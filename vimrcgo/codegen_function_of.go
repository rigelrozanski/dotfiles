package main

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/rigelrozanski/common"
	"github.com/rigelrozanski/common/parse"
	"github.com/spf13/cobra"
)

var createFunctionOf = &cobra.Command{
	Use:   "create-function-of [source-file] [lineno] [func-name]",
	Short: "create a function of a struct",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile := args[0]
		fnName := args[2]

		lineNo, err := strconv.Atoi(args[1])
		if err != nil {
			fmt.Printf("obad line number: %v", err)
			return nil
		}

		sfl := len(srcFile)
		gotoLineNo := 0
		if srcFile[sfl-2:] == "go" {
			gotoLineNo, err = createFunctionOfGo(srcFile, fnName, lineNo)
		} else if srcFile[sfl-2:] == "rs" {
			gotoLineNo, err = createFunctionOfRust(srcFile, fnName, lineNo-1)
		}
		fmt.Printf("%v", gotoLineNo)
		return err
	},
}

func createFunctionOfGo(srcFile, fnName string, lineNo int) (goToLineNo int, err error) {

	// get the function name
	strct, _, found := parse.GetCurrentParsedStruct(srcFile, lineNo)
	if !found {
		//fmt.Printf("o%v", "cursor not within a struct")
		return lineNo, nil
	}

	abbr := camelcaseToAbbreviation(strct.Name)

	insertLineNo := strct.EndLine

	lines, err := common.ReadLines(srcFile)
	if err != nil {
		return lineNo, err
	}

	// create the function text
	funcText := fmt.Sprintf("")
	funcText += fmt.Sprintf("// %v TODO\n", fnName)
	funcText += fmt.Sprintf("func (%v %v) %v() {\n", abbr, strct.Name, fnName)
	funcText += fmt.Sprintf("    \n")
	funcText += fmt.Sprintf("}\n")

	newLines := append([]string{}, lines[:insertLineNo+1]...)
	newLines = append(newLines, funcText)
	newLines = append(newLines, lines[insertLineNo+1:]...)

	return insertLineNo + 4, common.WriteLines(newLines, srcFile)
}

// TODO move parsing this into rust
// TODO move into common
type rustStructSig struct {
	structName    string
	typeDecl      string // ex. "<const ND: usize>"
	typeDeclConst string // ex. "ND" from the above typeDecl
}

func ParseRustStructSig(line string) rustStructSig {
	fs := strings.Fields(line)
	rss := rustStructSig{}
	lastF := ""
	withinTypeDecl := false
	for _, f := range fs {
		if lastF == "struct" {
			spl := strings.SplitN(f, "<", 2)
			if len(spl) == 1 {
				rss.structName = spl[0]
			} else {
				// split successful, len spl must be 2
				rss.structName = spl[0]
				rss.typeDecl = "<" + spl[1]
				withinTypeDecl = true
			}
		} else if withinTypeDecl {

			rss.typeDecl += " " + f
			if strings.HasSuffix(rss.typeDecl, ">") {
				break
			}
		}

		lastF = f
	}

	if len(rss.typeDecl) > 0 {
		spl := strings.SplitN(rss.typeDecl, "const ", 2)
		if len(spl) == 2 {
			spl := strings.SplitN(spl[1], ":", 2)
			if len(spl) == 2 {
				rss.typeDeclConst = spl[0]
			}
		}
	}
	return rss
}

func (rss rustStructSig) ImplBlockHeader() string {
	if len(rss.typeDecl) > 0 && len(rss.typeDeclConst) > 0 {
		return fmt.Sprintf("\nimpl%v %v<%v> {", rss.typeDecl, rss.structName, rss.typeDeclConst)
	}
	return fmt.Sprintf("impl %v {", rss.structName)
}

