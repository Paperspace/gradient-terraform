package config

var DefaultProfileName = "default"

type CliConfig struct {
	Profiles map[string]*Profile `json:"profiles,omitempty"`
}

func NewCliConfig() *CliConfig {
	return &CliConfig{
		Profiles: make(map[string]*Profile),
	}
}

func (c *CliConfig) CreateOrGetProfile(profileName string) *Profile {
	if !c.HasProfile(profileName) {
		c.Profiles[profileName] = NewProfile()
	}

	return c.Profiles[profileName]
}

func (c *CliConfig) HasProfile(profileName string) bool {
	if _, ok := c.Profiles[profileName]; !ok {
		return false
	}

	return true
}
