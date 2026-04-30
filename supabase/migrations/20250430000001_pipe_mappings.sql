create table pipe_mappings (
  pipe_number int primary key,
  description text not null default '',
  updated_at timestamptz default now()
);

alter table pipe_mappings enable row level security;

create policy "Public read pipe_mappings" on pipe_mappings for select using (true);
create policy "Auth write pipe_mappings" on pipe_mappings for all using (auth.role() = 'authenticated');

insert into pipe_mappings (pipe_number, description) values
  (1, ''),
  (2, ''),
  (3, ''),
  (4, ''),
  (5, 'ירקות'),
  (6, 'חממה');
