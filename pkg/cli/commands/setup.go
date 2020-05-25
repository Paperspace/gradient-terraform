package commands

import (
	"github.com/paperspace/gradient-installer/pkg/cli"
	"github.com/paperspace/gradient-installer/pkg/cli/config"
	"github.com/paperspace/gradient-installer/pkg/cli/terraform"
	"github.com/spf13/cobra"
)

func NewSetupCommand(profileName string) *cobra.Command {
	var withTerraform bool

	command := cobra.Command{
		Use:   "setup",
		Short: "Setup",
		RunE: func(cmd *cobra.Command, args []string) error {
			cliConfig := config.NewCliConfig()
			if err := config.LoadConfigIfExists("", "config", &cliConfig); err != nil {
				return err
			}
			profile := cliConfig.CreateOrGetProfile(profileName)

			prompt := cli.Prompt{
				Label:          "Paperspace API Key",
				Required:       true,
				UseMask:        true,
				MaskShowLength: 4,
				Value:          profile.APIKey,
			}

			println(cli.TextHeader("Setup Gradient Installer CLI, for a Paperspace API key visit: https://console.paperspace.com"))
			if err := prompt.Run(); err != nil {
				return err
			}

			profile.APIKey = prompt.Value

			if err := config.WriteConfig("", "config", &cliConfig); err != nil {
				return err
			}

			if withTerraform {
				if err := terraform.InstallCommand(true); err != nil {
					return err
				}

			}

			println("")
			println(cli.TextSuccess("Setup complete!"))

			return nil
		},
	}
	command.PersistentFlags().BoolVarP(&withTerraform, "with-terraform", "t", false, "Install Terraform dependencies")

	return &command
}
