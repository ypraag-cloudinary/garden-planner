-- Replace emoji icons with PNG filename stems (resolved to /icons/{name}.png at runtime)

-- Original seed vegetables (20250101000002)
UPDATE vegetables SET icon = 'cucumber' WHERE name = 'מלפפונים';
UPDATE vegetables SET icon = 'carrot' WHERE name = 'גזר';
UPDATE vegetables SET icon = 'onion' WHERE name = 'בצל';
UPDATE vegetables SET icon = 'garlic' WHERE name = 'שום';
UPDATE vegetables SET icon = 'parsley' WHERE name = 'פטרוזיליה';
UPDATE vegetables SET icon = 'coriander' WHERE name = 'כוסברה';
UPDATE vegetables SET icon = 'mint' WHERE name = 'נענע';
UPDATE vegetables SET icon = 'beans' WHERE name = 'שעועית';
UPDATE vegetables SET icon = 'peas' WHERE name = 'אפונה';
UPDATE vegetables SET icon = 'radish' WHERE name = 'צנון';
UPDATE vegetables SET icon = 'potato' WHERE name = 'תפוח אדמה';
UPDATE vegetables SET icon = 'sweet-potato' WHERE name = 'בטטה';
UPDATE vegetables SET icon = 'leek' WHERE name = 'כרישה';
UPDATE vegetables SET icon = 'dill' WHERE name = 'שמיר';
UPDATE vegetables SET icon = 'corn' WHERE name = 'תירס';
UPDATE vegetables SET icon = 'cherry-tomato-round' WHERE name = 'עגבניות שרי עגולה';
UPDATE vegetables SET icon = 'cherry-tomato-date' WHERE name = 'עגבניות שרי תמר';
UPDATE vegetables SET icon = 'cherry-tomato-black' WHERE name = 'עגבניות שרי שחור';
UPDATE vegetables SET icon = 'date-tomato' WHERE name = 'עגבניה תמר';
UPDATE vegetables SET icon = 'round-tomato' WHERE name = 'עגבניה עגולה';
UPDATE vegetables SET icon = 'eggplant-baladi' WHERE name = 'חציל בלאדי';
UPDATE vegetables SET icon = 'eggplant-classic' WHERE name = 'חציל קלאסי';
UPDATE vegetables SET icon = 'bell-pepper' WHERE name = 'פלפל גמבה';
UPDATE vegetables SET icon = 'shoshka-pepper' WHERE name = 'פלפל שושקה';
UPDATE vegetables SET icon = 'hot-pepper' WHERE name = 'פלפלים חריפים';
UPDATE vegetables SET icon = 'melon' WHERE name = 'מלון';
UPDATE vegetables SET icon = 'watermelon' WHERE name = 'אבטיח';
UPDATE vegetables SET icon = 'kabocha' WHERE name = 'דלעת יפנית';
UPDATE vegetables SET icon = 'chestnut-squash' WHERE name = 'דלעת ערמונים';
UPDATE vegetables SET icon = 'spaghetti-squash' WHERE name = 'דלעת ספגטי';
UPDATE vegetables SET icon = 'honey-nut' WHERE name = 'דלורית האני נאט';
UPDATE vegetables SET icon = 'lemon-basil' WHERE name = 'בזיליקום לימוני';
UPDATE vegetables SET icon = 'thai-basil' WHERE name = 'בזיליקום תאילנדי';
UPDATE vegetables SET icon = 'arabic-lettuce' WHERE name = 'חסה ערבית';
UPDATE vegetables SET icon = 'lollo-lettuce' WHERE name = 'חסה לליק';
UPDATE vegetables SET icon = 'turkish-spinach' WHERE name = 'תרד טורקי';
UPDATE vegetables SET icon = 'nz-spinach' WHERE name = 'תרד ניוזילנדי';
UPDATE vegetables SET icon = 'light-zucchini' WHERE name = 'קישוא בהיר';
UPDATE vegetables SET icon = 'dark-round-zucchini' WHERE name = 'קישוא עגול כהה';
UPDATE vegetables SET icon = 'zucchini' WHERE name = 'זוקיני';
UPDATE vegetables SET icon = 'broccoli' WHERE name = 'ברוקולי';
UPDATE vegetables SET icon = 'white-cabbage' WHERE name = 'כרוב לבן';
UPDATE vegetables SET icon = 'purple-cabbage' WHERE name = 'כרוב סגול';
UPDATE vegetables SET icon = 'arugula' WHERE name = 'רוקט';
UPDATE vegetables SET icon = 'kale' WHERE name = 'קייל';
UPDATE vegetables SET icon = 'swiss-chard' WHERE name = 'מנגולד';
UPDATE vegetables SET icon = 'celery' WHERE name = 'סלרי';
UPDATE vegetables SET icon = 'bok-choy' WHERE name = 'בק צ׳וי';
UPDATE vegetables SET icon = 'red-beet' WHERE name = 'סלק אדום';
UPDATE vegetables SET icon = 'yellow-beet' WHERE name = 'סלק צהוב';

-- Added in 20250430000002
UPDATE vegetables SET icon = 'green-beans' WHERE name = 'שעועית ירוקה';

-- Added in 20250504000001
UPDATE vegetables SET icon = NULL WHERE name = 'קולרבי';
UPDATE vegetables SET icon = 'broccoli' WHERE name = 'כרובית';
UPDATE vegetables SET icon = NULL WHERE name = 'כרוב ניצנים';
UPDATE vegetables SET icon = NULL WHERE name = 'לפת';
UPDATE vegetables SET icon = 'carrot' WHERE name = 'גזר לבן';
UPDATE vegetables SET icon = NULL WHERE name = 'במיה';
UPDATE vegetables SET icon = NULL WHERE name = 'אספרגוס';
UPDATE vegetables SET icon = 'onion' WHERE name = 'שאלוט';
UPDATE vegetables SET icon = 'radish' WHERE name = 'צנונית';

-- "ריקה" (empty marker) — clear the icon
UPDATE vegetables SET icon = NULL WHERE name = 'ריקה';
