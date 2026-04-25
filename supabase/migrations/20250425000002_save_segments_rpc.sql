create or replace function save_segments(
  p_row_id int,
  p_segments jsonb
) returns void as $$
begin
  delete from segments where row_id = p_row_id;

  insert into segments (row_id, position, vegetable, planted_at, length_m, notes)
  select
    p_row_id,
    (elem->>'position')::int,
    elem->>'vegetable',
    (elem->>'planted_at')::date,
    (elem->>'length_m')::numeric,
    elem->>'notes'
  from jsonb_array_elements(p_segments) as elem;
end;
$$ language plpgsql security definer;
