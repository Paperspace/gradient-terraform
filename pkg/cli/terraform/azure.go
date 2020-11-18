package terraform

import "fmt"

type Azure struct {
	*Common
}

func NewAzure() *Azure {
	azure := Azure{
		Common: NewCommon(),
	}

	azure.TerraformSource = fmt.Sprintf("%s?ref=master/gradient-azure", SourcePrefix)
	return &azure
}
