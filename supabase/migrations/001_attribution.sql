-- =====================================================
-- Migration: Attribution & Achat Groupé
-- Auteur: Yassine
-- Description: Ajoute le mécanisme d'achat groupé (product_groups), 
-- le type de produit (single/grouped), et l'attribution automatique 
-- des points + tier via triggers SQL.
-- =====================================================

-- ====== 1. Colonnes ajoutées à products ======
alter table products add column type text not null default 'single' 
  check (type in ('single', 'grouped'));

alter table products add column points_value int4 not null default 10;

alter table products add column seuil_min int4 not null default 5;

-- ====== 2. Table product_groups ======
create table product_groups (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id),
  ambassador_id uuid not null references ambassadors(id),
  seuil_min int4,
  compteur_actuel int4 not null default 0,
  statut text not null default 'en_attente',
  prix_groupe numeric,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

create unique index idx_product_groups_unique
  on product_groups (ambassador_id, product_id)
  where statut = 'en_attente';

-- ====== 3. Colonnes ajoutées à orders ======
alter table orders add column group_id uuid references product_groups(id);
alter table orders add column livraison_confirmee bool default false;
alter table orders add column points_awarded bool default false;

-- ====== 4. Trigger: auto-remplissage du seuil du groupe depuis le produit ======
create or replace function set_group_seuil_from_product()
returns trigger as $$
begin
  if new.seuil_min is null then
    select seuil_min into new.seuil_min
    from products
    where id = new.product_id;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_set_group_seuil
before insert on product_groups
for each row
execute function set_group_seuil_from_product();

-- ====== 5. Trigger: incrémentation du compteur + déblocage du groupe ======
create or replace function increment_group_counter()
returns trigger as $$
begin
  if new.group_id is not null then
    update product_groups
    set compteur_actuel = compteur_actuel + 1,
        updated_at = now(),
        statut = case
          when compteur_actuel + 1 >= seuil_min then 'débloqué'
          else statut
        end
    where id = new.group_id;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_increment_group_counter
after insert on orders
for each row
execute function increment_group_counter();

-- ====== 6. Fonction: calcul et mise à jour du tier de l'ambassadeur ======
create or replace function update_ambassador_tier(amb_id uuid)
returns void as $$
declare
  current_points int4;
  new_tier_id uuid;
begin
  select points_balance into current_points from ambassadors where id = amb_id;

  select id into new_tier_id
  from tiers
  where current_points >= level_min
    and (level_max is null or current_points <= level_max)
  order by level_min desc
  limit 1;

  if new_tier_id is not null then
    update ambassadors set tier_id = new_tier_id where id = amb_id;
  end if;
end;
$$ language plpgsql;

-- ====== 7. Trigger: attribution des points à la livraison confirmée ======
create or replace function award_points_and_update_tier()
returns trigger as $$
declare
  prod_type text;
  grp_statut text;
  pts int4;
begin
  if new.livraison_confirmee = true and old.livraison_confirmee = false then

    select type, points_value into prod_type, pts
    from products where id = new.product_id;

    if prod_type = 'single' then
      if new.points_awarded = false then
        update ambassadors set points_balance = points_balance + pts where id = new.ambassador_id;
        update orders set points_awarded = true where id = new.id;
        insert into points_history (ambassador_id, points, reason)
        values (new.ambassador_id, pts, 'commande single livrée');
      end if;

    elsif prod_type = 'grouped' then
      select statut into grp_statut from product_groups where id = new.group_id;
      if grp_statut = 'débloqué' and new.points_awarded = false then
        update ambassadors set points_balance = points_balance + pts where id = new.ambassador_id;
        update orders set points_awarded = true where id = new.id;
        insert into points_history (ambassador_id, points, reason)
        values (new.ambassador_id, pts, 'commande grouped livrée - groupe débloqué');
      end if;
    end if;

    perform update_ambassador_tier(new.ambassador_id);

  end if;

  return new;
end;
$$ language plpgsql;

create trigger trg_award_points_and_tier
after update on orders
for each row
execute function award_points_and_update_tier();

-- ====== 8. Trigger: rattrapage des points au déblocage du groupe ======
create or replace function award_points_on_group_unlock()
returns trigger as $$
declare
  o record;
  pts int4;
begin
  if new.statut = 'débloqué' and old.statut = 'en_attente' then
    select points_value into pts from products where id = new.product_id;

    for o in
      select * from orders
      where group_id = new.id
        and livraison_confirmee = true
        and points_awarded = false
    loop
      update ambassadors set points_balance = points_balance + pts where id = o.ambassador_id;
      update orders set points_awarded = true where id = o.id;
      insert into points_history (ambassador_id, points, reason)
      values (o.ambassador_id, pts, 'groupe débloqué - rattrapage points');
      perform update_ambassador_tier(o.ambassador_id);
    end loop;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trg_award_points_on_group_unlock
after update on product_groups
for each row
execute function award_points_on_group_unlock();

-- ====== 9. Données de référence: tiers (valeurs temporaires à valider par le fondateur) ======
insert into tiers (name, level_min, level_max, min_buyers, max_buyers, dh_per_buyer, weekly_bonus)
values
  ('Bronze', 0, 99, 0, 5, 5, 0),
  ('Silver', 100, 499, 5, 20, 8, 50),
  ('Gold', 500, null, 20, null, 12, 150)
on conflict (name) do nothing;
