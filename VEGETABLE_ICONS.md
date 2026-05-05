# Vegetable Icon Generation Guide

> Instructions for generating SVG or PNG icons for every vegetable in the community garden planner app.

## Visual Style — Emoji-Inspired

The icons **replace emoji** in the UI, so they must feel like a **cohesive custom emoji set** — bold, colorful, chunky, and instantly readable at tiny sizes. Think Apple/Google emoji style but with a slightly more unified, matte color palette.

- **Format:** SVG (preferred for inline use) or PNG with transparent background.
- **Canvas:** `viewBox="0 0 24 24"` — 24×24 grid. Fill most of the frame (keep ~1px padding).
- **Style:** **Filled, bold, and chunky.** Solid color shapes with minimal internal detail. NO thin outlines, NO line art, NO botanical illustration. Each icon is a **simplified, colorful, solid glyph** — like an emoji, not a technical drawing.
- **Shapes:** Use large, simple, rounded forms. Exaggerate the distinctive silhouette of each vegetable. Fewer paths = better. Aim for 2–5 shapes per icon maximum.
- **Colors:** **Vibrant but not neon.** Use rich, saturated, natural produce colors (bright tomato red, vivid carrot orange, deep eggplant purple, lively leaf green). Each icon should use 2–3 solid fill colors (main body + highlight/shadow + stem/leaf accent). NO gradients, NO textures — flat fills only.
- **Outlines:** Optional thin dark outline (`stroke-width="0.5"` to `"1"`, color `#2d2d2d`) only if it helps the shape pop at small sizes. Many emoji-style icons work fine with no outline at all — just abutting colored shapes.
- **Highlights:** A single lighter spot or stripe on the main body gives a 3D "plump" feel (like emoji). Keep it as one simple shape, not a gradient.
- **Stems and leaves:** Small green accent (`#4a8c3f` or similar) on top. Keep stems short and thick — they must survive at 12px.
- **Corners:** Everything rounded. No sharp points. Soft, bubbly, friendly.
- **Consistency:** All 51 icons must share the same visual weight, color saturation level, shape boldness, and padding. They appear side by side — a mismatched icon will stand out immediately.

### What to Avoid

- Thin line art or outline-only icons (too faint at 12px)
- Photorealism or detailed shading
- Gradients or blur effects
- Overly muted/desaturated colors (the current emoji are bright — the replacements should be too)
- Too much internal detail (veins, seeds, texture lines) — simplify aggressively
- Tiny disconnected parts that disappear at small sizes

### Reference Style

Look at these emoji for the target feel: 🍅🥕🌽🍆🥦🫑🥬🍉🥒🧅. Match that level of boldness, fill, and simplification. The icons should be **at least as readable** as standard emoji when rendered at 12–20px.

## SVG Template

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <!-- solid filled shapes, no default stroke -->
  <!-- example: tomato body -->
  <circle cx="12" cy="13" r="9" fill="#E74C3C"/>
  <!-- example: highlight -->
  <ellipse cx="9" cy="10" rx="3" ry="2" fill="#F1948A" opacity="0.6"/>
  <!-- example: stem -->
  <path d="M12 4 C10 6, 14 6, 12 4" fill="#4A8C3F"/>
</svg>
```

## Rendering Sizes in the App

Icons appear at these sizes — they must be legible and recognizable at the smallest:

| Context              | CSS                  | Rendered Size |
|----------------------|----------------------|---------------|
| Segment bar strip    | `text-xs` (~12px)    | ~12×12 px     |
| Quick-pick badge     | `text-xs` (~12px)    | ~12×12 px     |
| Selected button      | `text-base` (~16px)  | ~16×16 px     |
| Picker list item     | `text-xl` (~20px)    | ~20×20 px     |

## Design Constraints

- **12px readability is the #1 priority.** If a detail disappears at 12px, remove it. Bold shapes and strong color contrast are more important than accuracy.
- Each icon should have a **unique silhouette** — identifiable by shape alone even as a single-color blob.
- Varieties of the same vegetable (e.g. 5 types of tomato) should share a base shape but differ via size, color shade, or one obvious visual tweak. Don't rely on subtle details for differentiation.
- RTL Hebrew context — avoid left/right directional bias.
- Light mode only — icons sit on light warm backgrounds (`#f0faf4` to `#e8f0ea`), so avoid very light/white fills on the icon body (they'd vanish).

## App Color Palette (for reference)

