create table public.seller_stores (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  slug text not null unique,
  description text,
  logo_url text,
  is_verified boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.products
  add column if not exists store_id uuid references public.seller_stores(id) on delete set null;

create index seller_stores_owner_idx on public.seller_stores(owner_id);
create index products_store_idx on public.products(store_id);

alter table public.seller_stores enable row level security;

create policy "Anyone can view active seller stores"
  on public.seller_stores for select
  using (is_active = true or auth.uid() = owner_id);

create policy "Owners can create seller stores"
  on public.seller_stores for insert
  with check (auth.uid() = owner_id);

create policy "Owners can update seller stores"
  on public.seller_stores for update
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

create policy "Owners can delete seller stores"
  on public.seller_stores for delete
  using (auth.uid() = owner_id);
