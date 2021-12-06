
# Effects BBCode.
const BBCCodesMap: Dictionary = {
	"normal": 0,
	"shake": 1,
	"wave": 2,
	"colour": 3,
	"wave_colour": 4,
	"spin": 5,
	"pulse": 6,
	"flicker": 7
}

# Colour BBCodes.
const BBCColourMap: Dictionary = {"white": Color.white, "red": Color.red}

# BBCode regular expression.
const BBCRexp: String = "\\[(shake|wave|colour|wave_colour|spin|pulse|flicker|colour)\\].*?\\[\\/\\1\\]"

# Any BBCode regular expression.
# Used in case a wrong one was read and we need to remove it.
# It matches any BBCode, even not supported.
const BBCAnyRexp: String = "\\[.*\\].*?\\[\\/.*\\]"