| Token      | Value                     | Hex Approx  |
|------------|---------------------------|-------------|
| Primary    | `oklch(0.48 0.12 150)`    | `#2d6a4f`   |
| Secondary  | `oklch(0.55 0.14 55)`     | warm amber  |
| Accent     | `oklch(0.65 0.14 60)`     | golden      |
| Base bg    | `oklch(0.98 0.005 145)`   | `#f0faf4`   |
| Base text  | `oklch(0.25 0.008 145)`   | dark gray   |

---

## Complete Vegetable List (51 items)

Each entry: **Hebrew name** | English name | icon description (emoji-style) | main fill color(s).

Keep shapes **bold, chunky, and filled**. Think emoji, not illustration.

### Fruiting Vegetables

| # | Hebrew Name | English | Icon Description | Fill Colors |
|---|-------------|---------|-----------------|-------------|
| 1 | מלפפונים | Cucumbers | Fat chunky cucumber, short and plump, small bumps suggested by 2–3 lighter dots, tiny stem on top | `#5B9A42` green body, `#7BC050` highlight |
| 2 | עגבניות שרי עגולה | Round cherry tomatoes | Two small round tomatoes side by side on a tiny green vine | `#E74C3C` red body, `#F1948A` highlight |
| 3 | עגבניות שרי תמר | Date cherry tomatoes | Two small oval/elongated tomatoes on a tiny green vine | `#E74C3C` red body, `#F1948A` highlight |
| 4 | עגבניות שרי שחור | Black cherry tomatoes | Two small round tomatoes on vine — noticeably darker | `#8B2252` dark berry, `#A8486B` highlight |
| 5 | עגבניה תמר | Date tomato | Single plump elongated plum tomato, green calyx on top | `#E53E30` red, `#F08070` highlight |
| 6 | עגבניה עגולה | Round tomato | Single large round tomato, star-shaped green calyx | `#E53E30` red, `#F08070` highlight |
| 7 | חציל בלאדי | Baladi eggplant | Round/globe eggplant, chunky green cap | `#7B3FA0` vivid purple, `#9B6DBF` highlight |
| 8 | חציל קלאסי | Classic eggplant | Long teardrop/pear eggplant with green cap | `#6A2D8A` deep purple, `#8B5AAF` highlight |
| 9 | פלפל גמבה | Bell pepper | Blocky wide bell pepper, short stem | `#E8C820` bright yellow, `#F0DA55` highlight |
| 10 | פלפל שושקה | Shoshka pepper | Elongated pointed pepper, short stem | `#E8C820` bright yellow, `#F0DA55` highlight |
| 11 | פלפלים חריפים | Hot peppers | Small curved chili pepper, vivid red | `#D63030` bright red, `#E86050` highlight |
| 12 | קישוא בהיר | Light zucchini | Straight plump squash, light colored | `#A8D464` light green, `#C0E890` highlight |
| 13 | קישוא עגול כהה | Dark round zucchini | Round/globe squash, dark green | `#3A7A30` dark green, `#58A048` highlight |
| 14 | זוקיני | Zucchini | Straight plump zucchini, medium green | `#4A9040` green, `#68B058` highlight |
| 15 | תירס | Corn | Corn cob with rows of kernels visible, partial green husk peeled back | `#F0C830` golden yellow kernels, `#5B9A42` husk |

### Melons & Squash

| # | Hebrew Name | English | Icon Description | Fill Colors |
|---|-------------|---------|-----------------|-------------|
| 16 | מלון | Melon | Round melon, faint net-pattern (2–3 curved lines), small stem | `#D4B870` tan/golden body, `#E8D090` highlight |
| 17 | אבטיח | Watermelon | Wedge/slice showing pink flesh, black seeds (2–3 dots), green rind | `#48A848` green rind, `#F06080` pink flesh, `#333` seeds |
| 18 | דלעת יפנית | Japanese pumpkin (kabocha) | Flat-round ribbed pumpkin, squat shape | `#2D6E3A` dark green body, `#408050` highlight |
| 19 | דלעת ערמונים | Chestnut squash | Acorn-shaped squash with 2–3 ridges | `#8A7040` warm brown, `#A08850` highlight |
| 20 | דלעת ספגטי | Spaghetti squash | Oblong/oval squash, bright yellow | `#E8D050` yellow body, `#F0E080` highlight |
| 21 | דלורית האני נאט | Honey Nut delicata | Small butternut shape (bulb bottom, narrow neck) | `#D49838` honey orange, `#E4B058` highlight |

### Root Vegetables

