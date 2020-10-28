package clusters

import (
	"fmt"
	"os"

	"github.com/Paperspace/gradient-installer/pkg/cli"
	"github.com/Paperspace/gradient-installer/pkg/cli/terraform"
	"github.com/Paperspace/paperspace-go"
	"github.com/manifoldco/promptui"
	"github.com/spf13/cobra"
	"gopkg.in/yaml.v2"
)

const (
	InClusterContainerRegistryOption  = "Install on cluster"
	ThirdPartyContainerRegistryOption = "Use 3rd Party"
	NoContainerRegistry               = "No container registry"
)

func ClusterRegister(client *paperspace.Client, createFilePath string) (string, error) {
	var cluster paperspace.Cluster
	var params paperspace.ClusterCreateParams
	var region string

	client.CreateCluster(paperspace.ClusterCreateParams{})
	if createFilePath == "" {
		awsRegionSelect := promptui.Select{
			Label: "AWS Region",
			Items: paperspace.ClusterAWSRegions,
		}
		artifactsAccessKeyIDPrompt := cli.Prompt{
			Label:    "Artifacts S3 Access Key ID",
			Required: true,
		}
		artifactsBucketPathPrompt := cli.Prompt{
			Label:    "Artifacts S3 Bucket",
			Required: true,
		}
		artifactsSecretAccessKeyPrompt := cli.Prompt{
			Label:    "Artifacts S3 Secret Access Key",
			Required: true,
			UseMask:  true,
		}
		domainPrompt := cli.Prompt{
			Label:    "Domain (gradient.mycompany.com)",
			Required: true,
		}
		namePrompt := cli.Prompt{
			Label:    "Name",
			Required: true,
		}
		platformSelect := promptui.Select{
			Label: "Platform",
			Items: terraform.SupportedClusterPlatformTypes,
		}
		useContainerRegistrySelect := promptui.Select{
			Label: "Container Registry, used for storing notebook snapshots and container builds",
			Items: []string{ThirdPartyContainerRegistryOption, NoContainerRegistry},
		}
		containerRegistryURLPrompt := cli.Prompt{
			Label:    "Container Registry Username",
			Required: true,
		}
		containerRegistryRepositoryPrompt := cli.Prompt{
			Label:    "Container Registry Username",
			Required: true,
		}
		containerRegistryUsernamePrompt := cli.Prompt{
			Label:    "Container Registry Username",
			Required: true,
		}
		containerRegistryPasswordPrompt := cli.Prompt{
			Label:    "Container Registry Username",
			Required: true,
			UseMask:  true,
		}

		println(cli.TextHeader("Register a private cluster"))
		if err := namePrompt.Run(); err != nil {
			return "", err
		}
		if err := domainPrompt.Run(); err != nil {
			return "", err
		}

		_, platform, err := platformSelect.Run()
		if err != nil {
			return "", err
		}
		if platform == string(paperspace.ClusterPlatformAWS) {
			_, region, err = awsRegionSelect.Run()
			if err != nil {
				return "", err
			}
		}

		if err := artifactsBucketPathPrompt.Run(); err != nil {
			return "", err
		}
		if err := artifactsAccessKeyIDPrompt.Run(); err != nil {
			return "", err
		}
		if err := artifactsSecretAccessKeyPrompt.Run(); err != nil {
			return "", err
		}

		_, useContainerRegistry, err := useContainerRegistrySelect.Run()
		if err != nil {
			return "", err
		}
		if string(useContainerRegistry) == ThirdPartyContainerRegistryOption {
			if err := containerRegistryURLPrompt.Run(); err != nil {
				return "", err
			}
			if err := containerRegistryRepositoryPrompt.Run(); err != nil {
				return "", err
			}
			if err := containerRegistryUsernamePrompt.Run(); err != nil {
				return "", err
			}
			if err := containerRegistryPasswordPrompt.Run(); err != nil {
				return "", err
			}
		}

		params = paperspace.ClusterCreateParams{
			ArtifactsAccessKeyID:        artifactsAccessKeyIDPrompt.Value,
			ArtifactsBucketPath:         artifactsBucketPathPrompt.Value,
			ArtifactsSecretAccessKey:    artifactsSecretAccessKeyPrompt.Value,
			Domain:                      domainPrompt.Value,
			Name:                        namePrompt.Value,
			Platform:                    platform,
			Region:                      region,
			ContainerRegistryURL:        containerRegistryURLPrompt.Value,
			ContainerRegistryRepository: containerRegistryRepositoryPrompt.Value,
			ContainerRegistryUsername:   containerRegistryUsernamePrompt.Value,
			ContainerRegistryPassword:   containerRegistryPasswordPrompt.Value,
		}
	} else {
		createFile, err := os.Open(createFilePath)
		defer createFile.Close()
		if err != nil {
			return "", err
		}

		decoder := yaml.NewDecoder(createFile)
		err = decoder.Decode(&params)
		if err != nil {
			return "", err
		}
	}
	cluster, err := client.CreateCluster(params)
	if err != nil {
		return "", err
	}

	println(fmt.Sprintf("Cluster created with ID: %s", cluster.ID))
	println(fmt.Sprintf("Cluster API key: %s", cluster.APIToken.Key))

	return cluster.ID, nil
}

func NewClusterRegisterCommand() *cobra.Command {
	var createFilePath string

	command := cobra.Command{
		Use:   "register",
		Short: "Register a new private cluster",
		RunE: func(cmd *cobra.Command, args []string) error {
			client := cli.FromContext(cmd)
			_, err := ClusterRegister(client, createFilePath)
			if err != nil {
				return err
			}
			return nil
		},
	}
	command.Flags().StringVarP(&createFilePath, "file", "f", "", "YAML file to create a cluster")

	return &command
}