func createFunctionOfRust(srcFile, fnName string, structLineNo int) (gotoLineNo int, err error) {

	insertLineNo := -1
	lines, err := common.ReadLines(srcFile)
	if err != nil {
		return structLineNo, err
	}

	rss := ParseRustStructSig(lines[structLineNo])

	for i := len(lines) - 1; i >= 0; i-- {
		line := lines[i]
		if strings.Contains(line, `impl`) &&
			strings.Contains(line, rss.structName) &&
			!strings.Contains(line, ` for `) {

			br := false
			CountSquigs(lines, i, func(j int) {
				insertLineNo = j - 1
				br = true
			})
			if br {
				break
			}
		}
	}

	insertImplBlock := false
	if insertLineNo == -1 { // iow if no other tests found
		insertImplBlock = true
		insertLineNo = len(lines) - 1

		CountSquigs(lines, structLineNo, func(j int) {
			insertLineNo = j + 1
		})
	}

	gotoLineNo = insertLineNo + 1

	// actually insert the test code now
	functionCode := []string{}
	if insertImplBlock {
		header := rss.ImplBlockHeader()
		functionCode = append(functionCode, header)
		gotoLineNo += 2
	}

	actualTestCode := fmt.Sprintf("\n    pub fn %v() {\n         \n    }", fnName)
	functionCode = append(functionCode, actualTestCode)
	gotoLineNo += 2 // leave the gotoLineNo inbetween the squiggly brackets

	if insertImplBlock {
		functionCode = append(functionCode, fmt.Sprintf("}"))
	}

	newLines := append([]string{}, lines[:insertLineNo+1]...)
	newLines = append(newLines, functionCode...)
	newLines = append(newLines, lines[insertLineNo+1:]...)

	return gotoLineNo, common.WriteLines(newLines, srcFile)
}

var createGetSetFunctionOf = &cobra.Command{
	Use:   "create-get-set-function-of [source-file] [lineno] [get,set,or getandset]",
	Short: "create a get and/or set function of a struct for one of its fields",
	Args:  cobra.ExactArgs(3),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile := args[0]
		lineNo, err := strconv.Atoi(args[1])
		if err != nil {
			fmt.Printf("obad line number: %v", err)
			return nil
		}
		get, set := false, false
		switch args[2] {
		case "get":
			get = true
		case "set":
			set = true
		case "getandset":
			get = true
			set = true
		default:
			fmt.Printf("obad text for 3rd arg must be either get, set, or getandset")
			return nil
		}

		// get the field
		strct, fld, found := parse.GetCurrentParsedStruct(srcFile, lineNo)
		if !found {
			//fmt.Printf("o%v", "cursor not within a struct")
			return nil
		}

		abbr := camelcaseToAbbreviation(strct.Name)

		// normal vim script: go to endline, enter line and start insert mode
		fmt.Printf("%vggo", strct.EndLine)

	OUTER:
		for _, fldName := range fld.Names {
			capitalizedFldName := ""
			lowerCaseFldName := ""
			switch len(fldName) {
			case 0:
				continue OUTER
			case 1:
				capitalizedFldName = strings.ToUpper(string(fldName[0]))
				lowerCaseFldName = strings.ToLower(string(fldName[0]))
			default:
				capitalizedFldName = strings.ToUpper(string(fldName[0])) + string(fldName[1:])
				lowerCaseFldName = strings.ToLower(string(fldName[0])) + string(fldName[1:])
			}

			if get {
				fnName := fmt.Sprintf("Get%v", capitalizedFldName)

				funcText := fmt.Sprintf("\r")
				funcText += fmt.Sprintf("// %v gets %v from %v \r", fnName, fldName, strct.Name)
				funcText += fmt.Sprintf("func (%v *%v) %v() %v {\r",
					abbr, strct.Name, fnName, fld.Type)
				funcText += fmt.Sprintf("return %v.%v\r", abbr, fldName)
				funcText += fmt.Sprintf("}")
				fmt.Printf(funcText)
			}

			if set {
				fnName := fmt.Sprintf("Set%v", capitalizedFldName)
				funcText := fmt.Sprintf("\r")
				if get {
					funcText += fmt.Sprintf("\r") //extra line
				}
				funcText += fmt.Sprintf("// %v sets %v within %v \r", fnName, fldName, strct.Name)
				funcText += fmt.Sprintf("func (%v *%v) %v(%v %v) {\r",
					abbr, strct.Name, fnName, lowerCaseFldName, fld.Type)
				funcText += fmt.Sprintf("%v.%v = %v\r", abbr, fldName, lowerCaseFldName)
				funcText += fmt.Sprintf("}")
				fmt.Printf(funcText)
			}
		}

		return nil
	},
}
