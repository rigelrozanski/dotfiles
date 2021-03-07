package main

import (
	"errors"
	"fmt"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/rigelrozanski/common"
	"github.com/spf13/cobra"
)

// tools intended to be used with vim
var rootCmd = &cobra.Command{
	Use:   "vimrcgo",
	Short: "tools intended to be called from vim",
}

func init() {
	rootCmd.AddCommand(createTestCmd)
	rootCmd.AddCommand(debugPrintsCmd)
	rootCmd.AddCommand(removeDebugPrintsCmd)
	rootCmd.AddCommand(columnSpacesCmd)
	rootCmd.AddCommand(removeEveryOtherCmd)
	rootCmd.AddCommand(createNewXxx)
	rootCmd.AddCommand(createFunctionOf)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

var createTestCmd = &cobra.Command{
	Use:   "create-test [name] [source-file]",
	Short: "create a go-lang test shell in the correct file",
	Args:  cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {

		fnName := args[0]
		sourceFile := args[1]

		// construct the test file
		base := filepath.Base(sourceFile)
		name := strings.Split(base, ".")[0] + "_test.go"
		dir := filepath.Dir(sourceFile)
		testFile := path.Join(dir, name)

		testFnStr := fmt.Sprintf("\nfunc Test%v(t *testing.T) { \n\n}", fnName)

		var lines []string
		if common.FileExists(testFile) {
			var err error
			lines, err = common.ReadLines(testFile)
			if err != nil {
				return err
			}
			lines = append(lines, testFnStr)
		} else {
			sourceLines, err := common.ReadLines(sourceFile)
			if err != nil {
				return err
			}
			lines = []string{
				sourceLines[0], //package
				"\nimport \"testing\"",
				testFnStr,
			}
		}

		fmt.Println(testFile)
		return common.WriteLines(lines, testFile)
	},
}

var debugPrintsCmd = &cobra.Command{
	Use:   "debug-prints [name] [source-file] [lineno]",
	Short: "add prints to all the possible end points within a function",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {

		name := args[0]
		sourceFile := args[1]
		startLineNo, err := strconv.Atoi(args[2])
		if err != nil {
			return err
		}

		if !common.FileExists(sourceFile) {
			return errors.New("file don't exist")
		}

		lines, err := common.ReadLines(sourceFile)
		if err != nil {
			return err
		}
		lines = insertPrints(lines, startLineNo, name)

		err = common.WriteLines(lines, sourceFile)
		if err != nil {
			return err
		}
		return nil
	},
}

func insertPrints(lines []string, startLineNo int, name string) []string {

	debugNo := 0
	for i := startLineNo; i < len(lines); i++ {
		line := lines[i]
		if len(line) == 0 { // skip blank lines
			continue
		}
		if strings.HasPrefix(line, "}") { // reached the end of the function
			break
		}

		if strings.Contains(line, "}") || strings.Contains(line, "{") { // reached the end of the function

			outputStr := fmt.Sprintf("fmt.Println(\"wackydebugoutput %v %v\")", name, debugNo)
			debugNo++

			// insert the line
			lines = append(lines[:i+1], append([]string{outputStr}, lines[i+1:]...)...)
			i++ // skip a line
			continue
		}
	}

	return lines
}

var removeDebugPrintsCmd = &cobra.Command{
	Use:  "remove-debug-prints [source-file] [lineno]",
	Args: cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {

		sourceFile := args[0]
		startLineNo, err := strconv.Atoi(args[1])
		if err != nil {
			return err
		}

		if !common.FileExists(sourceFile) {
			return errors.New("file don't exist")
		}

		lines, err := common.ReadLines(sourceFile)
		if err != nil {
			return err
		}
		lines = removePrints(lines, startLineNo)

		err = common.WriteLines(lines, sourceFile)
		if err != nil {
			return err
		}
		return nil
	},
}

func removePrints(lines []string, startLineNo int) []string {
	for i := startLineNo; i < len(lines); i++ {
		line := lines[i]
		if strings.HasPrefix(line, "}") { // reached the end of the function
			break
		}

		// remove the line
		if strings.Contains(line, "wackydebugoutput") {
			lines = append(lines[:i], lines[i+1:]...)
		}
	}

	return lines
}

// helper function for visual mode vim commands
func loadFileVisualMode(args []string) (srcFile string, startLineNo, endLineNo int, lines []string, err error) {

	srcFile = args[0]
	startLineNo, err = strconv.Atoi(args[1])
	if err != nil {
		return
	}
	endLineNo, err = strconv.Atoi(args[2])
	if err != nil {
		return
	}
	if !common.FileExists(srcFile) {
		err = errors.New("file don't exist")
		return
	}
	lines, err = common.ReadLines(srcFile)
	if err != nil {
		return
	}

	return srcFile, startLineNo, endLineNo, lines, nil
}

var columnSpacesCmd = &cobra.Command{
	Use:   "column-width [source-file] [lineno-start] [lineno-end] [column-characters]",
	Short: "add spaces up to the column specified",
	Args:  cobra.ExactArgs(4),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile, startLineNo, endLineNo, lines, err := loadFileVisualMode(args)
		if err != nil {
			return err
		}

		columnChars, err := strconv.Atoi(args[3])
		if err != nil {
			return err
		}

		for i := startLineNo; i <= endLineNo; i++ {
			line := lines[i]
			len := len(line)
			if len >= columnChars {
				continue
			}
			for j := len; j <= columnChars; j++ {
				line += " "
			}
			lines[i] = line
		}
		//debugPrint := fmt.Sprintf("startLineNo: %v endLineNo: %v", startLineNo, endLineNo)
		//lines[startLineNo] += debugPrint

		err = common.WriteLines(lines, srcFile)
		if err != nil {
			return err
		}
		return nil
	},
}

