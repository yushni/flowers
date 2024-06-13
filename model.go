package main

import (
	"errors"
	"fmt"
)

type emailBody struct {
	name, card, price, phone, wish string
}

func (e emailBody) validate() error {
	var errs []error
	if e.name == "" {
		errs = append(errs, fmt.Errorf("name is required"))
	}
	if e.card == "" {
		errs = append(errs, fmt.Errorf("card is required"))
	}
	if e.price == "" {
		errs = append(errs, fmt.Errorf("price is required"))
	}
	if e.phone == "" {
		errs = append(errs, fmt.Errorf("phone is required"))
	}
	if e.wish == "" {
		errs = append(errs, fmt.Errorf("wish is required"))
	}

	if len(errs) > 0 {
		return errors.Join(errs...)
	}
	return nil
}

func (e emailBody) string() string {
	return fmt.Sprintf(`
		Нове замовлення
		Ім'я: %s
		Номер телефону: %s
		Ціна: %s
		Телефон: %s
		Побажання: %s
	`, e.name, e.card, e.price, e.phone, e.wish)
}
