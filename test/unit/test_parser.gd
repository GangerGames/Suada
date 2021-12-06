extends "res://addons/gut/test.gd"

const BBCParser = preload("res://Nodes/BBCParser/BBCParser.gd")


func test_parsed_ok():
	var parsed_obj = BBCParser.parse(
		(
			"Normal [shake]shake[/shake] [wave]wave[/wave] [colour=f9ff42]colour[/colour] "
			+ "[colour=42ff6b55]colour with alpha[/colour] "
			+ "[wave_colour]colour wave[/wave_colour] [spin]spin[/spin] "
			+ "[spin][colour=c007bd]spin colour[/colour][/spin] [pulse]pulse[/pulse] "
			+ "[flicker]flicker[/flicker] [wave]wave[/wave]"
		),
		Color.white
	)

	assert_eq(
		parsed_obj.parsed_text,
		"Normal shake wave colour colour with alpha colour wave spin spin colour pulse flicker wave"
	)
	assert_eq(parsed_obj.effects.size(), 16)
	assert_eq(parsed_obj.colours.size(), 6)
