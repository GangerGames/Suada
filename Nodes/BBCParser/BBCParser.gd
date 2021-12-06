## The BBCParser class
##
## @desc:
##     An object to parse BBCode text.
##

const BBCCodes = preload("res://addons/Suada/Nodes/BBCParser/BBCCodes.gd")

var _regex_bbc: RegEx = RegEx.new()
var _regex_bbc_any: RegEx = RegEx.new()

# _regex_bbc.compile(BBCCodes.BBCRexp)
# _regex_bbc_any.compile(BBCCodes.BBCAnyRexp)


class EffectLocation:
	var position: int
	var effect: int

	func _init(pos: int, ef: int):
		position = pos
		effect = ef


class ColourLocation:
	var position: int
	var colour: Color

	func _init(pos: int, col: Color):
		position = pos
		colour = col


class ParseReturn:
	var parsed_text: String = ""
	var effects: Array = []
	var colours: Array = []


static func Parse(text: String, default_colour: Color) -> ParseReturn:
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

			if effect != "colour" and !effect.empty() and effect in BBCCodes.BBCCodesMap:
				return_obj.effects.append(
					EffectLocation.new(
						it_original_text, BBCCodes.BBCCodesMap[effect] if !is_out else 0
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
