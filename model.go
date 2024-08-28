package main

import (
	"errors"
	"fmt"
)

type order struct {
	Name, Card, Price, Phone, Wish string
}

func (e order) validate() error {
	var errs []error
	if e.Name == "" {
		errs = append(errs, fmt.Errorf("name is required"))
	}
	if e.Card == "" {
		errs = append(errs, fmt.Errorf("card is required"))
	}
	if e.Price == "" {
		errs = append(errs, fmt.Errorf("price is required"))
	}
	if e.Phone == "" {
		errs = append(errs, fmt.Errorf("phone is required"))
	}
	if e.Wish == "" {
		errs = append(errs, fmt.Errorf("wish is required"))
	}

	if len(errs) > 0 {
		return errors.Join(errs...)
	}
	return nil
}

func (e order) string() string {
	return fmt.Sprintf(`
		Нове замовлення
		Ім'я: %s
		Номер телефону: %s
		Ціна: %s
		Телефон: %s
		Побажання: %s
	`, e.Name, e.Card, e.Price, e.Phone, e.Wish)
}
