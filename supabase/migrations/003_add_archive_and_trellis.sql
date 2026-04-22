-- Archive table for crop rotation history
create table segment_history (
  id uuid primary key default gen_random_uuid(),
  row_id int not null references rows(id) on delete cascade,
  position int not null,
  vegetable text not null,
  planted_at date,
  archived_at date not null default current_date,
  length_m numeric,
  notes text
);

alter table segment_history enable row level security;
create policy "Public read segment_history" on segment_history for select using (true);
create policy "Public write segment_history" on segment_history for all using (true);

-- Trellis indicator on rows
alter table rows add column has_trellis boolean not null default false;
