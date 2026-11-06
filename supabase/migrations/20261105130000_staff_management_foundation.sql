alter table public.profiles
  add column if not exists email text;

update public.profiles p
set email = u.email
from auth.users u
where p.id = u.id
  and p.email is null;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (new.id, new.raw_user_meta_data ->> 'full_name', new.email)
  on conflict (id) do update
    set email = excluded.email;
  return new;
end;
$$;

drop policy if exists "Members can view their business memberships" on public.business_members;
create policy "Members and owners can view business memberships"
  on public.business_members for select
  using (
    auth.uid() = user_id
    or exists (
      select 1 from public.businesses b
      where b.id = business_id and b.owner_id = auth.uid()
    )
  );

create index if not exists profiles_email_idx on public.profiles(email);
