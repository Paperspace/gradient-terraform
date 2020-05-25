package terraform

type TerraformOutput struct {
	Value string `json:"value"`
}

type TerraformOutputs struct {
	DNSCName *TerraformOutput `json:"dns_cname,omitempty"`
}
