package main

import (
	"strings"
	"testing"

	"github.com/magiconair/properties/assert"
)

func TestInsertRemovePrints(t *testing.T) {
	testLines := `
func debugPrintsCmd(cmd *cobra.Command, args []string) error {
	if !common.FileExists(testFile) {
		return errors.New("file don't exist")
	}
}

func insertPrints(lines []string, startLineNo int) []string {
	debugNo := 0
	for i := startLineNo; i < len(lines); i++ {
		line := lines[i]
		if len(line) == 0 { // skip blank lines
			continue
		}
		if line[0] == "}" { // reached the end of the function
			break
		}
	}
	return lines
}

func debugPrintsCmd(cmd *cobra.Command, args []string) error {
	if !common.FileExists(testFile) {
		return errors.New("file don't exist")
	}
}
`

	expOutlines := `
func debugPrintsCmd(cmd *cobra.Command, args []string) error {
	if !common.FileExists(testFile) {
		return errors.New("file don't exist")
	}
}

func insertPrints(lines []string, startLineNo int) []string {
fmt.Println("wackydebugoutput hoot 0")
	debugNo := 0
	for i := startLineNo; i < len(lines); i++ {
fmt.Println("wackydebugoutput hoot 1")
		line := lines[i]
		if len(line) == 0 { // skip blank lines
fmt.Println("wackydebugoutput hoot 2")
			continue
		}
fmt.Println("wackydebugoutput hoot 3")
		if line[0] == "}" { // reached the end of the function
fmt.Println("wackydebugoutput hoot 4")
			break
		}
fmt.Println("wackydebugoutput hoot 5")
	}
fmt.Println("wackydebugoutput hoot 6")
	return lines
}

func debugPrintsCmd(cmd *cobra.Command, args []string) error {
	if !common.FileExists(testFile) {
		return errors.New("file don't exist")
	}
}
`
	testLinesSplit := strings.Split(testLines, "\n")
	outlinesSplit := insertPrints(testLinesSplit, 7, "hoot")
	outlines := strings.Join(outlinesSplit, "\n")
	assert.Equal(t, expOutlines, outlines, "\n\n\ngot:\n"+outlines+"\nexp:\n"+expOutlines+"\n")

	outlinesSplit = removePrints(outlinesSplit, 7)
	outlines = strings.Join(outlinesSplit, "\n")
	assert.Equal(t, testLines, outlines, "\n\n\ngot:\n"+outlines+"\nexp:\n"+testLines+"\n")
}
