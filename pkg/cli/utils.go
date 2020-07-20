package cli

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"regexp"
	"strings"
	"syscall"
	"text/tabwriter"

	"github.com/fatih/color"
)

var Name = "Gradient Installer"
var maxInterruptCount = 1

func Exec(cmd *exec.Cmd) error {
	if err := cmd.Start(); err != nil {
		return err
	}

	errChan := make(chan error, 1)
	signalChan := make(chan os.Signal, 0)

	signal.Notify(signalChan, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		errChan <- cmd.Wait()
	}()

	signalCount := 0
	for {
		select {
		case err := <-errChan:
			return err
		case _ = <-signalChan:
			signalCount = signalCount + 1
			if signalCount >= maxInterruptCount {
				signal.Reset()
			}
		}
	}
}

func PrintTable(headers []string, data [][]string) {
	tabWriter := tabwriter.NewWriter(os.Stdout, 2, 2, 4, ' ', 0)

	if len(headers) > 0 {
		fmt.Fprintln(tabWriter, strings.Join(headers, "\t"))
	}

	for _, row := range data {
		fmt.Fprintln(tabWriter, strings.Join(row, "\t"))
	}

	tabWriter.Flush()
}

func TextBold(text string) string {
	c := color.New(color.Bold)
	return c.SprintFunc()(text)
}

func TextError(text string) string {
	c := color.New(color.FgRed)
	return c.SprintFunc()(text)
}

func TextHeader(text string) string {
	boldText := TextBold(text)
	return fmt.Sprintf("=== %s", boldText)
}

func TextSuccess(text string) string {
	c := color.New(color.FgGreen)
	return TextBold(c.SprintFunc()(text))
}

func ValidateHostname(input string) error {
	validDomain := regexp.MustCompile(`^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$`)

	if valid := validDomain.Match([]byte(input)); valid == false {
		return errors.New("Invalid domain name")
	}

	return nil
}

func ValidateRequired(input string) error {
	if input == "" {
		return errors.New("Required")
	}

	return nil
}
