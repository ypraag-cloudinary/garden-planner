-- Add planned/planted status to segments
alter table segments add column is_planned boolean not null default true;
alter table segment_history add column is_planned boolean not null default false;

-- Update existing segments to "planted" since they are current plantings
update segments set is_planned = false;

-- Update save_segments RPC to include is_planned
create or replace function save_segments(
  p_row_id int,
  p_segments jsonb
) returns void as $$
begin
  delete from segments where row_id = p_row_id;

  insert into segments (row_id, position, vegetable, planted_at, length_m, notes, is_planned)
  select
    p_row_id,
    (elem->>'position')::int,
    elem->>'vegetable',
    (elem->>'planted_at')::date,
    (elem->>'length_m')::numeric,
    elem->>'notes',
    coalesce((elem->>'is_planned')::boolean, true)
  from jsonb_array_elements(p_segments) as elem;
end;
$$ language plpgsql security definer;
