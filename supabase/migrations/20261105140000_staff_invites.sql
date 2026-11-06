create or replace function public.add_staff_member(
  p_business_id uuid,
  p_email text,
  p_role text default 'staff'
)
returns public.business_members
language plpgsql
security definer
set search_path = public
as $$
declare
  v_staff_id uuid;
  v_member public.business_members;
begin
  if not exists (
    select 1 from public.businesses
    where id = p_business_id and owner_id = auth.uid()
  ) then
    raise exception 'Bu işletme için yetkiniz yok';
  end if;

  select id into v_staff_id
  from public.profiles
  where lower(email) = lower(trim(p_email))
  limit 1;

  if v_staff_id is null then
    raise exception 'Bu e-posta ile kayıtlı kullanıcı bulunamadı';
  end if;

  insert into public.business_members (business_id, user_id, role)
  values (p_business_id, v_staff_id, p_role)
  on conflict (business_id, user_id) do update set role = excluded.role
  returning * into v_member;

  return v_member;
end;
$$;

grant execute on function public.add_staff_member(uuid, text, text) to authenticated;
