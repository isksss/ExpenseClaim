package main

import (
	"log"
	"os"

	"github.com/isksss/ExpenseClaim/apps/backend/internal/server"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	e := server.New()
	if err := e.Start(":" + port); err != nil {
		log.Fatal(err)
	}
}
