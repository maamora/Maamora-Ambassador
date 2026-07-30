-- =====================================================
-- Migration: Auto-creation ambassadeur apres inscription OAuth/Email
-- Description: Quand un utilisateur est cree dans auth.users (via OAuth
-- Google, email/mot de passe, etc.), un trigger cree automatiquement
-- une ligne dans la table public.ambassadors avec les valeurs par defaut.
-- =====================================================

-- Fonction utilitaire : genere un code de parrainage unique de 8 caracteres
create or replace function generate_referral_code(base_name text)
returns text as $$
declare
  code text;
  prefix text;
  exists_check int;
begin
  prefix := upper(substring(regexp_replace(base_name, ''[^a-zA-Z]'', '''', ''g''), 1, 4));
  if length(prefix) < 4 then
    prefix := rpad(prefix, 4, ''X'');
  end if;

  loop
    code := prefix || lpad(floor(random() * 10000)::text, 4, ''0'');
    select count(*) into exists_check from public.ambassadors where referral_code = code;
    exit when exists_check = 0;
  end loop;

  return code;
end;
$$ language plpgsql;

-- Fonction appelee par le trigger : cree l ambassadeur si inexistant
create or replace function public.handle_new_user()
returns trigger as $$
declare
  amb_name  text;
  amb_email text;
  ref_code  text;
begin
  amb_name  := coalesce(
    new.raw_user_meta_data->''full_name'',
    new.raw_user_meta_data->''name'',
    split_part(new.email, ''@'', 1),
    ''Ambassadeur''
  );
  amb_email := new.email;

  if not exists (select 1 from public.ambassadors where auth_id = new.id) then
    ref_code := generate_referral_code(amb_name);
    insert into public.ambassadors (auth_id, name, email, referral_code, points_total)
    values (new.id, amb_name, amb_email, ref_code, 0);
  end if;

  return new;
end;
$$ language plpgsql security definer;

-- Trigger : se declenche a chaque nouvel utilisateur dans auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();
