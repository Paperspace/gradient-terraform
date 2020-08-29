package terraform

import (
	"archive/zip"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"

	"github.com/paperspace/gradient-installer/pkg/cli"
	"github.com/paperspace/gradient-installer/pkg/cli/config"
)

var setupURL = "https://raw.githubusercontent.com/Paperspace/gradient-installer/master/bin/setup"
var terraformURLPrefix = "https://releases.hashicorp.com/terraform"
var terraformVersion = "0.13.1"

func ApplyCommand(configDir string, autoApprove bool) error {
	if err := InstallCommand(false); err != nil {
		return err
	}

	terraformPath, err := terraformCommandPath()
	if err != nil {
		return err
	}

	cmd := exec.Command(terraformPath, "apply")
	cmd.Dir = configDir

	if autoApprove {
		cmd.Args = append(cmd.Args, "-auto-approve")
	}
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout

	return cli.Exec(cmd)
}

func DestroyCommand(configDir string, autoApprove bool) error {
	if err := InstallCommand(false); err != nil {
		return err
	}

	terraformPath, err := terraformCommandPath()
	if err != nil {
		return err
	}

	cmd := exec.Command(terraformPath, "destroy")
	cmd.Dir = configDir
	if autoApprove {
		cmd.Args = append(cmd.Args, "-auto-approve")
	}
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout

	return cli.Exec(cmd)
}

func InitCommand(configDir string) error {
	if err := InstallCommand(false); err != nil {
		return err
	}

	terraformPath, err := terraformCommandPath()
	if err != nil {
		return err
	}

	cmd := exec.Command(terraformPath, "init")
	cmd.Dir = configDir

	if err := os.Remove(filepath.Join(configDir, ".terraform", "terraform.tfstate")); err != nil {
		return err
	}

	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout

	return cli.Exec(cmd)
}

func InstallCommand(force bool) error {
	if err := installSetup(force); err != nil {
		return err
	}

	if err := installTerraform(force); err != nil {
		return err
	}

	return nil
}

func SetupCommand() error {
	setupPath, err := setupCommandPath()
	if err != nil {
		return err
	}

	cmd := exec.Command(setupPath)
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout

	return cli.Exec(cmd)
}

func setupCommandPath() (string, error) {
	configDir, err := config.ConfigDirectory()
	if err != nil {
		return "", err
	}

	binDir := filepath.Join(configDir, "bin")
	if err := os.MkdirAll(binDir, 0700); err != nil {
		return "", err
	}

	return filepath.Join(binDir, "setup"), nil
}

func terraformCommandPath() (string, error) {
	configDir, err := config.ConfigDirectory()
	if err != nil {
		return "", err
	}

	binDir := filepath.Join(configDir, "bin")
	if err := os.MkdirAll(binDir, 0700); err != nil {
		return "", err
	}

	return filepath.Join(binDir, "terraform"), nil
}

func installSetup(force bool) error {
	setupPath, err := setupCommandPath()
	if err != nil {
		return err
	}

	if !force {
		if _, err := os.Stat(setupPath); !os.IsNotExist(err) {
			return nil
		}
	}

	resp, err := http.Get(setupURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	setupFile, err := os.Create(setupPath)
	if err != nil {
		return err
	}
	defer setupFile.Close()
	setupFile.Chmod(0700)

	if _, err := io.Copy(setupFile, resp.Body); err != nil {
		return err
	}

	setupFile.Close()
	return SetupCommand()
}

func installTerraform(force bool) error {
	var terraformOS string

	terraformPath, err := terraformCommandPath()
	if err != nil {
		return err
	}

	if !force {
		if _, err := os.Stat(terraformPath); !os.IsNotExist(err) {
			return nil
		}
	}

	switch runtime.GOOS {
	case "linux":
		terraformOS = "linux_amd64"
	case "darwin":
		terraformOS = "darwin_amd64"
	default:
		return fmt.Errorf("%s is not currently supported", runtime.GOOS)
	}

	terraformURL := fmt.Sprintf("%s/%s/terraform_%s_%s.zip", terraformURLPrefix, terraformVersion, terraformVersion, terraformOS)
	resp, err := http.Get(terraformURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	terraformFile, err := os.Create(terraformPath)
	if err != nil {
		return err
	}
	defer terraformFile.Close()
	terraformFile.Chmod(0700)

	buffer, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	bufioReader := bytes.NewReader(buffer)
	zipReader, err := zip.NewReader(bufioReader, bufioReader.Size())
	if err != nil {
		return err
	}

	for _, zipFile := range zipReader.File {
		if zipFile.Name != "terraform" {
			continue
		}

		file, err := zipFile.Open()
		if err != nil {
			return err
		}
		defer file.Close()

		_, err = io.Copy(terraformFile, file)
		if err != nil {
			return err
		}

		return nil
	}

	return fmt.Errorf("Could not unzip terraform from zip")
}
