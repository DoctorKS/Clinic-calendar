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

update public.clinics set user_id = (select id from auth.users order by created_at asc limit 1)
where user_id is null and exists (select 1 from auth.users);
update public.shifts set user_id = (select id from auth.users order by created_at asc limit 1)
where user_id is null and exists (select 1 from auth.users);
update public.user_lists set user_id = (select id from auth.users order by created_at asc limit 1)
where user_id is null and exists (select 1 from auth.users);
update public.hanging_fees set user_id = (select id from auth.users order by created_at asc limit 1)
where user_id is null and exists (select 1 from auth.users);

do $$
declare r record;
begin
  for r in
    select conrelid::regclass as table_name, conname
    from pg_constraint
    where conrelid in ('public.clinics'::regclass,'public.shifts'::regclass,'public.user_lists'::regclass,'public.hanging_fees'::regclass)
      and contype = 'p'
  loop
    execute format('alter table %s drop constraint if exists %I', r.table_name, r.conname);
  end loop;
end $$;

drop index if exists public.shifts_shift_date_key;
drop index if exists public.clinics_user_id_id_key;
drop index if exists public.shifts_user_id_shift_date_key;
drop index if exists public.user_lists_user_id_list_name_key;
drop index if exists public.hanging_fees_user_id_year_month_key;

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
