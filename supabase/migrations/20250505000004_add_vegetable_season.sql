-- Add planting season metadata to vegetables (Israeli climate)
-- Seasons: fall (Sep-Nov), winter (Dec-Feb), spring (Mar-May), summer (Jun-Aug)
-- A vegetable can belong to multiple seasons.

alter table vegetables add column season text[];

-- Summer crops (spring + summer planting)
update vegetables set season = '{spring,summer}' where name in (
  'מלפפונים',
  'עגבניות שרי עגולה',
  'עגבניות שרי תמר',
  'עגבניות שרי שחור',
  'עגבניה תמר',
  'עגבניה עגולה',
  'חציל בלאדי',
  'חציל קלאסי',
  'פלפל גמבה',
  'פלפל שושקה',
  'פלפלים חריפים',
  'מלון',
  'אבטיח',
  'תירס',
  'במיה',
  'קישוא בהיר',
  'קישוא עגול כהה',
  'זוקיני',
  'שעועית',
  'שעועית ירוקה'
);

-- Squash — spring planting
update vegetables set season = '{spring}' where name in (
  'דלעת יפנית',
  'דלעת ערמונים',
  'דלעת ספגטי',
  'דלורית האני נאט'
);

-- Sweet potato & regular potato
update vegetables set season = '{spring,summer}' where name = 'בטטה';
update vegetables set season = '{winter,spring}' where name = 'תפוח אדמה';

-- Fall/winter crops (cool-season vegetables)
update vegetables set season = '{fall,winter}' where name in (
  'ברוקולי',
  'כרובית',
  'כרוב לבן',
  'כרוב סגול',
  'כרוב ניצנים',
  'קולרבי',
  'קייל',
  'רוקט',
  'חסה ערבית',
  'חסה לליק',
  'תרד טורקי',
  'תרד ניוזילנדי',
  'מנגולד',
  'בק צ׳וי',
  'סלק אדום',
  'סלק צהוב',
  'לפת',
  'אפונה'
);

-- Root vegetables and alliums — fall through spring
update vegetables set season = '{fall,winter,spring}' where name in (
  'גזר',
  'גזר לבן',
  'בצל',
  'שום',
  'שאלוט',
  'צנון',
  'צנונית',
  'כרישה'
);

-- Herbs — varies by type
update vegetables set season = '{spring,summer}' where name in (
  'בזיליקום',
  'בזיליקום תאילנדי'
);
update vegetables set season = '{fall,winter,spring}' where name in (
  'פטרוזיליה',
  'כוסברה',
  'שמיר'
);
update vegetables set season = '{spring,summer,fall}' where name = 'נענע';
update vegetables set season = '{fall,winter,spring}' where name = 'סלרי';

-- Asparagus — perennial, planted in winter/spring
update vegetables set season = '{winter,spring}' where name = 'אספרגוס';
