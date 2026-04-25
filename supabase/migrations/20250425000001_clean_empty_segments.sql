-- Remove segments where users entered "ריק" as a placeholder for empty beds
DELETE FROM segments WHERE vegetable = 'ריק';

-- Remove the "ריק" entry from the vegetables lookup
DELETE FROM vegetables WHERE name = 'ריק';

-- Insert a proper "ריקה" vegetable for marking individual segments as empty
INSERT INTO vegetables (name, icon, days_to_harvest)
VALUES ('ריקה', '⬜', null)
ON CONFLICT (name) DO NOTHING;
