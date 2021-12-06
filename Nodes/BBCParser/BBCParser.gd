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


## Effect location class.
##
## Holds the position and effect.
class EffectLocation:
	var position: int
	var effect: int

	func _init(pos: int, ef: int):
		position = pos
		effect = ef


## Colour location class.
##
## Holds the position and colour.
class ColourLocation:
	var position: int
	var colour: Color

	func _init(pos: int, col: Color):
		position = pos
		colour = col


## Parse return class.
##
## Holds the parsed text data.
class ParseReturn:
	var parsed_text: String = ""
	var effects: Array = []
	var colours: Array = []


## Parse a text to get the data to show it on the dialog.
##
## Returns a [ParseReturn] object with the data without BBCodes and a list of effects and colours
## positions.
##
## If there is a wrong or unsupported BBCode, will be removed.
##
## @param text The text to parse.
## @param default_colour The default colour of the dialog.
## @returns A [ParseReturn] object.
static func parse(text: String, default_colour: Color) -> ParseReturn:
	var return_obj: ParseReturn = ParseReturn.new()

	var it = 0
	var it_original_text = 0
	var type = 0

	while it < text.length():
		var letter: String = text[it]

		if letter != "[":
			return_obj.parsed_text += letter
			it += 1
			it_original_text += 1
		else:
			var colour: String = ""
			var effect: String = ""
			var effect_it: int = it + 1
			var is_out: bool = false

			while effect_it < text.length():
				var in_letter: String = text[effect_it]

				if effect == "colour" && in_letter != "=" && in_letter != "]":
					colour += in_letter
				elif in_letter != "]" && in_letter != "/" && in_letter != "=":
					effect += in_letter
				elif in_letter == "/":
					is_out = true
				elif in_letter == "]":
					break

				effect_it += 1

			if effect != "colour" and !effect.empty() and effect in BBC_CODES_MAP:
				return_obj.effects.append(
					EffectLocation.new(
						it_original_text, BBC_CODES_MAP[effect] if !is_out else 0
					)
				)
			elif effect == "colour":
				return_obj.colours.append(
					ColourLocation.new(
						it_original_text, Color(colour) if !is_out else default_colour
					)
				)
			elif is_out:
				if return_obj.effects.size() % 2 != 0:
					return_obj.effects.pop_back()
				if return_obj.colours.size() % 2 != 0:
					return_obj.colours.pop_back()

			it = effect_it + 1

	return return_obj
