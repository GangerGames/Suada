
using Godot;
using static Godot.GD;

using System;
using System.Collections.Generic;

namespace BBCParser
{
  /// <summary>
  /// BBC parser class.
  /// </summary>
  public class BBCParser
  {
    private static string _original_text = "";

    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="text"></param> The text to parse.
    public BBCParser()
    {
    }

    /// <summary>
    /// Parse the text.
    /// </summary>
    /// <returns>A tuple with the text without the BBCodes, a list of Tuple
    /// of the position and effect type; and a tuple of the position and
    /// colour.</returns>
    public static Tuple<string, List<(int, int)>, List<(int, Color)>> Parse(
      string text,
      Color defaultColor)
    {
      _original_text = text;

      string parsed_text = "";
      List<(int, int)> list_effects = new List<(int, int)>();
      List<(int, Color)> list_colours = new List<(int, Color)>();

      int it = 0;
      int it_original_text = 0;
      int type = 0;
      while (it < _original_text.Length)
      {
        char letter = _original_text[it];

        if (letter != '[')
        {
          parsed_text += letter;
          ++it;
          ++it_original_text;
        }
        else
        {
          string colour = "";
          string effect = "";
          int effect_it = it + 1;
          bool is_out = false;
          while (effect_it < _original_text.Length)
          {
            char in_letter = _original_text[effect_it];

            if (effect == "colour" && in_letter != '=' && in_letter != ']')  // Get colour.
            {
              colour += in_letter;
            }
            else if (in_letter != ']' && in_letter != '/' && in_letter != '=')  // Get effect.
            {
              effect += in_letter;
            }
            else if (in_letter == '/')  // Close BBCode.
            {
              is_out = true;
            }
            else if (in_letter == ']')  // End of effect/colour.
            {
              break;
            }

            ++effect_it;
          }

          try
          {
            type = BBCodes.BBCCodesMap[effect];
            if (type != BBCodes.BBCCodesMap["colour"])
            {
              type = is_out ? -1 : type;
            }
          }
          catch (KeyNotFoundException)
          {
            PrintErr("Wrong effect BBCode: ", effect, ". Using the normal one.");
            type = is_out ? 0 : type;  // If it was a closing code, change the effect to 0.
          }

          if (type != BBCodes.BBCCodesMap["colour"])
          {
            list_effects.Add((it_original_text, type));
          }
          else if (type == BBCodes.BBCCodesMap["colour"] && is_out)
          {
            list_colours.Add((it_original_text, defaultColor));
          }
          else
          {
            try
            {
              Color new_colour = BBCodes.BBCColourMap[colour];
              list_colours.Add((it_original_text, new_colour));
            }
            catch (KeyNotFoundException)
            {
              PrintErr("Wrong colour BBCode: ", colour, ". Using the default one.");
              list_colours.Add((it_original_text, defaultColor));
            }
          }

          it = effect_it + 1;
        }
      }

      return new Tuple<string, List<(int, int)>, List<(int, Color)>>(
        parsed_text,
        list_effects,
        list_colours);
    }
  }
}