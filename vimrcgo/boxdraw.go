package main

import (
	"fmt"
	"strconv"

	"github.com/rigelrozanski/common"
	"github.com/spf13/cobra"
)

/*
main symbol conversions
. = corner (┌, ┐, └, ┘)
, = smooth corner (╭, ╮, ╯, ╰)
T,t = tee connection to 3 sides (┴, ┤, ┬, ├)
+ = box + (┼)
> = right arrow (←, ↑, →, ↓)
< = left arrow
v = down arrow
^ = up arrow
- = vertical line (─)
| = horizontal line (│)
x = ╳
/ = ╱
\ = ╲
0 = █
1 = ▓
2 = ▒
3 = ░

commands:
box:                  convert to box characters
boxrotate, boxr:      rotate corners, diagonals, or T's clockwise
boxclear, boxc:       reset style
boxbold, boxb:        bold thickness
boxdouble, boxdub:    double thickness
boxdash2, box2:       convert to dashed lines (2)
boxdash3, box3:       convert to dashed lines (3)
boxdash4, box4:       convert to dashed lines (4)
boxnodash box0:       convert to dashed lines (2)
*/

func parseArgs(args []string) (
	srcFile string, startLineNo, endLineNo, startColNo, endColNo int, err error) {

	srcFile = args[0]
	startLineNo, err = strconv.Atoi(args[1])
	if err != nil {
		return srcFile, startLineNo, endLineNo, startColNo, endColNo, err
	}
	endLineNo, err = strconv.Atoi(args[2])
	if err != nil {
		return srcFile, startLineNo, endLineNo, startColNo, endColNo, err
	}
	startColNo, err = strconv.Atoi(args[3])
	if err != nil {
		return srcFile, startLineNo, endLineNo, startColNo, endColNo, err
	}
	endColNo, err = strconv.Atoi(args[4])
	if err != nil {
		return srcFile, startLineNo, endLineNo, startColNo, endColNo, err
	}
	return srcFile, startLineNo, endLineNo, startColNo, endColNo, nil
}

var ConvertToBoxChars = &cobra.Command{
	Use:   "convert2boxch [source-file] [start-lineno] [end-lineno] [start-col] [end-col]",
	Short: "convert selected characters in file to box charcters",
	Args:  cobra.ExactValidArgs(5),
	RunE: func(cmd *cobra.Command, args []string) error {
		srcFile, startLineNo, endLineNo, startColNo, endColNo, err := parseArgs(args)
		if err != nil {
			fmt.Printf("oerror: %v", err)
		}

		lines, err := common.ReadLines(srcFile)
		if err != nil {
			fmt.Printf("oerror: %v", err)
		}

		for {
			// keep looping until nothing happens during the run
			// this may need to occur more than once to help fill
			// in the Ts and Corners (first the adjacent lines
			// must be filled in before the T know how to orient itself

			NothingHappened := true
			for x := startColNo; x < endColNo; x++ {
				for y := startLineNo; y < endLineNo; y++ {
					r := string([]rune(lines[y])[x])
					lineLen := len([]rune(lines[y]))
					numLines := len(lines)
					left, right, top, bottom := "", "", "", ""
					if x > 0 {
						left = string([]rune(lines[y])[x-1])
					}
					if x < lineLen-1 {
						right = string([]rune(lines[y])[x+1])
					}
					if y > 0 {
						top = string([]rune(lines[y-1])[x])
					}
					if y < numLines-1 {
						bottom = string([]rune(lines[y+1])[x])
					}
					boxCh, ok := ConvertToBoxCh(r, left, right, top, bottom)
					if ok {
						rn := ' '
						if len(boxCh) > 0 {
							rn = []rune(boxCh)[0]
						}
						lines = replaceCharInLines(lines, x, y, rn)
						NothingHappened = false
					}
				}
			}
			if NothingHappened {
				break
			}
		}

		return nil
	},
}

//var ConvertToBoxChars = &cobra.Command{
//Use:   "convert2boxch [source-file] [start-lineno] [end-lineno] [start-col] [end-col]",
//Short: "convert selected characters in file to box charcters",
//Args:  cobra.ExactValidArgs(5),
//RunE:  ToggleBoxBoldCmd,
//}

