-- Run this once in the Supabase SQL Editor.
-- RLS ensures a signed-in user can only read and change their own movie rows.

create table if not exists public.movies (
  user_id uuid not null references auth.users (id) on delete cascade,
  id text not null,
  title text not null,
  status text not null check (status in ('Completed', 'Plan to watch', 'Watching', 'Dropped')),
  rating numeric(3,1) check (rating is null or (rating >= 0 and rating <= 10)),
  next_three_months boolean not null default false,
  is_deleted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

alter table public.movies enable row level security;

revoke all on table public.movies from anon, public;
grant select, insert, update, delete on table public.movies to authenticated;

drop policy if exists "Users can read their own movies" on public.movies;
create policy "Users can read their own movies"
  on public.movies for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can add their own movies" on public.movies;
create policy "Users can add their own movies"
  on public.movies for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own movies" on public.movies;
create policy "Users can update their own movies"
  on public.movies for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can remove their own movies" on public.movies;
create policy "Users can remove their own movies"
  on public.movies for delete
  to authenticated
  using ((select auth.uid()) = user_id);
