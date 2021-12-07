# Effects BBCode.
const BBC_CODES_MAP: Dictionary = {
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
const BBC_COLOUR_MAP: Dictionary = {"white": Color.white, "red": Color.red}

# BBCode regular expression.
const BBC_REXP: String = (
	"\\[(shake|wave|colour|wave_colour|spin|pulse|flicker|colour)\\]"
	+ ".*?\\[\\/\\1\\]"
)

# Any BBCode regular expression.
# Used in case a wrong one was read and we need to remove it.
# It matches any BBCode, even not supported.
const BBC_ANY_REXP: String = "\\[.*\\].*?\\[\\/.*\\]"
