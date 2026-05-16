create extension if not exists pgcrypto;

create table if not exists public.clinics (
  id text not null,
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  abbr text,
  color text,
  hour_rate text,
  hours text,
  lump text,
  proc_pct text,
  mach_pct text,
  condition text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.shifts (
  id uuid default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  shift_date date not null,
  clinic_id text,
  condition text,
  hour_rate numeric default 0,
  hours numeric default 0,
  proc_pct numeric default 0,
  mach_pct numeric default 0,
  sitting numeric default 0,
  proc_fee numeric default 0,
  mach_fee numeric default 0,
  lump numeric default 0,
  total numeric default 0,
  patients jsonb not null default '[]'::jsonb,
  machs jsonb not null default '[]'::jsonb,
  paid_sitting boolean not null default false,
  paid_df boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_lists (
  id uuid default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  list_name text not null,
  items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.hanging_fees (
  id uuid default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  year_month text not null,
  amount numeric default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.clinics add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table public.clinics add column if not exists name text;
alter table public.clinics add column if not exists abbr text;
alter table public.clinics add column if not exists color text;
alter table public.clinics add column if not exists hour_rate text;
alter table public.clinics add column if not exists hours text;
alter table public.clinics add column if not exists lump text;
alter table public.clinics add column if not exists proc_pct text;
alter table public.clinics add column if not exists mach_pct text;
alter table public.clinics add column if not exists condition text;
alter table public.clinics add column if not exists created_at timestamptz not null default now();
alter table public.clinics add column if not exists updated_at timestamptz not null default now();

alter table public.shifts add column if not exists id uuid default gen_random_uuid();
alter table public.shifts add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table public.shifts add column if not exists clinic_id text;
alter table public.shifts add column if not exists condition text;
alter table public.shifts add column if not exists hour_rate numeric default 0;
alter table public.shifts add column if not exists hours numeric default 0;
alter table public.shifts add column if not exists proc_pct numeric default 0;
alter table public.shifts add column if not exists mach_pct numeric default 0;
alter table public.shifts add column if not exists sitting numeric default 0;
alter table public.shifts add column if not exists proc_fee numeric default 0;
alter table public.shifts add column if not exists mach_fee numeric default 0;
alter table public.shifts add column if not exists lump numeric default 0;
alter table public.shifts add column if not exists total numeric default 0;
alter table public.shifts add column if not exists patients jsonb not null default '[]'::jsonb;
alter table public.shifts add column if not exists machs jsonb not null default '[]'::jsonb;
alter table public.shifts add column if not exists paid_sitting boolean not null default false;
alter table public.shifts add column if not exists paid_df boolean not null default false;
alter table public.shifts add column if not exists created_at timestamptz not null default now();
alter table public.shifts add column if not exists updated_at timestamptz not null default now();

alter table public.user_lists add column if not exists id uuid default gen_random_uuid();
alter table public.user_lists add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table public.user_lists add column if not exists items jsonb not null default '[]'::jsonb;
alter table public.user_lists add column if not exists created_at timestamptz not null default now();
alter table public.user_lists add column if not exists updated_at timestamptz not null default now();

alter table public.hanging_fees add column if not exists id uuid default gen_random_uuid();
alter table public.hanging_fees add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table public.hanging_fees add column if not exists amount numeric default 0;
alter table public.hanging_fees add column if not exists created_at timestamptz not null default now();
alter table public.hanging_fees add column if not exists updated_at timestamptz not null default now();

alter table public.clinics disable row level security;
alter table public.shifts disable row level security;
alter table public.user_lists disable row level security;
alter table public.hanging_fees disable row level security;

do $$
declare r record;
begin
  for r in
    select conrelid::regclass as table_name, conname
    from pg_constraint
    where conrelid in ('public.clinics'::regclass,'public.shifts'::regclass,'public.user_lists'::regclass,'public.hanging_fees'::regclass)
      and contype in ('p','u')
  loop
    execute format('alter table %s drop constraint if exists %I', r.table_name, r.conname);
  end loop;
end $$;

drop index if exists public.shifts_shift_date_key;
drop index if exists public.clinics_user_id_id_key;
drop index if exists public.shifts_user_id_shift_date_key;
drop index if exists public.user_lists_user_id_list_name_key;
drop index if exists public.hanging_fees_user_id_year_month_key;

do $$
declare owner_id uuid;
begin
  select id into owner_id from auth.users order by created_at asc limit 1;

  if owner_id is null and (
    exists (select 1 from public.clinics where user_id is null) or
    exists (select 1 from public.shifts where user_id is null) or
    exists (select 1 from public.user_lists where user_id is null) or
    exists (select 1 from public.hanging_fees where user_id is null)
  ) then
    raise exception 'Cannot assign old rows because Supabase Auth has no users. Create/login one user first, then rerun this schema.';
  end if;

  update public.clinics set user_id = owner_id where user_id is null;
  update public.shifts set user_id = owner_id where user_id is null;
  update public.user_lists set user_id = owner_id where user_id is null;
  update public.hanging_fees set user_id = owner_id where user_id is null;
end $$;

drop table if exists pg_temp._cc_user_list_merge;
create temp table _cc_user_list_merge as
select user_id, list_name, jsonb_agg(distinct item.value) as items
from public.user_lists ul
left join lateral jsonb_array_elements(coalesce(ul.items,'[]'::jsonb)) as item(value) on true
where ul.user_id is not null
group by user_id, list_name;

drop table if exists pg_temp._cc_user_list_keep;
create temp table _cc_user_list_keep as
select distinct on (user_id, list_name) ctid as keep_ctid, user_id, list_name
from public.user_lists
where user_id is not null
order by user_id, list_name, updated_at desc nulls last, created_at desc nulls last, ctid desc;

with ranked as (
  select ctid, row_number() over (
    partition by user_id, id
    order by updated_at desc nulls last, created_at desc nulls last, ctid desc
  ) rn
  from public.clinics
  where user_id is not null
)
delete from public.clinics c
using ranked r
where c.ctid = r.ctid and r.rn > 1;

with ranked as (
  select ctid, row_number() over (
    partition by user_id, shift_date
    order by updated_at desc nulls last, created_at desc nulls last, ctid desc
  ) rn
  from public.shifts
  where user_id is not null
)
delete from public.shifts s
using ranked r
where s.ctid = r.ctid and r.rn > 1;

delete from public.user_lists ul
using pg_temp._cc_user_list_keep k
where ul.user_id = k.user_id
  and ul.list_name = k.list_name
  and ul.ctid <> k.keep_ctid;

update public.user_lists ul
set items = coalesce(m.items,'[]'::jsonb)
from pg_temp._cc_user_list_merge m
where ul.user_id = m.user_id and ul.list_name = m.list_name;

with ranked as (
  select ctid, row_number() over (
    partition by user_id, year_month
    order by updated_at desc nulls last, created_at desc nulls last, ctid desc
  ) rn
  from public.hanging_fees
  where user_id is not null
)
delete from public.hanging_fees h
using ranked r
where h.ctid = r.ctid and r.rn > 1;

do $$
declare dup text;
begin
  if exists (select 1 from public.user_lists where user_id is null) then
    raise exception 'user_lists still has rows with user_id null. Create/login one Supabase Auth user first, then rerun this schema.';
  end if;

  select string_agg(user_id::text || ':' || list_name || '=' || cnt::text, ', ')
  into dup
  from (
    select user_id, list_name, count(*) cnt
    from public.user_lists
    where user_id is not null
    group by user_id, list_name
    having count(*) > 1
  ) d;

  if dup is not null then
    raise exception 'Duplicate user_lists remain after cleanup: %', dup;
  end if;
end $$;

create unique index clinics_user_id_id_key on public.clinics (user_id, id);
create unique index shifts_user_id_shift_date_key on public.shifts (user_id, shift_date);
create unique index user_lists_user_id_list_name_key on public.user_lists (user_id, list_name);
create unique index hanging_fees_user_id_year_month_key on public.hanging_fees (user_id, year_month);

alter table public.clinics enable row level security;
alter table public.shifts enable row level security;
alter table public.user_lists enable row level security;
alter table public.hanging_fees enable row level security;

alter table public.clinics force row level security;
alter table public.shifts force row level security;
alter table public.user_lists force row level security;
alter table public.hanging_fees force row level security;

do $$
declare r record;
begin
  for r in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and tablename in ('clinics','shifts','user_lists','hanging_fees')
  loop
    execute format('drop policy if exists %I on %I.%I', r.policyname, r.schemaname, r.tablename);
  end loop;
end $$;

create policy "user read clinics" on public.clinics for select to authenticated using (auth.uid() = user_id);
create policy "user insert clinics" on public.clinics for insert to authenticated with check (auth.uid() = user_id);
create policy "user update clinics" on public.clinics for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "user delete clinics" on public.clinics for delete to authenticated using (auth.uid() = user_id);

create policy "user read shifts" on public.shifts for select to authenticated using (auth.uid() = user_id);
create policy "user insert shifts" on public.shifts for insert to authenticated with check (auth.uid() = user_id);
create policy "user update shifts" on public.shifts for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "user delete shifts" on public.shifts for delete to authenticated using (auth.uid() = user_id);

create policy "user read user lists" on public.user_lists for select to authenticated using (auth.uid() = user_id);
create policy "user insert user lists" on public.user_lists for insert to authenticated with check (auth.uid() = user_id);
create policy "user update user lists" on public.user_lists for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "user delete user lists" on public.user_lists for delete to authenticated using (auth.uid() = user_id);

create policy "user read hanging fees" on public.hanging_fees for select to authenticated using (auth.uid() = user_id);
create policy "user insert hanging fees" on public.hanging_fees for insert to authenticated with check (auth.uid() = user_id);
create policy "user update hanging fees" on public.hanging_fees for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "user delete hanging fees" on public.hanging_fees for delete to authenticated using (auth.uid() = user_id);
