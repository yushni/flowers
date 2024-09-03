package main

import (
	"fmt"

	"github.com/caarlos0/env"
	_ "github.com/joho/godotenv/autoload"
)

type Config struct {
	Recipient         string `env:"SMTP_RECIPIENT"`
	Username          string `env:"SMTP_USERNAME"`
	Password          string `env:"SMTP_PASSWORD"`
	SendEmailDisabled bool   `env:"SEND_EMAIL_DISABLED"`

	PostgresPassword string `env:"POSTGRES_PASSWORD"`
	PostgresUser     string `env:"POSTGRES_USER"`
	PostgresHost     string `env:"POSTGRES_HOST"`
	PostgresPort     string `env:"POSTGRES_PORT"`
	PostgresDB       string `env:"POSTGRES_DB"`
}

func (c *Config) PostgresDSN() string {
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		c.PostgresHost, c.PostgresPort, c.PostgresUser, c.PostgresPassword, c.PostgresDB)
}

func NewConfig() (*Config, error) {
	cfg := &Config{}
	if err := env.Parse(cfg); err != nil {
		return nil, err
	}
	return cfg, nil
}
