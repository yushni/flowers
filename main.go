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
	thankYou = template.Must(template.ParseFiles("public/thank_you.html"))
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
	http.HandleFunc("GET /thank_you", staticHandler(thankYou))

	http.HandleFunc("POST /subscribe", sendEmail(m))

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

		text := r.FormValue("text")
		if text == "" {
			w.WriteHeader(http.StatusBadRequest)
			fmt.Fprint(w, "empty text")
			return
		}
		//
		//if err := m.sendEmail(text); err != nil {
		//	log.Println("fail to send email", err)
		//	w.WriteHeader(http.StatusInternalServerError)
		//	return
		//}

		fmt.Println("email sent", text)
		return

		//if err := subscribe.Execute(w, nil); err != nil {
		//	log.Printf("template error: %s", err)
		//}
	}
}
