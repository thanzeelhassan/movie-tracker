-- One-time move: copies TV show rows out of public.movies into public.tv_shows,
-- checks every one arrived, and only then deletes them from public.movies.
-- Run supabase-schema.sql first so public.tv_shows exists. Safe to run again.
-- TV show rows are the ones whose id starts with "show-".

begin;

-- 1. Copy. If a show is already in tv_shows, keep whichever copy was updated last.
insert into public.tv_shows (user_id, id, title, status, rating, is_deleted, created_at, updated_at)
select user_id, id, title, status, rating, is_deleted, created_at, updated_at
from public.movies
where id like 'show-%'
on conflict (user_id, id) do update
  set title = excluded.title,
      status = excluded.status,
      rating = excluded.rating,
      is_deleted = excluded.is_deleted,
      created_at = excluded.created_at,
      updated_at = excluded.updated_at
  where public.tv_shows.updated_at < excluded.updated_at;

-- 2. Safety check. Stop, and undo everything above, if any show in movies has no
--    matching row in tv_shows that is at least as new.
do $$
declare
  missing integer;
  to_move integer;
begin
  select count(*) into to_move from public.movies where id like 'show-%';
  select count(*) into missing
  from public.movies m
  where m.id like 'show-%'
    and not exists (
      select 1 from public.tv_shows t
      where t.user_id = m.user_id
        and t.id = m.id
        and t.updated_at >= m.updated_at
    );
  if missing > 0 then
    raise exception 'Stopped: % of % TV show rows did not copy into tv_shows. Nothing was changed.', missing, to_move;
  end if;
  raise notice 'Check passed: % TV show rows are in tv_shows. Removing them from movies.', to_move;
end $$;

-- 3. Remove the copied shows from the movies table.
delete from public.movies m
using public.tv_shows t
where m.id like 'show-%'
  and t.user_id = m.user_id
  and t.id = m.id;

commit;

-- Afterwards, these should show 0 and your show count:
-- select count(*) as shows_left_in_movies from public.movies where id like 'show-%';
-- select count(*) as shows_in_tv_shows from public.tv_shows;
