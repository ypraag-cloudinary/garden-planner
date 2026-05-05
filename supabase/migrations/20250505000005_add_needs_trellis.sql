alter table vegetables add column needs_trellis boolean not null default false;

update vegetables set needs_trellis = true where name in (
  'עגבניות שרי עגולה',
  'עגבניות שרי תמר',
  'עגבניות שרי שחור',
  'עגבניה תמר',
  'עגבניה עגולה',
  'מלפפונים',
  'שעועית',
  'שעועית ירוקה',
  'אפונה'
);
