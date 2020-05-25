package config

import (
	"os"

	"github.com/paperspace/paperspace-go"
)

type Profile struct {
	APIKey    string `json:"apiKey,omitempty"`
	BaseURL   string `json:"baseURL,omitempty"`
	Debug     bool   `json:"debug,omitempty"`
	DebugBody bool   `json:"debugBody,omitempty"`
}

func NewProfile() *Profile {
	return &Profile{}
}

func (p *Profile) NewPaperspaceClient() *paperspace.Client {
	apiBackend := paperspace.NewAPIBackend()
	if p.BaseURL != "" {
		apiBackend.BaseURL = p.BaseURL
	}
	if os.Getenv("PAPERSPACE_BASEURL") != "" {
		apiBackend.BaseURL = os.Getenv("PAPERSPACE_BASEURL")
	}

	apiBackend.Debug = p.Debug
	if os.Getenv("PAPERSPACE_DEBUG") != "" {
		apiBackend.Debug = true
	}

	apiBackend.DebugBody = p.DebugBody
	if os.Getenv("PAPERSPACE_DEBUG_BODY") != "" {
		apiBackend.DebugBody = true
	}

	client := paperspace.NewClientWithBackend(paperspace.Backend(apiBackend))
	client.APIKey = p.APIKey

	return client
}
