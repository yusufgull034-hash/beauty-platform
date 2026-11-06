create type public.user_role as enum ('customer', 'professional', 'business_owner', 'seller', 'admin');

create type public.appointment_status as enum ('pending', 'confirmed', 'completed', 'cancelled');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  avatar_url text,
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text,
  category text not null,
  address text,
  city text,
  latitude double precision,
  longitude double precision,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  description text,
  duration_minutes integer not null check (duration_minutes > 0),
  price numeric(10, 2) not null check (price >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles(id) on delete cascade,
  service_id uuid not null references public.services(id) on delete restrict,
  starts_at timestamptz not null,
  status public.appointment_status not null default 'pending',
  notes text,
  created_at timestamptz not null default now()
);

create index businesses_owner_id_idx on public.businesses(owner_id);
create index businesses_category_idx on public.businesses(category);
create index services_business_id_idx on public.services(business_id);
create index appointments_customer_id_idx on public.appointments(customer_id);
create index appointments_starts_at_idx on public.appointments(starts_at);

alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.services enable row level security;
alter table public.appointments enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can create their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Anyone can view active businesses"
  on public.businesses for select
  using (is_active = true or auth.uid() = owner_id);

create policy "Owners can create businesses"
  on public.businesses for insert
  with check (auth.uid() = owner_id);

create policy "Owners can update their businesses"
  on public.businesses for update
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

create policy "Owners can delete their businesses"
  on public.businesses for delete
  using (auth.uid() = owner_id);

create policy "Anyone can view active services"
  on public.services for select
  using (
    is_active = true
    or exists (
      select 1 from public.businesses b
      where b.id = business_id and b.owner_id = auth.uid()
    )
  );

create policy "Business owners can create services"
  on public.services for insert
  with check (
    exists (
      select 1 from public.businesses b
      where b.id = business_id and b.owner_id = auth.uid()
    )
  );

create policy "Business owners can update services"
  on public.services for update
  using (
    exists (
      select 1 from public.businesses b
      where b.id = business_id and b.owner_id = auth.uid()
    )
  );

create policy "Customers can view their appointments"
  on public.appointments for select
  using (auth.uid() = customer_id);

create policy "Business owners can view their appointments"
  on public.appointments for select
  using (
    exists (
      select 1
      from public.services s
      join public.businesses b on b.id = s.business_id
      where s.id = service_id and b.owner_id = auth.uid()
    )
  );

create policy "Customers can create appointments"
  on public.appointments for insert
  with check (auth.uid() = customer_id);

create policy "Customers can cancel their appointments"
  on public.appointments for update
  using (auth.uid() = customer_id)
  with check (auth.uid() = customer_id);

create policy "Business owners can update appointment status"
  on public.appointments for update
  using (
    exists (
      select 1
      from public.services s
      join public.businesses b on b.id = s.business_id
      where s.id = service_id and b.owner_id = auth.uid()
    )
  );

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