| # | Hebrew Name | English | Icon Description | Fill Colors |
|---|-------------|---------|-----------------|-------------|
| 22 | גזר | Carrot | Bold tapered carrot, chunky green leaf tuft on top | `#E8852A` bright orange, `#F0A050` highlight, `#4A8C3F` leaves |
| 23 | בצל | Onion | Round onion with papery point on top, tiny root at bottom | `#D4A84A` golden brown, `#E8C468` highlight |
| 24 | שום | Garlic | Garlic bulb with 2–3 clove lines, short stem | `#E8E0D0` off-white body, `#D0C8B8` shadow, `#C8B8A0` clove lines |
| 25 | צנון | Radish | Round bright radish with one small green leaf | `#E85030` red-orange body, `#F07058` highlight, `#4A8C3F` leaf |
| 26 | תפוח אדמה | Potato | Plump oval potato, 2–3 small dots for eyes | `#C8A060` warm tan, `#D8B878` highlight |
| 27 | בטטה | Sweet potato | Elongated tapered sweet potato shape | `#C06030` warm russet, `#D88050` highlight |
| 28 | סלק אדום | Red beetroot | Round beet, small stubs of leaves on top | `#A82040` deep crimson, `#C84060` highlight, `#4A8C3F` leaf stubs |
| 29 | סלק צהוב | Yellow beetroot | Round beet, small stubs of leaves on top, golden | `#D8A830` warm gold, `#E8C050` highlight, `#4A8C3F` leaf stubs |

### Leafy Greens

| # | Hebrew Name | English | Icon Description | Fill Colors |
|---|-------------|---------|-----------------|-------------|
| 30 | חסה ערבית | Arabic lettuce | Loose ruffled leaf cluster, wider/rounder shape | `#60A848` fresh green, `#80C868` highlight |
| 31 | חסה לליק | Lollo lettuce | Tightly curly-edged leaf cluster | `#50983C` medium green, `#70B858` highlight |
| 32 | תרד טורקי | Turkish spinach | Single broad smooth leaf with visible center vein | `#2D7A28` deep green, `#48A040` highlight |
| 33 | תרד ניוזילנדי | New Zealand spinach | Thick chunky triangular leaf shape | `#389838` rich green, `#58B850` highlight |
| 34 | רוקט | Arugula / Rocket | Single leaf with distinctive pointed lobes (oak-leaf shape) | `#3A7830` dark green, `#58A048` highlight |
| 35 | קייל | Kale | Curly/frilly leaf with ruffled edge | `#2A6830` deep blue-green, `#489848` highlight |
| 36 | מנגולד | Swiss chard | Broad leaf shape with thick colorful stem running through middle | `#3A8838` green leaf, `#D83030` red stem |
| 37 | כרוב לבן | White cabbage | Round tight cabbage head, 2–3 wrap lines | `#88C878` pale green, `#A8E098` highlight |
| 38 | כרוב סגול | Purple cabbage | Round tight cabbage head, 2–3 wrap lines | `#8040A0` purple, `#A060C0` highlight |
| 39 | בק צ׳וי | Bok choy | Chunky white stalks fanning into green leaf tops | `#E8E0D0` white stalks, `#48A040` green leaves |
| 40 | ברוקולי | Broccoli | Chunky broccoli floret cluster, short thick stem | `#2D7A28` dark green florets, `#58A048` highlight, `#6AAA5A` stem |

### Herbs

| # | Hebrew Name | English | Icon Description | Fill Colors |
|---|-------------|---------|-----------------|-------------|
| 41 | פטרוזיליה | Parsley | Three-lobed flat parsley leaf on short stem | `#40A038` bright green, `#60C050` highlight |
| 42 | כוסברה | Coriander / Cilantro | Fan-shaped cilantro leaf cluster (rounder lobes than parsley) | `#48A840` fresh green, `#68C858` highlight |
| 43 | נענע | Mint | Two opposite oval leaves on a short stem, slightly serrated edge | `#30A050` cool mint green, `#50C070` highlight |
| 44 | שמיר | Dill | Feathery frond — use 3–5 thick radiating lines (not fine hairlines) | `#60AA40` yellow-green, `#80C858` highlight |
| 45 | כרישה | Leek | Tall shape — white/light base cylinder, green leaf fan on top | `#E0D8C8` light base, `#50A040` green top |
| 46 | בזיליקום לימוני | Lemon basil | Pointed oval basil leaves on stem, bright lime tint | `#68B840` lime green, `#88D060` highlight |
| 47 | בזיליקום תאילנדי | Thai basil | Pointed oval basil leaves on stem, darker green with purple stem | `#3A8038` dark green leaves, `#6A3870` purple stem |
| 48 | סלרי | Celery | Celery stalk bunch (2–3 thick ribs) with small leafy top | `#78B858` light green stalks, `#48A040` leaves |

