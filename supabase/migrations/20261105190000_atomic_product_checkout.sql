create or replace function public.create_product_order(p_items jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order_id uuid;
  v_item jsonb;
  v_product public.products;
  v_quantity integer;
  v_total numeric(10, 2) := 0;
begin
  if auth.uid() is null then raise exception 'Sipariş için giriş yapmalısınız'; end if;
  if jsonb_array_length(p_items) = 0 then raise exception 'Sepet boş'; end if;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_quantity := (v_item->>'quantity')::integer;
    if v_quantity is null or v_quantity <= 0 then raise exception 'Geçersiz ürün adedi'; end if;
    select * into v_product from public.products where id = (v_item->>'product_id')::uuid for update;
    if v_product.id is null or not v_product.is_active then raise exception 'Ürün satışta değil'; end if;
    if v_product.stock < v_quantity then raise exception 'Yetersiz stok: %', v_product.name; end if;
    v_total := v_total + (v_product.price * v_quantity);
  end loop;

  insert into public.product_orders (customer_id, total_amount)
  values (auth.uid(), v_total)
  returning id into v_order_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_quantity := (v_item->>'quantity')::integer;
    select * into v_product from public.products where id = (v_item->>'product_id')::uuid for update;
    update public.products set stock = stock - v_quantity, updated_at = now() where id = v_product.id;
    insert into public.product_order_items (order_id, product_id, quantity, unit_price)
    values (v_order_id, v_product.id, v_quantity, v_product.price);
  end loop;

  return v_order_id;
end;
$$;

grant execute on function public.create_product_order(jsonb) to authenticated;
