package main

import (
	"html/template"
	"log"
	"net/http"
	"os"
)

var (
	indexTmpl    = template.Must(template.ParseFiles("public/index.html", "public/heart.ico"))
	thankYouTmpl = template.Must(template.ParseFiles("public/thank-you.html", "public/heart.ico"))
	formTmpl     = template.Must(template.ParseFiles("public/form.html", "public/heart.ico"))
	rulesTmpl    = template.Must(template.ParseFiles("public/rules.html", "public/heart.ico"))
	errTmpl      = template.Must(template.ParseFiles("public/error.html", "public/heart.ico"))
)

func main() {
	recipient := os.Getenv("SMTP_RECIPIENT")
	username := os.Getenv("SMTP_USERNAME")
	password := os.Getenv("SMTP_PASSWORD")
	sendEmailDisabled := os.Getenv("SEND_EMAIL_DISABLED") == "true"

	m := newMailer(recipient, username, password, sendEmailDisabled)

	http.HandleFunc("GET /", staticHandler(indexTmpl))
	http.HandleFunc("GET /form", staticHandler(formTmpl))
	http.HandleFunc("GET /rules", staticHandler(rulesTmpl))
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
		if err := r.ParseForm(); err != nil {
			staticErrorHandler(err)(w, r)
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
			staticErrorHandler(err)(w, r)
			return
		}

		if err := m.sendEmail(body.string()); err != nil {
			staticErrorHandler(err)(w, r)
			return
		}

		staticHandler(thankYouTmpl)(w, r)
		return
	}
}

func staticErrorHandler(err error) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Println(err)

		w.WriteHeader(http.StatusInternalServerError)
		if err := errTmpl.Execute(w, nil); err != nil {
			log.Printf("template error: %s", err)
		}
	}
}
