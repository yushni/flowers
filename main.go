package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
)

func main() {
	recipient := os.Getenv("SMTP_RECIPIENT")
	username := os.Getenv("SMTP_USERNAME")
	password := os.Getenv("SMTP_PASSWORD")

	m := newMailer(recipient, username, password)

	http.HandleFunc("/", renderForm)
	http.HandleFunc("/subscribe", sendEmail(m))
	log.Fatal(http.ListenAndServe(":80", nil))
}

func renderForm(w http.ResponseWriter, r *http.Request) {
	tmpl := template.Must(template.ParseFiles("index.html"))
	if err := tmpl.Execute(w, nil); err != nil {
		log.Printf("template error: %s", err)
	}
}

func sendEmail(m *mailer) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		err := r.ParseForm()
		if err != nil {
			fmt.Fprintf(w, "parse error: %s", err)
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		text := r.FormValue("text")
		if text == "" {
			fmt.Fprint(w, "empty text")
			w.WriteHeader(http.StatusBadRequest)
			return
		}

		if err := m.sendEmail(text); err != nil {
			fmt.Fprintf(w, "send email: %s", err)
			return
		}
	}
}
