package terraform

type TerraformProvider struct {
	Backends *TerraformProviderBackends `json:"backend"`
}

type TerraformProviderBackends struct {
	S3 *S3Backend `json:"s3,omitempty"`
}

func NewTerraformProvider() *TerraformProvider {
	return &TerraformProvider{
		Backends: NewTerraformProviderBackends(),
	}
}

func NewTerraformProviderBackends() *TerraformProviderBackends {
	return &TerraformProviderBackends{
		S3: NewS3Backend(),
	}
}
