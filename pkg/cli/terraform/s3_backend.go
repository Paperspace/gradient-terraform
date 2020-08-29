package terraform

import "path"

type S3Backend struct {
	AccessKeyID     string `json:"access_key,omitempty"`
	Bucket          string `json:"bucket"`
	Endpoint        string `json:"endpoint,omitempty"`
	Key             string `json:"key"`
	Region          string `json:"region"`
	SecretAccessKey string `json:"secret_key,omitempty"`
	SessionName     string `json:"session_name"`
}

func NewS3Backend() *S3Backend {
	return &S3Backend{
		Region:      "us-east-1",
		SessionName: "gradient-installer",
	}
}

func (s *S3Backend) UpdatePath(prefix string) {
	s.Key = path.Join(prefix, "gradient-processing")
}
