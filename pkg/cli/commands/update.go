package commands

import (
	"context"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"runtime"

	"github.com/google/go-github/v32/github"
	"github.com/paperspace/gradient-installer/pkg/cli"
	"github.com/spf13/cobra"
)

func NewUpdateCommand() *cobra.Command {
	command := cobra.Command{
		Use:   "update",
		Short: "Update CLI to latest release",
		RunE: func(cmd *cobra.Command, args []string) error {
			var releaseAsset *github.ReleaseAsset
			var latestRelease *github.RepositoryRelease

			githubClient := github.NewClient(nil)
			ctx := context.TODO()

			// Get releases
			releases, _, err := githubClient.Repositories.ListReleases(ctx, "paperspace", "gradient-installer", nil)
			if err != nil {
				return err
			}

			if len(releases) == 0 {
				return fmt.Errorf("Could not find latest release")
			}

			// Get latest release
			for _, release := range releases {
				if *release.Prerelease {
					continue
				}

				valid, err := regexp.MatchString(`^v\d+\.\d+\.\d+$`, *release.TagName)
				if err != nil {
					return err
				}
				if !valid {
					continue
				}

				latestRelease = release
				break
			}

			if latestRelease == nil {
				return fmt.Errorf("Could not find latest release")
			}

			// Check if current version is latest
			if *latestRelease.TagName == version {
				println(cli.TextSuccess("All up to date!"))

				return nil
			}

			// Check for matching OS release assets
			for _, asset := range latestRelease.Assets {
				if *asset.Name == fmt.Sprintf("%s-%s", commandName, runtime.GOOS) {
					releaseAsset = asset
					break
				}
			}

			if releaseAsset == nil {
				return fmt.Errorf("Could not find latest release asset")
			}

			// Download latest OS asset
			resp, err := http.Get(*releaseAsset.URL)
			if err != nil {
				return err
			}

			// Write latest OS asset to disk
			tempFile, err := ioutil.TempFile(os.TempDir(), commandName)
			if err != nil {
				return err
			}
			defer tempFile.Close()

			if _, err := io.Copy(tempFile, resp.Body); err != nil {
				return err
			}
			tempFile.Close()

			// Move current executable to tmp directory
			currentPath, err := os.Executable()
			if err != nil {
				return err
			}

			oldPath := filepath.Join(os.TempDir(), fmt.Sprintf("%s-old", commandName))
			if err := os.Rename(currentPath, oldPath); err != nil {
				return err
			}

			// Move new executable to existing location
			if err := os.Rename(tempFile.Name(), currentPath); err != nil {
				return err
			}

			println(cli.TextSuccess("All up to date!"))

			return nil
		},
	}

	return &command
}
