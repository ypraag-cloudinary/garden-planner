-- Replace public-write policies with authenticated-only

drop policy "Public write rows" on rows;
drop policy "Public write vegetables" on vegetables;
drop policy "Public write segments" on segments;
drop policy "Public write segment_history" on segment_history;

create policy "Auth write rows" on rows for all using (auth.role() = 'authenticated');
create policy "Auth write vegetables" on vegetables for all using (auth.role() = 'authenticated');
create policy "Auth write segments" on segments for all using (auth.role() = 'authenticated');
create policy "Auth write segment_history" on segment_history for all using (auth.role() = 'authenticated');
