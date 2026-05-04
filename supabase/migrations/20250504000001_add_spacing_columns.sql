-- Add planting spacing metadata to vegetables
alter table vegetables add column spacing_cm int;
alter table vegetables add column lines text check (lines in ('all', 'sides', 'middle'));
alter table vegetables add column is_seeded boolean not null default false;

-- Set spacing data for all existing vegetables
update vegetables set spacing_cm = 30, lines = 'sides' where name = 'מלפפונים';
update vegetables set spacing_cm = 5,  lines = 'all', is_seeded = true where name = 'גזר';
update vegetables set spacing_cm = 12, lines = 'all' where name = 'בצל';
update vegetables set spacing_cm = 12, lines = 'all' where name = 'שום';
update vegetables set spacing_cm = 10, lines = 'all' where name = 'פטרוזיליה';
update vegetables set spacing_cm = 10, lines = 'all' where name = 'כוסברה';
update vegetables set spacing_cm = 25, lines = 'all' where name = 'נענע';
update vegetables set spacing_cm = 10, lines = 'all' where name = 'שעועית';
update vegetables set spacing_cm = 10, lines = 'all' where name = 'שעועית ירוקה';
update vegetables set spacing_cm = 5,  lines = 'all', is_seeded = true where name = 'אפונה';
update vegetables set spacing_cm = 5,  lines = 'all', is_seeded = true where name = 'צנון';
update vegetables set spacing_cm = 30, lines = 'sides' where name = 'תפוח אדמה';
update vegetables set spacing_cm = 35, lines = 'sides' where name = 'בטטה';
update vegetables set spacing_cm = 10, lines = 'all' where name = 'כרישה';
update vegetables set spacing_cm = 12, lines = 'all' where name = 'שמיר';
update vegetables set spacing_cm = 20, lines = 'sides' where name = 'תירס';
update vegetables set spacing_cm = 40, lines = 'sides' where name = 'עגבניות שרי עגולה';
update vegetables set spacing_cm = 40, lines = 'sides' where name = 'עגבניות שרי תמר';
update vegetables set spacing_cm = 40, lines = 'sides' where name = 'עגבניות שרי שחור';
update vegetables set spacing_cm = 50, lines = 'sides' where name = 'עגבניה תמר';
update vegetables set spacing_cm = 60, lines = 'sides' where name = 'עגבניה עגולה';
update vegetables set spacing_cm = 50, lines = 'sides' where name = 'חציל בלאדי';
update vegetables set spacing_cm = 50, lines = 'sides' where name = 'חציל קלאסי';
update vegetables set spacing_cm = 45, lines = 'sides' where name = 'פלפל גמבה';
update vegetables set spacing_cm = 45, lines = 'sides' where name = 'פלפל שושקה';
update vegetables set spacing_cm = 45, lines = 'sides' where name = 'פלפלים חריפים';
update vegetables set spacing_cm = 60, lines = 'middle' where name = 'מלון';
update vegetables set spacing_cm = 60, lines = 'middle' where name = 'אבטיח';
update vegetables set spacing_cm = 60, lines = 'middle' where name = 'דלעת יפנית';
update vegetables set spacing_cm = 60, lines = 'middle' where name = 'דלעת ערמונים';
update vegetables set spacing_cm = 60, lines = 'middle' where name = 'דלעת ספגטי';
update vegetables set spacing_cm = 60, lines = 'middle' where name = 'דלורית האני נאט';
update vegetables set spacing_cm = 20, lines = 'all' where name = 'בזיליקום לימוני';
update vegetables set spacing_cm = 20, lines = 'all' where name = 'בזיליקום תאילנדי';
update vegetables set spacing_cm = 25, lines = 'all' where name = 'חסה ערבית';
update vegetables set spacing_cm = 25, lines = 'all' where name = 'חסה לליק';
update vegetables set spacing_cm = 15, lines = 'all' where name = 'תרד טורקי';
update vegetables set spacing_cm = 15, lines = 'all' where name = 'תרד ניוזילנדי';
update vegetables set spacing_cm = 60, lines = 'sides' where name = 'קישוא בהיר';
update vegetables set spacing_cm = 60, lines = 'sides' where name = 'קישוא עגול כהה';
update vegetables set spacing_cm = 60, lines = 'sides' where name = 'זוקיני';
update vegetables set spacing_cm = 50, lines = 'sides' where name = 'ברוקולי';
update vegetables set spacing_cm = 50, lines = 'sides' where name = 'כרוב לבן';
update vegetables set spacing_cm = 50, lines = 'sides' where name = 'כרוב סגול';
update vegetables set spacing_cm = 12, lines = 'all' where name = 'רוקט';
update vegetables set spacing_cm = 20, lines = 'sides' where name = 'קייל';
update vegetables set spacing_cm = 20, lines = 'all' where name = 'מנגולד';
update vegetables set spacing_cm = 15, lines = 'all' where name = 'סלרי';
update vegetables set spacing_cm = 25, lines = 'all' where name = 'בק צ׳וי';
update vegetables set spacing_cm = 5,  lines = 'all' where name = 'סלק אדום';
update vegetables set spacing_cm = 5,  lines = 'all' where name = 'סלק צהוב';

-- Insert new vegetables with spacing data
insert into vegetables (name, icon, days_to_harvest, spacing_cm, lines, is_seeded) values
  ('קולרבי', '🥬', 55, 20, 'all', false),
  ('כרובית', '🥦', 85, 50, 'sides', false),
  ('כרוב ניצנים', '🥬', 100, 60, 'sides', false),
  ('לפת', '🟤', 50, 10, 'all', true),
  ('גזר לבן', '🟤', 100, 10, 'all', true),
  ('במיה', '🟢', 60, 40, 'sides', false),
  ('אספרגוס', '🌿', 365, 40, 'sides', false),
  ('שאלוט', '🧅', 90, 12, 'all', false),
  ('צנונית', '🟠', 25, 5, 'all', true);
