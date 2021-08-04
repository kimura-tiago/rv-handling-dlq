package main

import (
	"log"
	"time"

	"github.com/kelseyhightower/envconfig"
)

type config struct {
	DateToSkip    time.Time `envconfig:"SKIP_DATE" required:"true"`
	RequeueSQSURL string    `envconfig:"REQUEUE_SQS_URL" required:"true"`
}

func newConfig() config {
	cfg := &config{}
	if err := envconfig.Process("", cfg); err != nil {
		log.Fatal(err)
	}
	return *cfg
}
