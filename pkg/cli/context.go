package cli

import (
	"context"
	"os"

	"github.com/paperspace/paperspace-go"
	"github.com/spf13/cobra"
)

var paperspaceContextKey = "paperspace"

func NewContext(client *paperspace.Client) context.Context {
	ctx := context.Background()
	return context.WithValue(ctx, paperspaceContextKey, client)
}

func FromContext(cmd *cobra.Command) *paperspace.Client {
	ctx := cmd.Context()
	client, ok := ctx.Value(paperspaceContextKey).(*paperspace.Client)

	if !ok {
		println(TextError("Could not create Paperspace Client, this is an error, please file a bug"))
		os.Exit(1)
		return nil
	}

	return client
}
