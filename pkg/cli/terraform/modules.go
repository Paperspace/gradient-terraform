package terraform

type TerraformModules struct {
	AWS   *AWS   `json:"gradient_aws,omitempty"`
	Azure *Azure `json:"gradient_azure,omitempty"`
	GCP   *GCP   `json:"gradient_gcp,omitempty"`
	Metal *Metal `json:"gradient_metal,omitempty"`
}