//func ToggleBoxBoldCmd(cmd *cobra.Command, args []string) error {
//}

func replaceCharInLines(lines []string, x, y int, ch rune) []string {
	rs := []rune(lines[y])
	rs[x] = ch
	newLine := string(rs)
	lines[y] = newLine
	return lines
}

// must know surrounding characters for inferences of corners and tees
func ConvertToBoxCh(toConvert, left, right, top, bottom string) (boxCh string, converted bool) {

	switch toConvert {
	case `.`:
		leftConnects := IsBoxChWhichConnectsOnRight(left)
		rightConnects := IsBoxChWhichConnectsOnLeft(right)
		topConnects := IsBoxChWhichConnectsOnBottom(top)
		bottomConnects := IsBoxChWhichConnectsOnTop(bottom)
		switch {
		case leftConnects && topConnects:
			return `┘`, true
		case leftConnects && bottomConnects:
			return `┐`, true
		case rightConnects && bottomConnects:
			return `┌`, true
		case rightConnects && topConnects:
			return `└`, true
		}
	case `,`:
		leftConnects := IsBoxChWhichConnectsOnRight(left)
		rightConnects := IsBoxChWhichConnectsOnLeft(right)
		topConnects := IsBoxChWhichConnectsOnBottom(top)
		bottomConnects := IsBoxChWhichConnectsOnTop(bottom)
		switch {
		case leftConnects && topConnects:
			return `╯`, true
		case leftConnects && bottomConnects:
			return `╮`, true
		case rightConnects && bottomConnects:
			return `╭`, true
		case rightConnects && topConnects:
			return `╰`, true
		}
	case `T`, `t`:
		leftConnects := IsBoxChWhichConnectsOnRight(left)
		rightConnects := IsBoxChWhichConnectsOnLeft(right)
		topConnects := IsBoxChWhichConnectsOnBottom(top)
		bottomConnects := IsBoxChWhichConnectsOnTop(bottom)
		switch {
		case leftConnects && topConnects && rightConnects:
			return `┴`, true
		case leftConnects && bottomConnects && topConnects:
			return `┤`, true
		case rightConnects && leftConnects && bottomConnects:
			return `┬`, true
		case rightConnects && topConnects && bottomConnects:
			return `├`, true
		}
	case `+`:
		return `┼`, true
	case `>`:
		return `→`, true
	case `<`:
		return `←`, true
	case `v`:
		return `↓`, true
	case `^`:
		return `↑`, true
	case `-`:
		return `─`, true
	case `|`:
		return `│`, true
	case `x`:
		return `╳`, true
	case `/`:
		return `╱`, true
	case `\`:
		return `╲`, true
	case `0`:
		return `█`, true
	case `1`:
		return `▓`, true
	case `2`:
		return `▒`, true
	case `3`:
		return `░`, true
	}

	// otherwise don't convert
	return toConvert, false
}

func IsBoxChWhichConnectsOnBottom(ch string) bool {
	switch ch {
	case `│`, `┃`, `┆`, `┇`, `┊`, `┋`, `┌`, `┍`, `┎`, `┏`, `┐`, `┑`, `┒`,
		`┓`, `├`, `┝`, `┞`, `┟`, `┠`, `┡`, `┢`, `┣`, `┤`, `┥`, `┦`, `┧`, `┨`,
		`┩`, `┪`, `┫`, `┬`, `┭`, `┮`, `┯`, `┰`, `┱`, `┲`, `┳`, `┼`, `┽`, `┾`,
		`┿`, `╀`, `╁`, `╂`, `╃`, `╄`, `╅`, `╆`, `╇`, `╈`, `╉`, `╊`, `╋`, `╎`,
		`╏`, `║`, `╒`, `╓`, `╔`, `╕`, `╖`, `╗`, `╞`, `╟`, `╠`, `╡`, `╢`, `╣`,
		`╤`, `╥`, `╦`, `╪`, `╫`, `╬`, `╭`, `╮`, `╷`, `╻`, `╽`, `╿`:
		return true
	}
	return false
}

func IsBoxChWhichConnectsOnTop(ch string) bool {
	switch ch {
	case `│`, `┃`, `┆`, `┇`, `┊`, `┋`, `└`, `┕`, `┖`, `┗`, `┘`, `┙`, `┚`,
		`┛`, `├`, `┝`, `┞`, `┟`, `┠`, `┡`, `┢`, `┣`, `┤`, `┥`, `┦`, `┧`, `┨`,
		`┩`, `┪`, `┫`, `┴`, `┵`, `┶`, `┷`, `┸`, `┹`, `┺`, `┻`, `┼`, `┽`, `┾`,
		`┿`, `╀`, `╁`, `╂`, `╃`, `╄`, `╅`, `╆`, `╇`, `╈`, `╉`, `╊`, `╋`, `╎`,
		`╏`, `║`, `╘`, `╙`, `╚`, `╛`, `╜`, `╝`, `╞`, `╟`, `╠`, `╡`, `╢`, `╣`,
		`╧`, `╨`, `╩`, `╪`, `╫`, `╬`, `╯`, `╰`, `╵`, `╹`, `╽`, `╿`:
		return true
	}
	return false
}

func IsBoxChWhichConnectsOnRight(ch string) bool {
	switch ch {
	case `─`, `━`, `┄`, `┅`, `┈`, `┉`, `┌`, `┍`, `┎`, `┏`, `└`, `┕`, `┖`,
		`┗`, `├`, `┝`, `┞`, `┟`, `┠`, `┡`, `┢`, `┣`, `┬`, `┭`, `┮`, `┯`, `┰`,
		`┱`, `┲`, `┳`, `┴`, `┵`, `┶`, `┷`, `┸`, `┹`, `┺`, `┻`, `┼`, `┽`, `┾`,
		`┿`, `╀`, `╁`, `╂`, `╃`, `╄`, `╅`, `╆`, `╇`, `╈`, `╉`, `╊`, `╋`, `╌`,
		`╍`, `═`, `╒`, `╓`, `╔`, `╘`, `╙`, `╚`, `╞`, `╟`, `╠`, `╤`, `╥`, `╦`,
		`╧`, `╨`, `╩`, `╪`, `╫`, `╬`, `╭`, `╰`, `╶`, `╺`, `╼`, `╾`:
		return true
	}
	return false
}

func IsBoxChWhichConnectsOnLeft(ch string) bool {
	switch ch {
	case `─`, `━`, `┄`, `┅`, `┈`, `┉`, `┐`, `┑`, `┒`, `┓`, `┘`, `┙`, `┚`,
		`┛`, `┤`, `┥`, `┦`, `┧`, `┨`, `┩`, `┪`, `┫`, `┬`, `┭`, `┮`, `┯`, `┰`,
		`┱`, `┲`, `┳`, `┴`, `┵`, `┶`, `┷`, `┸`, `┹`, `┺`, `┻`, `┼`, `┽`, `┾`,
		`┿`, `╀`, `╁`, `╂`, `╃`, `╄`, `╅`, `╆`, `╇`, `╈`, `╉`, `╊`, `╋`, `╌`,
		`╍`, `═`, `╕`, `╖`, `╗`, `╛`, `╜`, `╝`, `╡`, `╢`, `╣`, `╤`, `╥`, `╦`,
		`╧`, `╨`, `╩`, `╪`, `╫`, `╬`, `╮`, `╯`, `╴`, `╸`, `╼`, `╽`, `╾`, `╿`:
		return true
	}
	return false
}

// --------------------------
func BoxChToggleBold(toConvert string) string {
	pairs := [][]string{
		{`─`, `━`},
		{`│`, `┃`},
		{`╌`, `╍`},
		{`╎`, `╏`},
		{`┄`, `┅`},
		{`┆`, `┇`},
		{`┈`, `┉`},
		{`┊`, `┋`},
		{`┴`, `┻`},
		{`┤`, `┫`},
		{`┬`, `┳`},
		{`├`, `┣`},
		{`┌`, `┏`},
		{`┐`, `┓`},
		{`└`, `┗`},
		{`┘`, `┛`},
		{`┼`, `╋`},
	}
	for _, pair := range pairs {
		if toConvert == pair[0] {
			return pair[1]
		}
		if toConvert == pair[1] {
			return pair[0]
		}
	}
	return toConvert
}

func BoxChToggleDouble(toConvert string) string {
	pairs := [][]string{
		{`─`, `═`},
		{`│`, `║`},
		{`┴`, `╩`},
		{`┤`, `╣`},
		{`┬`, `╦`},
		{`├`, `╠`},
		{`┌`, `╔`},
		{`┐`, `╗`},
		{`└`, `╚`},
		{`┘`, `╝`},
		{`┼`, `╬`},
	}
	for _, pair := range pairs {
		if toConvert == pair[0] {
			return pair[1]
		}
		if toConvert == pair[1] {
			return pair[0]
		}
	}
	return toConvert
}

func BoxChRotateClockwise(toConvert string) string {
	pairs := [][]string{
		{`─`, `│`},
		{`│`, `─`},
		{`┴`, `├`},
		{`├`, `┬`},
		{`┬`, `┤`},
		{`┤`, `┴`},
		{`┌`, `┐`},
		{`┐`, `┘`},
		{`┘`, `└`},
		{`└`, `┌`},
		{`═`, `║`},
		{`║`, `═`},
		{`╩`, `╠`},
		{`╠`, `╦`},
		{`╦`, `╣`},
		{`╣`, `╩`},
		{`╔`, `╗`},
		{`╗`, `╝`},
		{`╝`, `╚`},
		{`╚`, `╔`},
		{`━`, `┃`},
		{`┃`, `━`},
		{`╌`, `╎`},
		{`╎`, `╌`},
		{`╍`, `╏`},
		{`╏`, `╍`},
		{`┄`, `┆`},
		{`┆`, `┄`},
		{`┅`, `┇`},
		{`┇`, `┅`},
		{`┈`, `┊`},
		{`┊`, `┈`},
		{`┉`, `┋`},
		{`┋`, `┉`},
		{`┻`, `┣`},
		{`┣`, `┳`},
		{`┳`, `┫`},
		{`┫`, `┻`},
		{`┏`, `┓`},
		{`┓`, `┛`},
		{`┛`, `┗`},
		{`┗`, `┏`},
		{`╭`, `╮`},
		{`╮`, `╯`},
		{`╯`, `╰`},
		{`╰`, `╭`},
		{`╱`, `╲`},
		{`╲`, `╱`},
		{`→`, `↓`},
		{`↓`, `←`},
		{`←`, `↑`},
		{`↑`, `→`},
	}
	for _, pair := range pairs {
		if toConvert == pair[0] {
			return pair[1]
		}
	}
	return toConvert
}

func BoxChNoDash(toConvert string) string {
	switch toConvert {
	case `╌`, `┄`, `┈`:
		return `─`
	case `╎`, `┆`, `┊`:
		return `│`
	case `╍`, `┅`, `┉`:
		return `━`
	case `╏`, `┇`, `┋`:
		return `┃`
	}
	return toConvert
}

func BoxChDash2(toConvert string) string {
	switch toConvert {
	case `─`, `┄`, `┈`:
		return `╌`
	case `│`, `┆`, `┊`:
		return `╎`
	case `━`, `┅`, `┉`:
		return `╍`
	case `┃`, `┇`, `┋`:
		return `╏`
	}
	return toConvert
}

func BoxChDash3(toConvert string) string {
	switch toConvert {
	case `─`, `╌`, `┈`:
		return `┄`
	case `│`, `╎`, `┊`:
		return `┆`
	case `━`, `╍`, `┉`:
		return `┅`
	case `┃`, `╏`, `┋`:
		return `┇`
	}
	return toConvert
}

func BoxChDash4(toConvert string) string {
	switch toConvert {
	case `─`, `╌`, `┄`:
		return `┈`
	case `│`, `╎`, `┆`:
		return `┊`
	case `━`, `╍`, `┅`:
		return `┉`
	case `┃`, `╏`, `┇`:
		return `┋`
	}
	return toConvert
}
