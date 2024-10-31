package main

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ssm"
	"github.com/caarlos0/env"
	_ "github.com/joho/godotenv/autoload"
)

const (
	dbPassword = "/db/password"
	dbUser     = "/db/username"
	dbHost     = "/db/host"
	dbPort     = "/db/port"
	dbName     = "/db/name"

	smtpRecipient = "/smtp/recipient"
	smtpUsername  = "/smtp/username"
	smtpPassword  = "/smtp/password"
)

type Config struct {
	AWSRegion string `env:"AWS_REGION"`

	Recipient         string `env:"SMTP_RECIPIENT"`
	Username          string `env:"SMTP_USERNAME"`
	Password          string `env:"SMTP_PASSWORD"`
	SendEmailDisabled bool   `env:"SEND_EMAIL_DISABLED"`

	PostgresPassword   string `env:"POSTGRES_PASSWORD"`
	PostgresUser       string `env:"POSTGRES_USER"`
	PostgresHost       string `env:"POSTGRES_HOST"`
	PostgresPort       string `env:"POSTGRES_PORT"`
	PostgresDB         string `env:"POSTGRES_DB"`
	PostgresSSLEnabled bool
}

func (c *Config) PostgresDSN() string {
	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s",
		c.PostgresHost, c.PostgresPort, c.PostgresUser, c.PostgresPassword, c.PostgresDB)
}

func NewConfig() (*Config, error) {
	cfg := &Config{}
	if err := env.Parse(cfg); err != nil {
		return nil, err
	}

	if cfg.AWSRegion != "" {
		sess, err := session.NewSessionWithOptions(session.Options{
			Config:            aws.Config{Region: aws.String(cfg.AWSRegion)},
			SharedConfigState: session.SharedConfigEnable,
		})
		if err != nil {
			return nil, fmt.Errorf("fail to create aws session: %w", err)
		}

		ssmsvc := ssm.New(sess, aws.NewConfig().WithRegion(cfg.AWSRegion))

		secrets := map[string]string{
			dbPassword: "",
			dbUser:     "",
			dbHost:     "",
			dbPort:     "",
			dbName:     "",

			smtpRecipient: "",
			smtpUsername:  "",
			smtpPassword:  "",
		}

		for secret := range secrets {
			param, err := ssmsvc.GetParameter(&ssm.GetParameterInput{
				Name:           aws.String(secret),
				WithDecryption: aws.Bool(true),
			})
			if err != nil {
				return nil, fmt.Errorf("fail to get parameter by path %s: %w", secret, err)
			}
			if param.Parameter.Value == nil {
				return nil, fmt.Errorf("parameter %s is empty", secret)
			}

			secrets[secret] = *param.Parameter.Value
		}

		cfg.PostgresPassword = secrets[dbPassword]
		cfg.PostgresUser = secrets[dbUser]
		cfg.PostgresHost = secrets[dbHost]
		cfg.PostgresPort = secrets[dbPort]
		cfg.PostgresDB = secrets[dbName]

		cfg.Recipient = secrets[smtpRecipient]
		cfg.Username = secrets[smtpUsername]
		cfg.Password = secrets[smtpPassword]
	}

	return cfg, nil
}
