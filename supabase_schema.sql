create table if not exists public.clinics (
  id text primary key,
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
  shift_date date primary key,
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
  list_name text primary key,
  items jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.hanging_fees (
  year_month text primary key,
  amount numeric default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

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
create unique index if not exists shifts_shift_date_key on public.shifts (shift_date);

alter table public.user_lists add column if not exists items jsonb not null default '[]'::jsonb;
alter table public.user_lists add column if not exists created_at timestamptz not null default now();
alter table public.user_lists add column if not exists updated_at timestamptz not null default now();

alter table public.hanging_fees add column if not exists amount numeric default 0;
alter table public.hanging_fees add column if not exists created_at timestamptz not null default now();
alter table public.hanging_fees add column if not exists updated_at timestamptz not null default now();

alter table public.clinics enable row level security;
alter table public.shifts enable row level security;
alter table public.user_lists enable row level security;
alter table public.hanging_fees enable row level security;

drop policy if exists "anon read clinics" on public.clinics;
drop policy if exists "anon insert clinics" on public.clinics;
drop policy if exists "anon update clinics" on public.clinics;
drop policy if exists "anon delete clinics" on public.clinics;

create policy "anon read clinics" on public.clinics for select to anon using (true);
create policy "anon insert clinics" on public.clinics for insert to anon with check (true);
create policy "anon update clinics" on public.clinics for update to anon using (true) with check (true);
create policy "anon delete clinics" on public.clinics for delete to anon using (true);

drop policy if exists "anon read shifts" on public.shifts;
drop policy if exists "anon insert shifts" on public.shifts;
drop policy if exists "anon update shifts" on public.shifts;
drop policy if exists "anon delete shifts" on public.shifts;

create policy "anon read shifts" on public.shifts for select to anon using (true);
create policy "anon insert shifts" on public.shifts for insert to anon with check (true);
create policy "anon update shifts" on public.shifts for update to anon using (true) with check (true);
create policy "anon delete shifts" on public.shifts for delete to anon using (true);

drop policy if exists "anon read user lists" on public.user_lists;
drop policy if exists "anon insert user lists" on public.user_lists;
drop policy if exists "anon update user lists" on public.user_lists;
drop policy if exists "anon delete user lists" on public.user_lists;

create policy "anon read user lists" on public.user_lists for select to anon using (true);
create policy "anon insert user lists" on public.user_lists for insert to anon with check (true);
create policy "anon update user lists" on public.user_lists for update to anon using (true) with check (true);
create policy "anon delete user lists" on public.user_lists for delete to anon using (true);

drop policy if exists "anon read hanging fees" on public.hanging_fees;
drop policy if exists "anon insert hanging fees" on public.hanging_fees;
drop policy if exists "anon update hanging fees" on public.hanging_fees;
drop policy if exists "anon delete hanging fees" on public.hanging_fees;

create policy "anon read hanging fees" on public.hanging_fees for select to anon using (true);
create policy "anon insert hanging fees" on public.hanging_fees for insert to anon with check (true);
create policy "anon update hanging fees" on public.hanging_fees for update to anon using (true) with check (true);
create policy "anon delete hanging fees" on public.hanging_fees for delete to anon using (true);
