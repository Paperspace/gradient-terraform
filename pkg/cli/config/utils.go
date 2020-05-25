package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

func ConfigDirectory() (string, error) {
	userConfigDir, err := os.UserConfigDir()
	if err != nil {
		return "", err
	}

	return filepath.Join(userConfigDir, "paperspace"), nil
}

func ConfigPath(prefix, name string) (string, error) {
	configDir, err := ConfigDirectory()
	if err != nil {
		return "", err
	}

	return filepath.Join(configDir, prefix, fmt.Sprintf("%s.json", name)), nil
}

func ConfigPathExists(prefix, name string) (bool, error) {
	configPath, err := ConfigPath(prefix, name)
	if err != nil {
		return false, err
	}

	if _, err := os.Stat(configPath); err != nil {
		if os.IsNotExist(err) {
			return false, nil
		}

		return false, err
	}

	return true, nil
}

func LoadConfig(prefix, name string, v interface{}) error {
	configPath, err := ConfigPath(prefix, name)
	if err != nil {
		return err
	}

	configFile, err := os.Open(configPath)
	defer configFile.Close()
	if err != nil {
		return err
	}
	decoder := json.NewDecoder(configFile)
	if err := decoder.Decode(v); err != nil {
		return err
	}

	return nil
}

func LoadConfigIfExists(prefix, name string, v interface{}) error {
	exists, err := ConfigPathExists(prefix, name)
	if err != nil {
		return err
	}

	if exists {
		err := LoadConfig(prefix, name, v)
		if err != nil {
			return err
		}

	}

	return nil
}

func WriteConfig(prefix, name string, v interface{}) error {
	configPath, err := ConfigPath(prefix, name)
	if err != nil {
		return err
	}

	if err := os.MkdirAll(filepath.Dir(configPath), 0700); err != nil {
		return err
	}

	configFile, err := os.Create(configPath)
	defer configFile.Close()
	if err != nil {
		return err
	}

	encoder := json.NewEncoder(configFile)
	encoder.SetIndent("", "    ")
	if err := encoder.Encode(v); err != nil {
		return err
	}

	return nil
}
