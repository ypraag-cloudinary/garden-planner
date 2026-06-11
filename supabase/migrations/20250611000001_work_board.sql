-- Work board ("לוח עבודה"): garden task checklist + volunteer shift assignments.
-- Replaces the standalone organizer.html jsonb blob with relational tables.

-- garden_tasks: the "דברים לביצוע בגינה" checklist
create table garden_tasks (
  id uuid primary key default gen_random_uuid(),
  text text not null,
  completed boolean not null default false,
  position int not null default 0,
  created_at timestamptz default now()
);

alter table garden_tasks enable row level security;
create policy "Public read garden_tasks" on garden_tasks for select using (true);
create policy "Auth write garden_tasks" on garden_tasks for all using (auth.role() = 'authenticated');

-- garden_shifts: volunteer-coordinator assignments by date (day-agnostic)
create table garden_shifts (
  id uuid primary key default gen_random_uuid(),
  shift_date date not null,
  person text not null default '',
  created_at timestamptz default now()
);

alter table garden_shifts enable row level security;
create policy "Public read garden_shifts" on garden_shifts for select using (true);
create policy "Auth write garden_shifts" on garden_shifts for all using (auth.role() = 'authenticated');

-- Seed the 14 tasks (verbatim Hebrew text from organizer.html, ordered)
insert into garden_tasks (text, position) values
  ('גיוס נאמני גינה - להתחיל לגייס מתנדבים ולבנות בנק משימות', 1),
  ('הקמת הדליות בערוגות שנשארו (ערוגות 25 ו-27)', 2),
  ('מטבח: סיום חיפוי OSB', 3),
  ('מטבח: השלמת עבודות חשמל ואינסטלציה', 4),
  ('מטבח: להכניס כיור ושולחן נירוסטה', 5),
  ('מטבח: להכניס מקרר, כיריים ולחבר לגז', 6),
  ('השלמת 2 שלטי ערוגות חסרים עם המספרים', 7),
  ('לתלות לוח מחיק לטובת משימות על המחסן', 8),
  ('סידור החממה (כולל פתרונות הצללה והשקיה)', 9),
  ('החלפת הכיור באזור המדורה בזקיף עם ברז מים לשטיפת ידיים', 10),
  ('לדבר עם ארבל לגבי הכנסת הנוער לפעילות בגינה', 11),
  ('שתילות ביום עבודה בשבוע הבא (שתילות אחרונות לקיץ)', 12),
  ('שליחת סקר גינה לקראת המשך העבודה', 13),
  ('להביא הלמניה מברק לגינה ולרשום עליה את שמו', 14);

-- Seed the 4 Monday shift dates (converted to real 2026 dates; person left blank)
insert into garden_shifts (shift_date, person) values
  ('2026-06-15', ''),
  ('2026-06-22', ''),
  ('2026-06-29', ''),
  ('2026-07-06', '');
