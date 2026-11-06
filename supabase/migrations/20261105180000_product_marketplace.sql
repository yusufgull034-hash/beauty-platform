create type public.order_status as enum ('pending', 'confirmed', 'preparing', 'shipped', 'delivered', 'cancelled');

create table public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text,
  category text not null,
  brand text,
  price numeric(10, 2) not null check (price >= 0),
  stock integer not null default 0 check (stock >= 0),
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles(id) on delete cascade,
  status public.order_status not null default 'pending',
  total_amount numeric(10, 2) not null default 0 check (total_amount >= 0),
  shipping_address text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.product_order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.product_orders(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  quantity integer not null check (quantity > 0),
  unit_price numeric(10, 2) not null check (unit_price >= 0),
  unique (order_id, product_id)
);

create index products_category_idx on public.products(category);
create index products_seller_idx on public.products(seller_id);
create index product_orders_customer_idx on public.product_orders(customer_id, created_at desc);
create index order_items_product_idx on public.product_order_items(product_id);

alter table public.products enable row level security;
alter table public.product_orders enable row level security;
alter table public.product_order_items enable row level security;

create policy "Anyone can view active products"
  on public.products for select
  using (is_active = true or auth.uid() = seller_id);

create policy "Sellers can create products"
  on public.products for insert
  with check (auth.uid() = seller_id);

create policy "Sellers can update their products"
  on public.products for update
  using (auth.uid() = seller_id)
  with check (auth.uid() = seller_id);

create policy "Sellers can delete their products"
  on public.products for delete
  using (auth.uid() = seller_id);

create policy "Customers can view their orders"
  on public.product_orders for select
  using (auth.uid() = customer_id);

create policy "Customers can create their orders"
  on public.product_orders for insert
  with check (auth.uid() = customer_id);

create policy "Customers can update their orders"
  on public.product_orders for update
  using (auth.uid() = customer_id)
  with check (auth.uid() = customer_id);

create policy "Customers can view their order items"
  on public.product_order_items for select
  using (exists (
    select 1 from public.product_orders o
    where o.id = order_id and o.customer_id = auth.uid()
  ));

create policy "Customers can create order items"
  on public.product_order_items for insert
  with check (exists (
    select 1 from public.product_orders o
    where o.id = order_id and o.customer_id = auth.uid()
  ));
