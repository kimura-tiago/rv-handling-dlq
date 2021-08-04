package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/getzoop/rv-handling-dlq/reprocess"
)

func main() {

	cfg := newConfig()

	sess, err := session.NewSession(&aws.Config{})
	if err != nil {
		panic(err)
	}

	sqsClient := sqs.New(sess)
	service := reprocess.NewService(sqsClient, cfg.RequeueSQSURL)
	lambda.Start(requeueRecordsHandler(service, cfg.DateToSkip))
}
