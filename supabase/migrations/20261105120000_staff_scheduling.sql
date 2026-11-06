-- İşletme içindeki çalışanların ve çalışan bazlı takvimin temeli.

create table public.staff_services (
  business_id uuid not null references public.businesses(id) on delete cascade,
  staff_user_id uuid not null references public.profiles(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (business_id, staff_user_id, service_id)
);

create table public.staff_working_hours (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  staff_user_id uuid not null references public.profiles(id) on delete cascade,
  weekday smallint not null check (weekday between 1 and 7),
  starts_at time not null,
  ends_at time not null,
  is_active boolean not null default true,
  check (ends_at > starts_at),
  unique (business_id, staff_user_id, weekday)
);

create table public.staff_time_off (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  staff_user_id uuid not null references public.profiles(id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  reason text,
  check (ends_at > starts_at)
);

alter table public.appointments
  add column if not exists business_id uuid references public.businesses(id) on delete cascade,
  add column if not exists staff_user_id uuid references public.profiles(id) on delete restrict,
  add column if not exists ends_at timestamptz;

update public.appointments a
set business_id = s.business_id,
    ends_at = a.starts_at + make_interval(mins => s.duration_minutes)
from public.services s
where a.service_id = s.id
  and (a.business_id is null or a.ends_at is null);

create index staff_services_service_idx on public.staff_services(service_id);
create index staff_working_hours_staff_idx on public.staff_working_hours(business_id, staff_user_id);
create index staff_time_off_staff_idx on public.staff_time_off(business_id, staff_user_id, starts_at);
create index appointments_staff_time_idx on public.appointments(business_id, staff_user_id, starts_at);

alter table public.staff_services enable row level security;
alter table public.staff_working_hours enable row level security;
alter table public.staff_time_off enable row level security;

create policy "Anyone can view active staff services"
  on public.staff_services for select
  using (true);

create policy "Business owners manage staff services"
  on public.staff_services for all
  using (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()))
  with check (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()));

create policy "Anyone can view active working hours"
  on public.staff_working_hours for select
  using (is_active = true);

create policy "Business owners manage working hours"
  on public.staff_working_hours for all
  using (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()))
  with check (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()));

create policy "Business owners manage staff time off"
  on public.staff_time_off for all
  using (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()))
  with check (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()));

create policy "Customers can view active appointment staff"
  on public.appointments for select
  using (auth.uid() = customer_id or exists (
    select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()
  ));

