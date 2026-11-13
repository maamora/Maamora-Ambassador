-- =====================================================
-- VÉRIFICATION SÉCURITÉ SUPABASE — à exécuter dans SQL Editor
-- Lecture seule : aucune modification. Colle-moi le résultat
-- et je valide chaque point (garde RPC, policies, Storage).
-- =====================================================

-- ── 1. Policies RLS existantes (celles du dashboard, non versionnées) ────
select schemaname, tablename, policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname = 'public'
order by tablename, policyname;

-- ── 2. Tables : RLS actif ? forcé ? ──────────────────────────────────────
select c.relname as table_name,
       c.relrowsecurity as rls_enabled,
       c.relforcerowsecurity as rls_forced
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'table'
order by c.relname;

-- ── 3. Fonctions security definer et leur garde admin ────────────────────
-- ⚠️ LE POINT CRITIQUE : chaque fonction admin DOIT contenir
--    « if not public.is_admin() then raise exception » (ou équivalent
--    auth.uid() pour les fonctions ambassadeur).
select p.proname as function_name,
       p.prosecdef as security_definer,
       pg_get_userbyid(p.proowner) as owner,
       p.proargnames as param_names,
       p.prosrc as source_code
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'admin_set_ambassador_status',
    'admin_create_invite_code',
    'assign_commission',
    'admin_create_payout',
    'register_ambassador',
    'verify_invite_code_status',
    'check_invite_code',
    'create_deal_group',
    'increment_group_member',
    'increment_group_taps',
    'get_my_wallet_balance',
    'get_leaderboard',
    'get_my_ambassador_status',
    'is_admin'
  )
order by p.proname;

-- ── 4. Qui peut exécuter les RPC admin ? (GRANT EXECUTE) ─────────────────
-- Les fonctions admin doivent être interdites à anon ; seuls les rôles
-- authentifiés (admins via la garde is_admin) peuvent les appeler.
select p.proname as function_name,
       has_function_privilege('anon', p.oid, 'EXECUTE') as anon_can_execute,
       has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_can_execute
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'admin_set_ambassador_status',
    'admin_create_invite_code',
    'assign_commission',
    'admin_create_payout'
  )
order by p.proname;

-- ── 5. Buckets Storage et leur publicité ─────────────────────────────────
select id, name, public, file_size_limit, allowed_mime_types
from storage.buckets;

-- ── 6. Policies Storage ──────────────────────────────────────────────────
select schemaname, tablename, policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname = 'storage'
order by tablename, policyname;
