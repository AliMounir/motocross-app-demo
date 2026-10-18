-- Admin dashboard read access for /admin.html
-- Run this once in the Supabase SQL editor (Dashboard → SQL Editor → New query → paste → Run).
--
-- The waitlist and survey_responses tables stay locked to the public (RLS unchanged).
-- This function runs as its owner (security definer), checks the password server-side,
-- and only then returns the rows. The password never ships in the website's code.
-- To change the password, edit it below and run the file again.

create or replace function public.admin_dashboard(p_password text)
returns json
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_password is distinct from '121314' then
    perform pg_sleep(1); -- slows down guessing
    raise exception 'invalid password' using errcode = '28P01';
  end if;

  return json_build_object(
    'waitlist', coalesce((select json_agg(w order by w.created_at desc) from public.waitlist w), '[]'::json),
    'surveys',  coalesce((select json_agg(s order by s.created_at desc) from public.survey_responses s), '[]'::json)
  );
end;
$$;

revoke all on function public.admin_dashboard(text) from public;
grant execute on function public.admin_dashboard(text) to anon, authenticated;
