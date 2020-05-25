package terraform

type TerraformModules struct {
	AWS   *AWS   `json:"gradient_aws,omitempty"`
	Metal *Metal `json:"gradient_metal,omitempty"`
}
