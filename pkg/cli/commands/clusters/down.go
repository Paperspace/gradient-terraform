package clusters

import (
	"path/filepath"

	"github.com/paperspace/gradient-installer/pkg/cli"
	"github.com/paperspace/gradient-installer/pkg/cli/config"
	"github.com/paperspace/gradient-installer/pkg/cli/terraform"
	"github.com/spf13/cobra"
)

func NewClusterDownCommand() *cobra.Command {
	var autoApprove bool

	command := cobra.Command{
		Use:   "down [CLUSTER_ID]",
		Args:  cobra.MaximumNArgs(1),
		Short: "Tear down cluster",
		RunE: func(cmd *cobra.Command, args []string) error {
			var id string

			// Prepare args
			if len(args) > 0 {
				id = args[0]
			} else {
				NewClusterRegisterCommand().Execute()
			}

			terraformDir := filepath.Join("clusters", id)

			configPath, err := config.ConfigPath(terraformDir, TerraformTFName)
			if err != nil {
				return err
			}

			println(cli.TextHeader("Running terraform destroy"))
			if err := terraform.InitCommand(filepath.Dir(configPath)); err != nil {
				return err
			}

			if err := terraform.DestroyCommand(filepath.Dir(configPath), autoApprove); err != nil {
				return err
			}

			return nil
		},
	}
	command.PersistentFlags().BoolVarP(&autoApprove, "auto-approve", "a", false, "")

	return &command
}
