create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid not null unique references public.appointments(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete cascade,
  business_id uuid not null references public.businesses(id) on delete cascade,
  staff_user_id uuid references public.profiles(id) on delete set null,
  service_id uuid not null references public.services(id) on delete restrict,
  business_rating smallint not null check (business_rating between 1 and 5),
  staff_rating smallint check (staff_rating between 1 and 5),
  review_text text,
  business_reply text,
  is_visible boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index reviews_business_idx on public.reviews(business_id, created_at desc);
create index reviews_staff_idx on public.reviews(staff_user_id, created_at desc);

create or replace function public.validate_review_appointment()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_appointment public.appointments;
begin
  select * into v_appointment from public.appointments where id = new.appointment_id;
  if v_appointment.id is null then raise exception 'Randevu bulunamadı'; end if;
  if v_appointment.customer_id <> new.customer_id then raise exception 'Bu randevuyu değerlendirme yetkiniz yok'; end if;
  if v_appointment.status <> 'completed' then raise exception 'Yalnızca tamamlanan randevular değerlendirilebilir'; end if;
  if v_appointment.business_id <> new.business_id or v_appointment.service_id <> new.service_id then raise exception 'Değerlendirme randevu bilgileriyle eşleşmiyor'; end if;
  if v_appointment.staff_user_id is not null and new.staff_user_id is distinct from v_appointment.staff_user_id then raise exception 'Çalışan bilgisi randevuyla eşleşmiyor'; end if;
  return new;
end;
$$;

create trigger validate_review_before_insert
  before insert on public.reviews
  for each row execute procedure public.validate_review_appointment();

alter table public.reviews enable row level security;

create policy "Anyone can view visible reviews"
  on public.reviews for select
  using (is_visible = true);

create policy "Customers can create their own reviews"
  on public.reviews for insert
  with check (auth.uid() = customer_id);

create policy "Customers can update their own reviews"
  on public.reviews for update
  using (auth.uid() = customer_id)
  with check (auth.uid() = customer_id);

create policy "Business owners can reply to reviews"
  on public.reviews for update
  using (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()))
  with check (exists (select 1 from public.businesses b where b.id = business_id and b.owner_id = auth.uid()));
