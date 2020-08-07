package main

import (
	"os"

	"github.com/paperspace/gradient-installer/pkg/cli"
	"github.com/paperspace/gradient-installer/pkg/cli/commands"
	"github.com/paperspace/gradient-installer/pkg/cli/config"
)

func main() {
	cliConfig := config.NewCliConfig()

	profileName := os.Getenv("PAPERSPACE_PROFILE")
	if profileName == "" {
		profileName = config.DefaultProfileName
	}

	configPathExists, err := config.ConfigPathExists("", "config")
	if err != nil {
		println(cli.TextError(err.Error()))
		os.Exit(1)
	}
	if !configPathExists {
		commands.NewSetupCommand(profileName).Execute()
		println("")
	}
	if err := config.LoadConfigIfExists("", "config", &cliConfig); err != nil {
		println(cli.TextError(err.Error()))
		os.Exit(1)
	}

	profile := cliConfig.CreateOrGetProfile(profileName)

	ctx := cli.NewContext(profile.NewPaperspaceClient())
	rootCommand := commands.NewRootCommand(profileName)
	if err := rootCommand.ExecuteContext(ctx); err != nil {
		println(cli.TextError(err.Error()))
		os.Exit(1)
	}
}
