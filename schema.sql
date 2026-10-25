-- ProfitTrack Supabase schema
-- Safe to run on an existing project: creates the table if absent and adds missing app columns.
create table if not exists public.items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  purchase_price numeric not null default 0,
  sale_price numeric not null default 0,
  fees numeric not null default 0,
  status text not null default 'stock' check (status in ('stock','sold')),
  created_at timestamptz not null default now()
);

alter table public.items add column if not exists category text default 'Vêtements';
alter table public.items add column if not exists buy_price numeric default 0;
alter table public.items add column if not exists other_costs numeric default 0;
alter table public.items add column if not exists expected_price numeric default 0;
alter table public.items add column if not exists expected_fees numeric default 0;
alter table public.items add column if not exists actual_price numeric default 0;
alter table public.items add column if not exists actual_fees numeric default 0;
alter table public.items add column if not exists buy_date date default current_date;
alter table public.items add column if not exists sale_date date;
alter table public.items add column if not exists notes text;
alter table public.items add column if not exists updated_at timestamptz default now();

alter table public.items enable row level security;

drop policy if exists "Users can view their own items" on public.items;
create policy "Users can view their own items" on public.items
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can insert their own items" on public.items;
create policy "Users can insert their own items" on public.items
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update their own items" on public.items;
create policy "Users can update their own items" on public.items
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own items" on public.items;
create policy "Users can delete their own items" on public.items
  for delete to authenticated using (auth.uid() = user_id);

grant select, insert, update, delete on public.items to authenticated;
