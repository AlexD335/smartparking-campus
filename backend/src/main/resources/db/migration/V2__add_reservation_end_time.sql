ALTER TABLE reservations
    ADD COLUMN IF NOT EXISTS reservation_end_time TIME;

UPDATE reservations
SET reservation_end_time = reservation_time + INTERVAL '1 hour'
WHERE reservation_end_time IS NULL;

ALTER TABLE reservations
    ALTER COLUMN reservation_end_time SET NOT NULL;
