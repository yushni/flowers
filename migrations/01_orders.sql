-- +goose Up
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    card VARCHAR(255) NOT NULL,
    price INT NOT NULL,
    phone VARCHAR(255) NOT NULL,
    wish VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- +goose Down
DROP TABLE orders;