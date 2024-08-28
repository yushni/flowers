package main

import "github.com/caarlos0/env"

type Config struct {
	Recipient         string `env:"SMTP_RECIPIENT"`
	Username          string `env:"SMTP_USERNAME"`
	Password          string `env:"SMTP_PASSWORD"`
	SendEmailDisabled bool   `env:"SEND_EMAIL_DISABLED" envDefault:"true"`
	PostgresDSN       string `env:"POSTGRES_DSN" envDefault:"postgres://postgres:postgres@localhost:5432/flowers?sslmode=disable"`
}

func NewConfig() (*Config, error) {
	cfg := &Config{}
	if err := env.Parse(cfg); err != nil {
		return nil, err
	}
	return cfg, nil
}
