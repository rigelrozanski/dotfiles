package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"math"
	"net/http"
	"strconv"
	"strings"

	"github.com/PuerkitoBio/goquery"
	"github.com/knetic/govaluate"
	"github.com/rigelrozanski/common"
	"github.com/spf13/cobra"
)

var evaluateDoc = &cobra.Command{
	Use:  "evaluate-doc [source-file]",
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {

		srcFile := args[0]
		if !common.FileExists(srcFile) {
			return errors.New("src file not found")
		}
		lines, err := common.ReadLines(srcFile)
		outLines := make([]string, len(lines))
		copy(outLines, lines)
		if err != nil {
			return err
		}
		params := make(map[string]interface{})

		for i, line := range lines {
			if len(line) < 2 {
				continue
			}
			strTrim := strings.TrimSpace(line)
			if strings.HasPrefix(strTrim, "//") {
				continue
			}

			// set params
			if strings.HasPrefix(strTrim, "let ") {
				tr := strings.TrimPrefix(strTrim, "let ")
				splt := strings.SplitN(tr, "==", 2)
				if len(splt) < 2 {
					continue
				}
				paramName := splt[0]
				exprStr := strings.Split(splt[1], "==")[0] // trim any old results
				exprRes := evaluateExpr(exprStr, params)
				params[paramName] = exprRes
				outLines[i] = fmt.Sprintf("let %v==%v==%v", paramName, exprStr, exprRes)
				continue
			}

			// evaluate line otherwise
			splt := strings.SplitN(line, "==", 2)
			expression := splt[0]
			exprRes := evaluateExpr(expression, params)
			outLines[i] = fmt.Sprintf("%v==%v", expression, exprRes)
		}

		return common.WriteLines(outLines, srcFile)
	},
}

var evaluateText = &cobra.Command{
	Use:  "evaluate-text [text-to-evaluate]",
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {

		origEvalText := args[0]
		s := strings.Split(origEvalText, "==")
		evalText := s[0]
		evalText = strings.TrimSpace(evalText)
		//evalText = strings.ReplaceAll(evalText, " ", "*")

		result := evaluateExpr(evalText, nil)

		switch res := result.(type) {
		case string:
			fmt.Printf("%v==%v", evalText, res)
		case bool:
			fmt.Printf("%v==%v", evalText, res)
		case float64:
			fmt.Printf("%v==%v", evalText, res)
		default:
			fmt.Printf("%v==uknown output type %v", origEvalText, result)
		}
		return nil
	},
}

func evaluateExpr(expression string, params map[string]interface{}) (res interface{}) {

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
		"rmDollar": func(args ...interface{}) (interface{}, error) {
			tr := strings.TrimPrefix(args[0].(string), "$")
			tr = strings.Replace(tr, ",", "", -1) // also remove any commas
			return strconv.ParseFloat(tr, 64)
		},
		"parse":     parseHTML,
		"parsejson": parseJson,
	}

	expr, err := govaluate.NewEvaluableExpressionWithFunctions(expression, fns)
	if err != nil {
		return fmt.Sprintf("cannot parse, error: %v", err)
	}
	res, err = expr.Evaluate(params)
	if err != nil {
		return fmt.Sprintf("cannot evaluate, error: %v", err)
	}
	return res
}

// parse html text with goquery
// arg1 = the html text
// arg2 = the index of any results to capture
// arg3 = the classes to search through (aka ".yourclassname")
// arg4,5 = alternating mandatory attribute name and value to filter for
// argx,y = continuation of the attributes to filter for
func parseHTML(args ...interface{}) (interface{}, error) {

	if len(args) < 3 {
		return "", errors.New("must have at least 3 args, html text, capture index, and classes")
	}
	url := args[0].(string)
	resIndexToTake, err := strconv.Atoi(args[1].(string))
	if err != nil {
		return "", err
	}
	classFilter := args[2].(string)

	// get the attributes to look through
	type attrVal struct {
		attr string
		val  string
	}
	avs := []attrVal{}
	if len(args) >= 3 && (len(args)-3)%2 != 0 {
		return "", errors.New("must have even number of attributes and attribute values")
	}
	for i := 3; i < len(args); i += 2 {
		avs = append(avs, attrVal{args[i].(string), args[i+1].(string)})
	}

	res, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		return "", fmt.Errorf("status code error: %d %s", res.StatusCode, res.Status)
	}

	// Load the HTML document
	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		return "", err
	}

	// Find the review items
	foundIndex := 0
	outText := ""
	doc.Find(classFilter).Each(func(_ int, s *goquery.Selection) {

		// For each item found, get the title
		for _, av := range avs {
			attrVal, exists := s.Attr(av.attr)
			if !exists {
				return
			}
			if attrVal != av.val {
				return
			}
		}

		// only take output at the found index
		if foundIndex == resIndexToTake {
			outText = s.Text()
		}
		foundIndex++
	})

	return outText, nil
}

func parseJson(args ...interface{}) (interface{}, error) {

	if len(args) < 2 {
		return "", fmt.Errorf("must have at least 2 args: url, a parser:%+v", args)
	}
	url := args[0].(string)
	res, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		return "", fmt.Errorf("status code error: %d %s", res.StatusCode, res.Status)
	}
	body, err := ioutil.ReadAll(res.Body) // response body is []byte
	if err != nil {
		return "", err
	}

	result := make(map[string]interface{})
	if err := json.Unmarshal(body, &result); err != nil { // Parse []byte to the go struct pointer
		return "", err
	}

	query := []string{}
	for i := 1; i < len(args); i++ {
		query = append(query, args[i].(string))
	}

	return TraverseToStr(result, query)
}

func TraverseToUint64(data interface{}, path []string) (uint64, error) {
	val, err := Traverse(data, path)
	if err != nil {
		return 0, err
	}
	return val.(uint64), nil
}

func TraverseToStr(data interface{}, path []string) (string, error) {
	val, err := Traverse(data, path)
	if err != nil {
		return "", err
	}
	return val.(string), nil
}

func TraverseToMap(data interface{}, path []string) (map[string]interface{}, error) {
	val, err := Traverse(data, path)
	if err != nil {
		return nil, err
	}
	return val.(map[string]interface{}), nil
}

func TraverseToArray(data interface{}, path []string) ([]interface{}, error) {
	val, err := Traverse(data, path)
	if err != nil {
		return nil, err
	}
	return val.([]interface{}), nil
}

func Traverse(data interface{}, path []string) (interface{}, error) {
	var ok bool
	current := data
	for _, p := range path {
		switch current.(type) {
		case map[string]string:
			if current, ok = current.(map[string]string)[p]; !ok {
				return nil, fmt.Errorf("key not found in map: %s", p)
			}
		case map[string]interface{}:
			if current, ok = current.(map[string]interface{})[p]; !ok {
				return nil, fmt.Errorf("key not found in map: %s", p)
			}
		case []interface{}:
			i, err := strconv.ParseInt(p, 10, 64)
			if err != nil {
				return nil, fmt.Errorf("integer required, got: %s", p)
			}
			array := current.([]interface{})
			if i < 0 || i >= int64(len(array)) {
				return nil, fmt.Errorf("index %d out of bounds for %v", i, array)
			}
			current = array[i]
		default:
			return nil, fmt.Errorf("cannot traverse %T\n", current)
		}
	}
	return current, nil
}
