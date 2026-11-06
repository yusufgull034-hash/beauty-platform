-- İlk kurulumda mevcut çalışanları mevcut hizmetlerle senkronize et.
insert into public.staff_services (business_id, staff_user_id, service_id)
select bm.business_id, bm.user_id, s.id
from public.business_members bm
join public.services s on s.business_id = bm.business_id and s.is_active = true
where bm.role in ('owner', 'manager', 'staff')
on conflict (business_id, staff_user_id, service_id) do nothing;

create or replace function public.auto_assign_services_to_staff()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.staff_services (business_id, staff_user_id, service_id)
  select new.business_id, bm.user_id, new.id
  from public.business_members bm
  where bm.business_id = new.business_id
    and bm.role in ('owner', 'manager', 'staff')
  on conflict (business_id, staff_user_id, service_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_service_created_assign_staff on public.services;
create trigger on_service_created_assign_staff
  after insert on public.services
  for each row execute procedure public.auto_assign_services_to_staff();

create or replace function public.auto_assign_staff_to_services()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.staff_services (business_id, staff_user_id, service_id)
  select new.business_id, new.user_id, s.id
  from public.services s
  where s.business_id = new.business_id and s.is_active = true
  on conflict (business_id, staff_user_id, service_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_business_member_created_assign_services on public.business_members;
create trigger on_business_member_created_assign_services
  after insert on public.business_members
  for each row execute procedure public.auto_assign_staff_to_services();
