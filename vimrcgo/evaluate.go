package main

import (
	"fmt"
	"math"
	"strings"

	"github.com/knetic/govaluate"
	"github.com/spf13/cobra"
)

var evaluateText = &cobra.Command{
	Use:  "evaluate-text [text-to-evaluate]",
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {

		origEvalText := args[0]
		s := strings.Split(origEvalText, "=")
		evalText := s[0]
		evalText = strings.TrimPrefix(evalText, " ")
		evalText = strings.TrimPrefix(evalText, "\t")
		evalText = strings.TrimSuffix(evalText, " ")
		evalText = strings.TrimSuffix(evalText, "\t")
		evalText = strings.ReplaceAll(evalText, "\t", "")
		evalText = strings.ReplaceAll(evalText, " ", "*")

		fns := map[string]govaluate.ExpressionFunction{
			"strlen": func(args ...interface{}) (interface{}, error) {
				length := len(args[0].(string))
				return (float64)(length), nil
			},
			"sqrt": func(args ...interface{}) (interface{}, error) {
				return math.Sqrt(args[0].(float64)), nil
			},
			"abs": func(args ...interface{}) (interface{}, error) {
				return math.Abs(args[0].(float64)), nil
			},
			"log": func(args ...interface{}) (interface{}, error) {
				return math.Log(args[0].(float64)), nil
			},
			"log10": func(args ...interface{}) (interface{}, error) {
				return math.Log10(args[0].(float64)), nil
			},
			"log2": func(args ...interface{}) (interface{}, error) {
				return math.Log2(args[0].(float64)), nil
			},

			"sin": func(args ...interface{}) (interface{}, error) {
				return math.Sin(args[0].(float64)), nil
			},
			"cos": func(args ...interface{}) (interface{}, error) {
				return math.Cos(args[0].(float64)), nil
			},
			"tan": func(args ...interface{}) (interface{}, error) {
				return math.Tan(args[0].(float64)), nil
			},
			"asin": func(args ...interface{}) (interface{}, error) {
				return math.Asin(args[0].(float64)), nil
			},
			"acos": func(args ...interface{}) (interface{}, error) {
				return math.Acos(args[0].(float64)), nil
			},
			"atan": func(args ...interface{}) (interface{}, error) {
				return math.Atan(args[0].(float64)), nil
			},
			"sinh": func(args ...interface{}) (interface{}, error) {
				return math.Sinh(args[0].(float64)), nil
			},
			"cosh": func(args ...interface{}) (interface{}, error) {
				return math.Cosh(args[0].(float64)), nil
			},
			"tanh": func(args ...interface{}) (interface{}, error) {
				return math.Tanh(args[0].(float64)), nil
			},
		}

		expr, err := govaluate.NewEvaluableExpressionWithFunctions(evalText, fns)
		if err != nil {
			fmt.Printf("%v = cannot parse %v", origEvalText, evalText)
			return nil
		}
		result, err := expr.Evaluate(nil)
		if err != nil {
			fmt.Printf("%v = cannot evaluate %v", origEvalText, evalText)
			return nil
		}
		switch res := result.(type) {
		case string:
			fmt.Printf("%v=%v", evalText, res)
		case bool:
			fmt.Printf("%v=%v", evalText, res)
		case float64:
			fmt.Printf("%v=%v", evalText, res)
		default:
			fmt.Printf("%v = uknown output type %v", origEvalText, result)
		}
		return nil
	},
}
