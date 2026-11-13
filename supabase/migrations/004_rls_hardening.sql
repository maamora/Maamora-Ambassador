-- =====================================================
-- Migration: RLS Hardening (durcissement sécurité)
-- Description: durcit la sécurité SANS changer le comportement de l'app :
--   1. Active et FORCE le RLS sur toutes les tables sensibles
--      (FORCE = même le propriétaire de table passe par les policies).
--   2. Retire à anon (clé publishable) tout droit d'écriture directe
--      sur les tables d'administration — l'écriture doit passer par les
--      RPC security definer avec garde is_admin()/auth.uid().
--   Idempotent : peut être relancé sans erreur (IF EXISTS / blocs DO).
-- ⚠️ Ne crée AUCUNE policy permissive nouvelle : impossible d'élargir
--    l'accès par accident si cette migration est rejouée ailleurs.
-- =====================================================

-- ── 1. RLS activé + forcé ────────────────────────────────────────────────
do $$
declare
  t text;
begin
  foreach t in array array[
    'admins',
    'ambassadors',
    'commissions',
    'payouts',
    'admin_audit_log',
    'invite_codes',
    'deal_groups',
    'level_history'
  ]
  loop
    -- Activer le RLS si absent (no-op si déjà actif)
    execute format('alter table if exists public.%I enable row level security', t);
    -- Forcer le RLS même pour le propriétaire (durcissement)
    execute format('alter table if exists public.%I force row level security', t);
  end loop;
end $$;

-- ── 2. anon ne doit RIEN écrire directement ──────────────────────────────
-- Les écrans passent par des RPC security definer ; les écritures directes
-- depuis la clé publishable ne sont jamais légitimes.
do $$
declare
  t text;
begin
  foreach t in array array[
    'admins',
    'ambassadors',
    'commissions',
    'payouts',
    'admin_audit_log',
    'invite_codes',
    'deal_groups',
    'level_history'
  ]
  loop
    execute format('revoke insert, update, delete, truncate on public.%I from anon', t);
  end loop;
end $$;

-- L'anonyme ne doit jamais lire la table des admins du tout
revoke select on public.admins from anon;

-- ── 3. authenticated ne modifie pas la table admins ──────────────────────
revoke insert, update, delete, truncate on public.admins from authenticated;

-- ── 3bis. Fonctions admin : EXECUTE réservé aux connectés ────────────────
-- Les 4 RPC admin sont gardées en interne par is_admin(), mais on ferme
-- aussi l'accès EXECUTE à l'anonyme (défense en profondeur). Idempotent.
do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as fn
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'admin_set_ambassador_status',
        'admin_create_invite_code',
        'assign_commission',
        'admin_create_payout'
      )
  loop
    execute format('revoke execute on function %s from anon, public', r.fn);
    execute format('grant execute on function %s to authenticated', r.fn);
  end loop;
end $$;

-- ── 4. Fonction utilitaire is_admin : défense en profondeur ──────────────
-- (recreate conservatrice : ne touche que la fonction, pas les policies)
-- Vérifie dans verify_security.sql si elle existe déjà sous cette forme.

-- =====================================================
-- VÉRIFICATIONS À FAIRE À LA MAIN (SQL Editor) — voir
-- supabase/verify_security.sql : il liste les policies existantes, les
-- RPC et leurs gardes is_admin()/auth.uid(). Les policies de lecture
-- (SELECT) déjà configurées dans le dashboard sont CONSERVÉES telles
-- quelles par cette migration.
-- =====================================================
