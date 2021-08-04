package reprocess

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sqs"
)

// ServiceImpl implements tokenization service interface
type ServiceImpl struct {
	sqs                  sqsAPIClient
	tokenizationQueueURL string
}

// NewService returns a service implementation
func NewService(sqs sqsAPIClient, tokenizationQueueURL string) Service {
	svc := ServiceImpl{
		sqs:                  sqs,
		tokenizationQueueURL: tokenizationQueueURL,
	}

	return svc
}

type sqsAPIClient interface {
	SendMessage(*sqs.SendMessageInput) (*sqs.SendMessageOutput, error)
}

// Service is an interface that represents the tokenizetion process
type Service interface {
	SendToTokenizedQueue(event []byte) error
}

// SendToTokenizedQueue ...
func (s ServiceImpl) SendToTokenizedQueue(event []byte) error {

	_, err := s.sqs.SendMessage(&sqs.SendMessageInput{
		MessageBody: aws.String(string(event)),
		QueueUrl:    aws.String(s.tokenizationQueueURL),
	})

	return err
}