// TODO complete
// remove the first line
var removeEveryOtherCmd = &cobra.Command{
	Use:   "remove-every-other [source-file] [lineno-start] [lineno-end]",
	Short: "remove every other line (starting with the first line",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile, startLineNo, endLineNo, lines, err := loadFileVisualMode(args)
		if err != nil {
			return err
		}

		var outLines []string
		if startLineNo > 0 {
			outLines = lines[:startLineNo]
		}

		makeEven := 0
		if startLineNo%2 == 0 {
			makeEven = 1
		}
		for i := startLineNo; i <= endLineNo; i++ {
			if (i+makeEven)%2 == 0 {
				outLines = append(outLines[:], lines[i])
			}
		}

		if endLineNo+1 < len(lines) {
			outLines = append(outLines[:], lines[endLineNo:]...)
		}

		//debugPrint := fmt.Sprintf(" hits: %v", out)
		//lines[startLineNo] += debugPrint

		err = common.WriteLines(outLines, srcFile)
		if err != nil {
			return err
		}
		return nil
	},
}

var createNewXxx = &cobra.Command{
	Use:   "create-new-xxx [source-file] [lineno-start] [lineno-end]",
	Short: "create a NewXxx function for the highlighted struct",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile, startLineNo, endLineNo, lines, err := loadFileVisualMode(args)
		if err != nil {
			return err
		}

		// get the function name
		split0 := strings.Split(lines[startLineNo], " ")
		var name string
		for i := 0; i < len(split0); i-- {
			if split0[i] == "type" && split0[i+2] == "struct" {
				name = split0[i+1]
				break
			}
		}

		// get the field names and types
		var fieldNames, fieldNamesLC, fieldTypes []string

		for i := startLineNo + 1; i <= endLineNo; i++ {
			spliti := strings.Fields(lines[i])

			var fieldName, fieldNameLC, fieldType string
			success := false
			for j := 0; j < len(spliti); j++ {
				word := spliti[j]
				if len(word) > 0 {
					if fieldName == "" {
						fieldName = word
						fieldNameLC = strings.ToLower(string(word[0])) + string(word[1:])
						continue
					}
					if fieldType == "" {
						fieldType = word
						success = true
						break
					}
				}
			}
			if success {
				fieldNamesLC = append(fieldNamesLC[:], fieldNameLC)
				fieldNames = append(fieldNames[:], fieldName)
				fieldTypes = append(fieldTypes[:], fieldType)
			}
		}

		// create the newXxx struct
		newXxx := []string{""}

		// comment above function
		newXxx = append(newXxx[:], fmt.Sprintf("// New%v creates a new %v object", name, name))

		// function header
		fnHead := fmt.Sprintf("func New%v(", name)
		for i := 0; i < len(fieldNamesLC); i++ {
			fnHead += fmt.Sprintf("%s %s, ", fieldNamesLC[i], fieldTypes[i])
		}
		fnHead = fmt.Sprintf("%v) %v {", fnHead[:len(fnHead)-2], name) // remove last comma, return arg

		newXxx = append(newXxx[:],
			fnHead,
			fmt.Sprintf("    return %v {", name)) // first line in function

		// type definition lines
		for i := 0; i < len(fieldNames); i++ {
			newline := fmt.Sprintf("        %s: %s, ", fieldNames[i], fieldNamesLC[i])
			newXxx = append(newXxx[:], newline)
		}

		// closing lines
		newXxx = append(newXxx[:], "    }", "}")

		// compile and save the final file
		var outLines []string
		outLines = append(outLines[:], lines[:endLineNo+1]...)
		outLines = append(outLines[:], newXxx...)
		outLines = append(outLines[:], lines[endLineNo+1:]...)
		err = common.WriteLines(outLines, srcFile)
		if err != nil {
			return err
		}
		return nil
	},
}

var createFunctionOf = &cobra.Command{
	Use:   "create-function-of [source-file] [lineno-start] [lineno-end]",
	Short: "create a function of a struct",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile, startLineNo, endLineNo, lines, err := loadFileVisualMode(args)
		if err != nil {
			return err
		}

		// get the function name
		split0 := strings.Split(lines[startLineNo], " ")
		var name string
		for i := 0; i < len(split0); i-- {
			if split0[i] == "type" && split0[i+2] == "struct" {
				name = split0[i+1]
				break
			}
		}

		// get an abbreviation text
		abbr := strings.ToLower(string(name[0]))

		// create the function text
		funcText := []string{"", "// TODO",
			fmt.Sprintf("func (%v %v)FuncName() {", abbr, name),
			"",
			"}",
		}

		// compile and save the final file
		var outLines []string
		outLines = append(outLines[:], lines[:endLineNo+1]...)
		outLines = append(outLines[:], funcText...)
		outLines = append(outLines[:], lines[endLineNo+1:]...)
		err = common.WriteLines(outLines, srcFile)
		if err != nil {
			return err
		}
		return nil
	},
}
