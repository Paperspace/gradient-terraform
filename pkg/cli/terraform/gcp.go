package terraform

import "fmt"

type GCP struct {
	*Common
}

func NewGCP() *GCP {
	gcp := GCP{
		Common: NewCommon(),
	}

	gcp.TerraformSource = fmt.Sprintf("%s?ref=master/gradient-gcp", SourcePrefix)
	return &gcp
}
