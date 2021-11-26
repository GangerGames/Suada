
using Godot;
using System.Collections.Generic;

namespace BBCParser
{
  public static class BBCodes
  {
    public static readonly Dictionary<string, int> BBCCodesMap = new Dictionary<string, int>()
    {
      ["colour"] = 0,
      ["shake"] = 1,
      ["wave"] = 2,
      ["colour"] = 3,
      ["wave_colour"] = 4,
      ["spin"] = 5,
      ["pulse"] = 6,
      ["flicker"] = 7,
    };

    public static readonly Dictionary<string, Color> BBCColourMap = new Dictionary<string, Color>()
    {
      ["white"] = Colors.White,
      ["red"] = Colors.Red,
    };

    public const string BBCRexp = @"\[shake|wave|colour|wave_colour|spin|pulse|flicker|colour\].*?\[/shake|wave|colour|wave_colour|spin|pulse|flicker|colour\]";

    public const string BBCAnyRexp = @"\[.*\].*?\[/.*\]";
  }
}