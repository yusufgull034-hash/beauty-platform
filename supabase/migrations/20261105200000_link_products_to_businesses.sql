alter table public.products
  add column if not exists business_id uuid references public.businesses(id) on delete set null;

create index if not exists products_business_idx on public.products(business_id);

drop policy if exists "Sellers can create products" on public.products;
create policy "Sellers can create products"
  on public.products for insert
  with check (
    auth.uid() = seller_id
    and (business_id is null or exists (
      select 1 from public.businesses b
      where b.id = business_id and b.owner_id = auth.uid()
    ))
  );
