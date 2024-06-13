package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
)

var (
	index    = template.Must(template.ParseFiles("public/index.html"))
	thankYou = template.Must(template.ParseFiles("public/thank-you.html"))
	form     = template.Must(template.ParseFiles("public/form.html"))
	rules    = template.Must(template.ParseFiles("public/rules.html"))
)

func main() {
	recipient := os.Getenv("SMTP_RECIPIENT")
	username := os.Getenv("SMTP_USERNAME")
	password := os.Getenv("SMTP_PASSWORD")
	sendEmailDisabled := os.Getenv("SEND_EMAIL_DISABLED") == "true"

	m := newMailer(recipient, username, password, sendEmailDisabled)

	http.HandleFunc("GET /", staticHandler(index))
	http.HandleFunc("GET /form", staticHandler(form))
	http.HandleFunc("GET /rules", staticHandler(rules))
	http.HandleFunc("POST /thank-you", sendEmail(m))

	if err := http.ListenAndServe(":80", nil); err != nil {
		log.Fatalf("fail to start server: %s", err)
	}
}

func staticHandler(t *template.Template) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := t.Execute(w, nil); err != nil {
			log.Printf("template error: %s", err)
		}
	}
}

func sendEmail(m *mailer) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := r.ParseForm()
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(w, "parse error: %s", err)
			return
		}

		body := emailBody{
			name:  r.FormValue("name"),
			card:  r.FormValue("card"),
			price: r.FormValue("price"),
			phone: r.FormValue("phone"),
			wish:  r.FormValue("wish"),
		}

		if err := body.validate(); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(w, "validation error: %s", err)
			return
		}

		if err := m.sendEmail(body.string()); err != nil {
			log.Println("fail to send email", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		staticHandler(thankYou)(w, r)
		return
	}
}
