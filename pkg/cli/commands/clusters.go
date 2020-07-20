package commands

import (
	"github.com/paperspace/gradient-installer/pkg/cli/commands/clusters"
	"github.com/spf13/cobra"
)

func NewClusterCommand() *cobra.Command {
	command := cobra.Command{
		Use:   "clusters",
		Short: "Manage private clusters",
	}
	command.AddCommand(clusters.NewClusterDownCommand())
	command.AddCommand(clusters.NewClusterListCommand())
	command.AddCommand(clusters.NewClusterUpCommand())

	return &command
}
