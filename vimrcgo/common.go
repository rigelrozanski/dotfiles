package main

import (
	"strings"
	"unicode"
)

func capitalizedWord(word string) (capitalized string) {
	switch len(word) {
	case 0:
		return ""
	case 1:
		capitalized = strings.ToUpper(string(word[0]))
	default:
		capitalized = strings.ToUpper(string(word[0])) + string(word[1:])
	}
	return capitalized
}

func lowerCasedWord(word string) (lowerCased string) {
	switch len(word) {
	case 0:
		return ""
	case 1:
		lowerCased = strings.ToLower(string(word[0]))
	default:
		lowerCased = strings.ToLower(string(word[0])) + string(word[1:])
	}
	return lowerCased
}

func camelcaseToAbbreviation(camel string) (abbr string) {
	if len(camel) == 0 {
		return ""
	}

	abbr = strings.ToLower(string(camel[0])) // always include the first letter

	remainingRunes := []rune(camel[1:])
	for _, r := range remainingRunes {
		if unicode.IsUpper(r) {
			abbr += strings.ToLower(string(r))
		}
	}
	return abbr
}
