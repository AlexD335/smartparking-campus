ALTER TABLE app_users
    ADD COLUMN full_name VARCHAR(120),
    ADD COLUMN institutional_code VARCHAR(30),
    ADD COLUMN phone VARCHAR(20),
    ADD COLUMN vehicle_type VARCHAR(30),
    ADD COLUMN vehicle_plate VARCHAR(15),
    ADD COLUMN vehicle_color VARCHAR(30);