package main

import (
	"fmt"
	"strings"
	"unicode"

	"github.com/spf13/cobra"
)

var snakeToUpperCamel = &cobra.Command{
	Use:  "snake-to-upper-camel [input-word]",
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return SnakeToCamel(args[0], strings.ToUpper)
	},
}

var snakeToCamel = &cobra.Command{
	Use:  "snake-to-camel [input-word]",
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return SnakeToCamel(args[0], strings.ToLower)
	},
}

func SnakeToCamel(wordIn string, caseChangeFn func(string) string) error {

	chs := []rune(wordIn)
	if len(chs) < 2 {
		_, err := fmt.Print(strings.ToUpper(wordIn))
		return err
	}

	words := []string{""}
	prevLetterIsUpper := false
	currLetterIsUpper := false
	nextLetterIsUpper := false
	for i, letter := range chs {
		if i >= len(chs)-1 {
			nextLetterIsUpper = false
		} else {
			nextLetterIsUpper = unicode.IsUpper(chs[i+1])
		}
		currLetterIsUpper = unicode.IsUpper(letter)

		switch {
		case i == 0: // first letter always goes into the first word
			words[len(words)-1] += string(letter)
		case !currLetterIsUpper:
			words[len(words)-1] += string(letter)
		case !prevLetterIsUpper && currLetterIsUpper:
			words = append(words, string(letter))
		case prevLetterIsUpper && currLetterIsUpper && nextLetterIsUpper:
			words[len(words)-1] += string(letter)
		case prevLetterIsUpper && currLetterIsUpper && !nextLetterIsUpper:
			words = append(words, string(letter))
		}

		// shift perspective
		prevLetterIsUpper = currLetterIsUpper
		currLetterIsUpper = nextLetterIsUpper
	}

	// convert word casing
	wordsCaseUpdated := []string{}
	for _, word := range words {
		wordsCaseUpdated = append(wordsCaseUpdated, caseChangeFn(word))
	}

	combineToCamel := strings.Join(wordsCaseUpdated, "_")
	_, err := fmt.Print(combineToCamel)
	return err
}
