package main

import (
	"errors"
	"fmt"
	"path"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/rigelrozanski/common"
	"github.com/rigelrozanski/common/parse"
	"github.com/spf13/cobra"
)

var createTestCmd = &cobra.Command{
	Use:   "create-test [name] [source-file]",
	Short: "create a (golang/rust) test for the [name], returns new file to open and line no",
	Args:  cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		fnName := args[0]
		sourceFile := args[1]
		sfl := len(sourceFile)

		testFile := ""
		lineNo := 0
		var err error

		if sourceFile[sfl-2:] == "go" {
			testFile, lineNo, err = createTestGolang(fnName, sourceFile)
		} else if sourceFile[sfl-2:] == "rs" {
			testFile, lineNo, err = createTestRust(fnName, sourceFile)
		}
		fmt.Printf("%v,%v", testFile, lineNo)
		return err
	},
}

func createTestGolang(fnName, sourceFile string) (
	testFile string, lineNo int, err error) {

	// construct the test file
	base := filepath.Base(sourceFile)
	name := strings.Split(base, ".")[0] + "_test.go"
	dir := filepath.Dir(sourceFile)
	testFile = path.Join(dir, name)

	testFnStr := fmt.Sprintf("\nfunc Test%v(t *testing.T) {\n     \n}", fnName)

	var lines []string
	lineNo = 0 // line number to go to when reloading vim
	if common.FileExists(testFile) {
		var err error
		lines, err = common.ReadLines(testFile)
		if err != nil {
			return testFile, lineNo, err
		}
		lineNo = len(lines) + 2
		lines = append(lines, testFnStr)
	} else {
		sourceLines, err := common.ReadLines(sourceFile)
		if err != nil {
			return testFile, lineNo, err
		}
		lines = []string{
			sourceLines[0], //package
			"\nimport \"testing\"",
			testFnStr,
		}
		lineNo = 6
	}

	err = common.WriteLines(lines, testFile)
	return testFile, lineNo, err
}

// count squiggly brackets until 0
// to find the final line when the squigs are balanced
func CountSquigs(lines []string,
	startingAtIndex int, runOnceSquigsBalanced func(lineIndex int)) {

	squigCount := 0
	squigInitialized := false
	for j := startingAtIndex; j < len(lines); j++ {
		linej := lines[j]
		openSquigs := strings.Count(linej, "{")
		closeSquigs := strings.Count(linej, "}")
		squigCount += openSquigs - closeSquigs
		if !squigInitialized && openSquigs > 0 {
			squigInitialized = true
		}
		if squigInitialized && squigCount == 0 {
			runOnceSquigsBalanced(j)
			return
		}
	}
}

func createTestRust(fnName, sourceFile string) (
	testFile string, lineNo int, err error) {

	insertLineNo := -1
	lines, err := common.ReadLines(sourceFile)
	if err != nil {
		return sourceFile, lineNo, err
	}

	for i := len(lines) - 1; i >= 0; i-- {
		line := lines[i]
		if strings.Contains(line, `#[test]`) || strings.Contains(line, `#[cfg(test)]`) {

			insertLineNoWithinSquig := false
			if strings.Contains(line, `#[cfg(test)]`) {
				insertLineNoWithinSquig = true
			}

			br := false
			CountSquigs(lines, i, func(j int) {
				switch {
				case j > 0 && insertLineNoWithinSquig:
					insertLineNo = j - 1
				case j == 0 && insertLineNoWithinSquig:
					insertLineNo = j
				case !insertLineNoWithinSquig:
					insertLineNo = j
				}
				br = true
			})
			if br {
				break
			}

		}
	}

	insertTestHeader := false
	if insertLineNo == -1 { // iow if no other tests found
		insertTestHeader = true
		insertLineNo = len(lines) - 1
	}

	lineNo = insertLineNo + 1

	// actually insert the test code now
	testCode := []string{}
	if insertTestHeader {
		base := filepath.Base(sourceFile)
		modName := strings.Split(base, ".")[0] + "_tests"
		header := fmt.Sprintf("\n#[cfg(test)]\npub mod %v {\n    use super::*;", modName)
		testCode = append(testCode, header)
		lineNo += 4
	}

	testFnName := fnName + "_test"
	actualTestCode := fmt.Sprintf("\n    #[test]\n    fn %v() {\n         \n    }", testFnName)
	testCode = append(testCode, actualTestCode)
	lineNo += 4 // leave the lineNo inbetween the squiggly brackets

	if insertTestHeader {
		testCode = append(testCode, fmt.Sprintf("}"))
	}

	newLines := append([]string{}, lines[:insertLineNo+1]...)
	newLines = append(newLines, testCode...)
	newLines = append(newLines, lines[insertLineNo+1:]...)

	err = common.WriteLines(newLines, sourceFile)
	return sourceFile, lineNo, err
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

		// reached the end of the function
		if strings.Contains(line, "}") || strings.Contains(line, "{") {

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
func loadFileVisualMode(args []string) (srcFile string,
	startLineNo, endLineNo int, lines []string, err error) {

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

var createStructFulfillingInterface = &cobra.Command{
	Use:   "create-struct-fulfilling-interface [source-file] [lineno] [struct-name]",
	Short: "create a struct which fulfilles an interface",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile := args[0]
		lineNo, err := strconv.Atoi(args[1])
		if err != nil {
			fmt.Printf("obad line number: %v", err)
			return nil
		}
		structName := args[2]

		// get the interface
		inter, found := parse.GetCurrentParsedInterface(srcFile, lineNo)
		if !found {
			//fmt.Printf("o%v", "cursor not within a struct")
			return nil
		}

		abbr := camelcaseToAbbreviation(structName)

		// normal vim script: go to endline, enter line and start insert mode
		fmt.Printf("%vggo", inter.EndLine)

		// write the struct
		fmt.Printf("\r")
		fmt.Printf("// %v fulfills the interface %v (DNETL)\r", structName, inter.Name)
		fmt.Printf("type %v struct {}\r", structName)
		fmt.Printf("\r")
		fmt.Printf("var _ %v = %v{}\r", inter.Name, structName)

		// write all the interface functions
		for _, interFn := range inter.Functions {

			returnLine := ""
			if len(interFn.OutputFields) > 0 {
				returnLine = "return "
				for _, of := range interFn.OutputFields {

					// write one dummy output for each name, or just one dummy output
					// if there are no names
					max := len(of.Names)
					if max == 0 {
						max = 1
					}

					for i := 0; i < max; i++ {
						if len(returnLine) > 7 { // (7 = "return ")
							returnLine += ", "
						}
						returnLine += of.DummyFulfill
					}
				}
				returnLine += "\r"
			}

			// create the function text
			funcText := fmt.Sprintf("\r")
			funcText += fmt.Sprintf("// %v TODO\r", interFn.FuncName)
			funcText += fmt.Sprintf("func (%v %v) %v {\r", abbr, structName, interFn.RecreatedCode)
			funcText += fmt.Sprintf(returnLine)
			funcText += fmt.Sprintf("}\r")
			fmt.Printf(funcText)
		}

		return nil
	},
}
