package main

import (
	"fmt"
	"net/smtp"
)

const (
	host    = "smtp.gmail.com"
	address = "smtp.gmail.com:587"
)

type mailer struct {
	auth      smtp.Auth
	recipient string
	disabled  bool
}

func newMailer(recipient, username, password string, disabled bool) *mailer {
	return &mailer{
		auth:      smtp.PlainAuth("", username, password, host),
		recipient: recipient,
		disabled:  disabled,
	}
}

func (e *mailer) sendEmail(body string) error {
	if e.disabled {
		return nil
	}

	err := smtp.SendMail(address, e.auth, "", []string{e.recipient}, []byte(body))
	if err != nil {
		return fmt.Errorf("send mail: %w", err)
	}

	return nil
}
