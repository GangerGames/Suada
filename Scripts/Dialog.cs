using Godot;
using System.Collections.Generic;

namespace Suada
{
  internal class Dialog
  {
    private readonly string _text;
    public string Text { get { return _text; } }

    private readonly Portrait _portrait;
    public Portrait PortraitObject { get { return _portrait; } }

    private readonly int _type;
    public int Type { get { return _type; } }

    private readonly List<(int, int)> _effects;
    public List<(int, int)> Effects { get { return _effects; } }

    private readonly List<(int, Color)> _colours;
    public List<(int, Color)> Colours { get { return _colours; } }

    public Dialog()
    {
      _text = "";
      _portrait = null;
      _type = -1;
      _effects = new List<(int, int)>();
      _colours = new List<(int, Color)>();
    }

    public Dialog(string text, string portrait, int type, List<(int, int)> effects,
      List<(int, Color)> colours)
    {
      _text = text;
      _portrait = new Portrait(portrait);
      _type = type;
      _effects = effects;
      _colours = colours;
    }
  }
}