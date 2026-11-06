create extension if not exists btree_gist;

alter table public.appointments
  drop constraint if exists appointments_no_overlapping_staff_appointments;

alter table public.appointments
  add constraint appointments_no_overlapping_staff_appointments
  exclude using gist (
    business_id with =,
    staff_user_id with =,
    tstzrange(starts_at, ends_at, '[)') with &&
  )
  where (
    status in ('pending', 'confirmed')
    and business_id is not null
    and staff_user_id is not null
    and starts_at is not null
    and ends_at is not null
  );
