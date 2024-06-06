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
}

func newMailer(recipient, username, password string) *mailer {
	return &mailer{
		auth:      smtp.PlainAuth("", username, password, host),
		recipient: recipient,
	}
}

func (e *mailer) sendEmail(text string) error {
	err := smtp.SendMail(address, e.auth, "", []string{e.recipient}, []byte(text))
	if err != nil {
		return fmt.Errorf("send mail: %w", err)
	}

	return nil
}
