package main

import (
	"fmt"
	"path"
	"strconv"

	"github.com/rigelrozanski/common/parse"
	"github.com/spf13/cobra"
)

var createInterfaceMirroringStruct = &cobra.Command{
	Use:   "create-interface-mirroring-struct [source-file] [lineno] <interface-name>",
	Short: "create a struct which fulfilles an interface",
	Args:  cobra.RangeArgs(2, 3),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile := args[0]
		lineNo, err := strconv.Atoi(args[1])
		if err != nil {
			fmt.Printf("obad line number: %v", err)
			return nil
		}
		interName := ""
		if len(args) == 3 {
			interName = args[2]
		}

		// get the function name
		strct, _, found := parse.GetCurrentParsedStruct(srcFile, lineNo)
		if !found {
			//fmt.Printf("o%v", "cursor not within a struct")
			return nil
		}

		if interName == "" {
			interName = capitalizedWord(strct.Name) + "I"
		}

		// get all the possible functions
		pfns := parse.GetAllFuncsOfStruct(path.Dir(srcFile), strct.Name)
		interCode := parse.InterfaceCodeFromFuncs(interName, pfns, "\r")

		// write the interface code
		fmt.Printf("%vggO", strct.CommentStartLine)
		fmt.Printf("// %v mirrors the struct %v (DNETL)\r%v", interName, strct.Name, interCode)
		return nil
	},
}
