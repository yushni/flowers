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
	sendEmailDisabled := os.Getenv("SEND_EMAIL_DISABLED") == "true"

	m := newMailer(recipient, username, password, sendEmailDisabled)

	http.Handle("/", http.FileServer(http.Dir("./public")))
	http.HandleFunc("/subscribe", sendEmail(m))
	log.Fatal(http.ListenAndServe(":80", nil))
}

func sendEmail(m *mailer) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		err := r.ParseForm()
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			fmt.Fprintf(w, "parse error: %s", err)
			return
		}

		text := r.FormValue("text")
		if text == "" {
			w.WriteHeader(http.StatusBadRequest)
			fmt.Fprint(w, "empty text")
			return
		}

		if err := m.sendEmail(text); err != nil {
			log.Println("fail to send email", err)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		tmpl := template.Must(template.ParseFiles("subscribe.html"))
		if err := tmpl.Execute(w, nil); err != nil {
			log.Printf("template error: %s", err)
		}
	}
}
