package main

import (
	"database/sql"

	_ "github.com/lib/pq"
)

type Storage struct {
	db *sql.DB
}

func NewStorage(db *sql.DB) Storage {
	return Storage{db: db}
}

func (s Storage) SaveOrder(o order) error {
	_, err := s.db.Exec("INSERT INTO orders (Name, Card, Price, Phone, Wish) VALUES ($1, $2, $3, $4, $5)",
		o.Name, o.Card, o.Price, o.Phone, o.Wish)

	return err
}

func (s Storage) Orders() ([]order, error) {
	rows, err := s.db.Query("SELECT Name, Card, Price, Phone, Wish FROM orders")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var orders []order
	for rows.Next() {
		var o order
		if err := rows.Scan(&o.Name, &o.Card, &o.Price, &o.Phone, &o.Wish); err != nil {
			return nil, err
		}
		orders = append(orders, o)
	}

	return orders, nil
}

func (s Storage) Close() error {
	return s.db.Close()
}
