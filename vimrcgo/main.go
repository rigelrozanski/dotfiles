package main

import (
	"fmt"
	"os"

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
	rootCmd.AddCommand(createGetSetFunctionOf)
	rootCmd.AddCommand(createStructFulfillingInterface)
	rootCmd.AddCommand(createInterfaceMirroringStruct)
	rootCmd.AddCommand(evaluateText)
	rootCmd.AddCommand(evaluateDoc)
	rootCmd.AddCommand(ConvertToBoxChars)
	rootCmd.AddCommand(snakeToUpperCamel)
	rootCmd.AddCommand(snakeToCamel)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
