class_name BBCParser


static func _get_value(text: String, pos: int) -> Array:
	var value = ""

	while pos < text.length():
		var in_letter: String = text[pos]

		if in_letter != "]" && in_letter != "/" && in_letter != "=":
			value += in_letter
		elif in_letter == "]":
			break

		pos += 1

	return [value, pos]


## Parse a text to get the data to show it on the dialog.
##
## Returns a [ParseReturn] object with the data without BBCodes and a list of effects and colours
## positions.
##
## If there is a wrong or unsupported BBCode, will be removed.
##
## @param text The text to parse.
## @returns A [ParseReturn] object.
static func parse(text: String) -> ParsedDialog:
	var parsed_dialog := ParsedDialog.new(text)

	var regex: RegEx = RegEx.new()
	regex.compile(BBCCodes.BBC_REXP)

	while regex.search(text):
		var regex_match = regex.search(text)
		var match_start = regex_match.get_start()

		if (
			regex_match.get_group_count() != 3
			and !BBCCodes.BBC_CODES_MAP.has(regex_match.strings[1])
		):
			printerr("Wrong BBCode format")
			return parsed_dialog

		var effect = BBCCodes.BBC_CODES_MAP[regex_match.strings[1]]
		var effect_value = regex_match.strings[2]
		parsed_dialog.effects[match_start] = EffectLocation.new(effect, effect_value)

		var new_text = text.substr(0, match_start)
		var match_end = regex_match.get_end()
		new_text += text.substr(match_end)
		text = new_text

	return parsed_dialog


static func bbc_remover(text: String, regex_str: String) -> String:
	var regex := RegEx.new()
	regex.compile(regex_str)

	var out = ""
	var last_pos = 0
	for regex_match in regex.search_all(text):
		var start := regex_match.get_start()
		out += text.substr(last_pos, start - last_pos)
		last_pos = regex_match.get_end()

	out += text.substr(last_pos)
	return out
