package main

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/rv-handling-dlq/reprocess"
)

type handlerFunc func(context.Context, events.SQSEvent)

func requeueRecordsHandler(service reprocess.Service, timeThreshold time.Time) handlerFunc {
	return func(ctx context.Context, sqsEvent events.SQSEvent) {

		for _, item := range sqsEvent.Records {
			timeOfMessage := item.Attributes["SentTimestamp"][:len(item.Attributes["SentTimestamp"])-3]
			i, err := strconv.ParseInt(timeOfMessage, 10, 64)
			if err != nil {
				panic(err)
			}
			tm := time.Unix(i, 0)
			if timeThreshold.Before(tm) {
				fmt.Println("message -> ", time.Now(), item.Body)
				continue
			}
			service.SendToTokenizedQueue([]byte(item.Body))
		}

	}
}
