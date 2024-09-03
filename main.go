package main

import (
	"database/sql"
	"embed"
	"html/template"
	"log"
	"net/http"

	_ "github.com/lib/pq"
	"github.com/pressly/goose/v3"
)

var (
	indexTmpl    = template.Must(template.ParseFiles("public/index.html", "public/heart.ico"))
	thankYouTmpl = template.Must(template.ParseFiles("public/thank-you.html", "public/heart.ico"))
	formTmpl     = template.Must(template.ParseFiles("public/form.html", "public/heart.ico"))
	rulesTmpl    = template.Must(template.ParseFiles("public/rules.html", "public/heart.ico"))
	errTmpl      = template.Must(template.ParseFiles("public/error.html", "public/heart.ico"))
	ordersTmpl   = template.Must(template.ParseFiles("public/orders.html", "public/heart.ico"))
)

//go:embed migrations/*.sql
var embedMigrations embed.FS

func main() {
	cfg, err := NewConfig()
	if err != nil {
		log.Fatalf("fail to parse config: %s", err)
	}

	db, err := sql.Open("postgres", cfg.PostgresDSN())
	if err != nil {
		log.Fatalf("fail to connect to db: %s", err)
	}
	defer db.Close()

	goose.SetBaseFS(embedMigrations)
	if err := goose.SetDialect("postgres"); err != nil {
		log.Fatalf("fail to set dialect: %s", err)
	}
	if err := goose.Up(db, "migrations"); err != nil {
		log.Fatalf("fail to apply migrations: %s", err)
	}

	s := NewStorage(db)
	http.HandleFunc("GET /", staticHandler(indexTmpl))
	http.HandleFunc("GET /form", staticHandler(formTmpl))
	http.HandleFunc("GET /rules", staticHandler(rulesTmpl))
	http.HandleFunc("GET /orders", ordersHandler(s))

	m := newMailer(cfg.Recipient, cfg.Username, cfg.Password, cfg.SendEmailDisabled)
	http.HandleFunc("POST /thank-you", thankYouHandler(m, s))

	if err := http.ListenAndServe(":80", nil); err != nil {
		log.Fatalf("fail to start server: %s", err)
	}
}
