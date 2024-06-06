package main

import "testing"

func TestName(t *testing.T) {
	m := newMailer(
		"yurii.shnitsar@gmail.com",
		"yuriy.shnitsar@gmail.com",
		"bplw vozx svzh baix",
	)

	err := m.sendEmail("Hello, World!")
	if err != nil {
		t.Errorf("send email: %v", err)
	}
}