### Legumes

| # | Hebrew Name | English | Icon Description | Fill Colors |
|---|-------------|---------|-----------------|-------------|
| 49 | שעועית | Beans | Plump curved bean pod, wider shape | `#A07840` warm brown, `#B89058` highlight |
| 50 | שעועית ירוקה | Green beans | Slim straight green bean pod | `#48A040` fresh green, `#68C058` highlight |
| 51 | אפונה | Peas | Pea pod partially open showing 2–3 round peas inside | `#58A848` green pod, `#80D070` peas |

---

## Differentiating Varieties

Several vegetables have multiple varieties. Each variety should share a recognizable "family" shape but with a distinguishing detail:

### Tomatoes (5 varieties)
- **Base shape:** Round/oval tomato with a small star-shaped calyx.
- **שרי עגולה (round cherry):** Two small circles on a short vine.
- **שרי תמר (date cherry):** Two small ovals on a short vine.
- **שרי שחור (black cherry):** Two small circles, darker fill.
- **תמר (date/plum):** Single elongated oval.
- **עגולה (round):** Single large circle.

### Eggplants (2 varieties)
- **בלאדי (baladi):** Rounder, globe-shaped.
- **קלאסי (classic):** Long teardrop, more elongated.

### Peppers (3 varieties)
- **גמבה (bell):** Blocky wide shape.
- **שושקה (shoshka):** Elongated, pointed.
- **חריפים (hot):** Small, curved chili.

### Squash / Zucchini (3 varieties)
- **בהיר (light):** Straight cylinder, light fill.
- **עגול כהה (dark round):** Globe/disc shape, dark fill.
- **זוקיני:** Straight cylinder, medium green, blossom end visible.

### Pumpkins (4 varieties)
- **יפנית (kabocha):** Flat-round, dark green.
- **ערמונים (chestnut):** Acorn-shaped, brown-green.
- **ספגטי:** Oblong oval, yellow.
- **האני נאט (honey nut):** Small butternut shape, honey-toned.

### Lettuce (2 varieties)
- **ערבית (Arabic):** Loose, ruffled leaves.
- **לליק (lollo):** Extra curly leaf edges.

### Spinach (2 varieties)
- **טורקי (Turkish):** Broad, smooth, classic spinach shape.
- **ניוזילנדי (New Zealand):** Thicker, triangular, succulent-like.

### Cabbage (2 varieties)
- **לבן (white):** Pale green fill.
- **סגול (purple):** Purple fill.

### Basil (2 varieties)
- **לימוני (lemon):** Lighter, lime-green.
- **תאילנדי (Thai):** Darker green with purple tint on stem.

### Beetroot (2 varieties)
- **אדום (red):** Deep magenta-red fill.
- **צהוב (yellow):** Warm gold fill.

### Beans (2 varieties)
- **שעועית:** Wider, curved kidney-bean pod shape, brown.
- **שעועית ירוקה:** Slim, straight green pod.

---

## Notes for Generation

1. **Batch consistency is critical.** Generate all 51 icons in a single session/prompt so they share the same artistic hand.
2. **Emoji boldness test:** Hold each icon next to a real emoji (🍅🥕🍆🌽). It should feel like it belongs in the same row — same visual weight, same level of simplification, same color richness.
3. **Test at 12px.** Scale each icon down to 12×12 and verify it's still recognizable by silhouette alone. If it's not, simplify further — remove detail, make shapes bigger, increase color contrast.
4. **Name files** using the Hebrew name slugified or English name: e.g. `cucumber.svg`, `cherry-tomato-round.svg`, etc.
5. **Transparent background** — no background fill in the SVG, the app provides its own.
6. **No text or labels** inside the icon — the vegetable name is displayed separately in the UI.
7. **Keep SVG paths simple.** Fewer nodes = cleaner rendering at all sizes. Prefer circles, ellipses, and simple rounded paths over complex bezier curves.
8. **Color consistency across the set:** greens for all leafy/herb icons should use a related family of greens (not 15 random greens). Same for reds (tomatoes/peppers/beets) and yellows/oranges (peppers/squash/carrots).
