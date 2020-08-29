package cli

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

var YesNoValues = []string{"yes", "no"}
var maskChar = '*'

type Prompt struct {
	AllowedValues  []string
	HideValue      bool
	Label          string
	MaskShowLength int
	MaxLength      int
	Required       bool
	UseMask        bool
	Value          string
}

func BoolToYesNo(value bool) string {
	if value {
		return "yes"
	}

	return "no"
}

func YesNoToBool(value string) bool {
	if value == "yes" {
		return true
	}

	return false
}

func (p *Prompt) MaskValue(value string) string {
	valueLen := len(value) - p.MaskShowLength
	if valueLen < 1 {
		valueLen = len(value)
	}

	maskValue := []rune(value)
	for i := 0; i < valueLen; i++ {
		maskValue[i] = maskChar
	}

	return string(maskValue)
}

func (p *Prompt) Run() error {
	displayValue := p.Value

	if p.UseMask {
		displayValue = p.MaskValue(displayValue)
	}

	promptTextParts := []string{p.Label}
	if displayValue == "" {
		displayValue = "None"
	}

	if !p.HideValue {
		promptTextParts = append(promptTextParts, fmt.Sprintf("[%s]", displayValue))
	}

	for {
		fmt.Printf("%s: ", strings.Join(promptTextParts, " "))

		reader := bufio.NewReader(os.Stdin)
		value, err := reader.ReadString('\n')
		if err != nil {
			return err
		}
		value = strings.TrimSuffix(value, "\n")
		if value != "" {
			p.Value = value
		}

		if len(p.AllowedValues) > 0 {
			validValue := false
			for _, allowedValue := range p.AllowedValues {
				if p.Value == allowedValue {
					validValue = true
					break
				}
			}
			if !validValue {
				fmt.Printf("Invalid value, allowed values: %s \n\n", strings.Join(p.AllowedValues, ", "))
				continue
			}
		}

		if p.Value != "" || !p.Required {
			break
		}
	}

	return nil
}
