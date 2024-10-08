package main

import (
	"html/template"
	"log"
	"net/http"
)

func staticHandler(t *template.Template) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := t.Execute(w, nil); err != nil {
			log.Printf("template error: %s", err)
		}
	}
}

func thankYouHandler(m *mailer, s Storage) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := r.ParseForm(); err != nil {
			staticErrorHandler(err)(w, r)
			return
		}

		body := order{
			Name:  r.FormValue("name"),
			Card:  r.FormValue("card"),
			Price: r.FormValue("price"),
			Phone: r.FormValue("phone"),
			Wish:  r.FormValue("wish"),
		}

		if err := body.validate(); err != nil {
			staticErrorHandler(err)(w, r)
			return
		}

		if err := s.SaveOrder(body); err != nil {
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

func ordersHandler(s Storage) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		orders, err := s.Orders()
		if err != nil {
			staticErrorHandler(err)(w, r)
			return
		}

		if err := ordersTmpl.Execute(w, orders); err != nil {
			log.Printf("template error: %s", err)
		}
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
