package clusters

import (
	"github.com/paperspace/gradient-installer/pkg/cli"
	"github.com/paperspace/paperspace-go"
	"github.com/spf13/cobra"
)

func NewClusterListCommand() *cobra.Command {
	command := cobra.Command{
		Use:   "list",
		Short: "List clusters",
		RunE: func(cmd *cobra.Command, args []string) error {
			client := cli.FromContext(cmd)
			clusters, err := client.GetClusters(paperspace.NewClusterListParams())
			if err != nil {
				return err
			}

			if len(clusters) == 0 {
				println("You have no private clusters")
				return nil
			}

			println(cli.TextHeader("Private clusters"))
			data := [][]string{}
			for _, cluster := range clusters {
				data = append(data, []string{cluster.Name, cluster.ID})
			}

			cli.PrintTable(nil, data)
			return nil
		},
	}

	return &command
}
