-- =====================================================
-- Migration: Admin Create Payout RPC
-- Description: Adds a function to allow admins to settle an ambassador's wallet.
-- =====================================================

create or replace function admin_create_payout(
  p_ambassador_id uuid,
  p_method text,
  p_reference text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance numeric;
  v_payout_id uuid;
begin
  if not public.is_admin() then
    raise exception 'Réservé aux administrateurs';
  end if;

  select coalesce(sum(amount), 0) into v_balance
  from commissions
  where ambassador_id = p_ambassador_id and status = 'payable';

  if v_balance <= 0 then
    raise exception 'Aucun solde disponible pour cet ambassadeur';
  end if;

  insert into payouts (ambassador_id, week_ending_on, amount, method, status, reference, paid_at)
  values (
    p_ambassador_id,
    current_date,
    v_balance,
    p_method::payout_method_type,
    'paid'::payout_status,
    p_reference,
    now()
  )
  returning id into v_payout_id;

  update commissions
  set status = 'paid', payout_id = v_payout_id
  where ambassador_id = p_ambassador_id and status = 'payable';

  insert into admin_audit_log (admin_id, action, target_type, target_id, metadata)
  values (
    auth.uid(),
    'create_payout',
    'ambassador',
    p_ambassador_id,
    jsonb_build_object('amount', v_balance, 'method', p_method, 'reference', p_reference, 'payout_id', v_payout_id)
  );

  return v_payout_id;
end;
$$;
