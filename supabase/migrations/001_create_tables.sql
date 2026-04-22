-- Garden rows
create table rows (
  id int primary key,
  length_m numeric not null default 10,
  drip_spacing_cm int not null default 20,
  pipes_count int not null default 3,
  section text not null check (section in ('left', 'right')),
  notes text
);

-- Vegetable lookup
create table vegetables (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  icon text,
  days_to_harvest int
);

-- Row segments (parts of a row with different vegetables)
create table segments (
  id uuid primary key default gen_random_uuid(),
  row_id int not null references rows(id) on delete cascade,
  position int not null default 1,
  vegetable text not null,
  planted_at date,
  length_m numeric,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (row_id, position)
);

-- Auto-update updated_at
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger segments_updated_at
  before update on segments
  for each row
  execute function update_updated_at();

-- Allow public access (no auth)
alter table rows enable row level security;
alter table vegetables enable row level security;
alter table segments enable row level security;

create policy "Public read rows" on rows for select using (true);
create policy "Public write rows" on rows for all using (true);

create policy "Public read vegetables" on vegetables for select using (true);
create policy "Public write vegetables" on vegetables for all using (true);

create policy "Public read segments" on segments for select using (true);
create policy "Public write segments" on segments for all using (true);
