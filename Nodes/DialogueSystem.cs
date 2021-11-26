using Godot;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Suada
{
  public class DialogueSystem : Node2D
  {
    #region Customizable
    private int _interactKey = (int)KeyList.E;
    private bool _interactKeyPressed = false;
    private int _upKey = (int)KeyList.Up;  // For dialogue _choices
    private int _upKeyPressed = 0;
    private int _downKey = (int)KeyList.Down;  // For dialogue _choices
    private int _downKeyPressed = 0;

    private const int _scaleFactor = 1;
    private readonly float _xOffset = 10 * _scaleFactor;
    private readonly float _yOffset = 18 * _scaleFactor;

    private Node2D _portraitFrameBox = null;
    private Node2D _dialogueBox = null;
    private Node2D _nameBox = null;
    private Node2D _finishEffect = null;

    private AnimatedSprite _portraitFrame = null;

    private AudioStreamPlayer2D _audioPlayer = null;

    // private Sprite _emoteSprite = null;

    [Export(PropertyHint.File, "*.ogg,*.wav")]
    private AudioStream _voiceSndEffect = null;
    // private AudioStream _choiceSndEffect = null;
    // private AudioEffect _selectSndEffect = null;

    [Export]
    private Color _defaultCol = Colors.White;
    // [Export]
    // private Color _choiceCol = Colors.Yellow;
    // [Export]
    // private Color _selectCol = Colors.Orange;
    // [Export]
    // private Color _nameCol = Colors.Orange;

    [Export(PropertyHint.File, "*.res,*.tres")]
    private DynamicFont _defaultFont = ResourceLoader.Load<DynamicFont>("res://Assets/Fonts/FixedsysExcelsior.tres");

    // private int _prioritySndEffect = 5;

    // You only need to change this if you are using animated sprites
    // Set this to equal the frame where the mouth is OPEN for talking sprites
    // private int _openMouthFrame = 1;
    #endregion

    #region Setup
    private readonly int _targetFps = Engine.TargetFps != 0 ? Engine.TargetFps : 60;

    private bool _exiting = false;

    // private int _portraitTalk = -1;
    // private int _portraitTalkN = -1;
    // private int _portraitTalkS = -1;
    // private int _portraitTalkC = 0;

    // private int _portraitIdle = -1;
    // private int _portraitIdleN = -1;
    // private int _portraitIdleS = -1;
    // private int _portraitIdleC = 0;

    // private int _emotes = -1;
    // private Node _speaker = null;

    private float _boxHeight = -1;
    private float _boxWidth = -1;
    private float _guiWidth = -1;
    private float _guiHeight = -1;
    private float _gbDiff = -1;
    private float _portraitWidth = -1;
    private float _finishedeNum = -1;
    private float _finishedeSpd = -1;

    private float _dialogBoxX = -1;
    private float _dialogBoxY = -1;

    private float _nameBoxX = -1;
    private float _nameBoxY = -1;
    private float _nameBoxTextX = -1;
    private float _nameBoxTextY = -1;

    private float _finishedeX = -1;
    private float _finishedeY = -1;

    private char _letter;
    private float _charCount = 0;
    // private int _charCountF = 0;
    private float _finishedeCount = 0;
    // private int _textSpeed = 0;
    // private int _textSpeedC = 0;
    private float _audioC = 0;
    private int _page = 0;
    private float _strLen = -1;
    // private bool _pause = false;
    private bool _chosen = false;
    private int _choice = 0;

    private readonly List<Dialog> _conversation = new List<Dialog>();

    // private Node _creator = null;
    private string _textNE = "";
    private Dictionary<int, int> _breakpoints = new Dictionary<int, int>();
    private int[][] _nextLine = { };
    // private Color _textCol = Colors.White;
    // private int _emotion = 0;

    // private int _voice = 1;
    // private int _font = 1;

    private float _charSize = 1;
    private float _charHeight = 1;

    private readonly RandomNumberGenerator _randomGen = new RandomNumberGenerator();
    private Vector2 _drawVector = new Vector2();
    private Color _drawColor = new Color();

    private bool _pause = false;
    private int _animationCnt;
    private int _animationTrigger;
    private int _animationTriggerRangeX;
    private int _animationTriggerRangeY;

    // Effect variables
    // private int _effectsP;
    private int _cntEffect = 0;
    private readonly int _amplitude = 4;
    private readonly int _freq = 2;
    private Vector2 _effectVector = new Vector2(Vector2.One);
    // private int _ec = 0;  // Effect c

    // private Timer _timer = new Timer();
    #endregion

    public override void _Ready()
    {
      _dialogueBox = GetNode<Node2D>("DialogueBox");
      _portraitFrameBox = GetNode<Node2D>("PortraitFrame");
      _nameBox = GetNode<Node2D>("NameBox");
      _finishEffect = GetNode<Node2D>("FinishEffect");

      _finishEffect.Hide();

      _portraitFrame = GetNode<AnimatedSprite>("PortraitFrame/PortraitSprite");
      _portraitFrame.Connect("animation_finished", this, nameof(OnPortraitAnimationFinished));

      _audioPlayer = GetNode<AudioStreamPlayer2D>("DialogueAudioPlayer");

      var portraitFrameTexture = GetNode<Sprite>("PortraitFrame/PortraitFrameSprite").Texture;
      var dialogueBoxTexture = GetNode<Sprite>("DialogueBox/DialogueBoxSprite").Texture;
      var nameBoxTexture = GetNode<Sprite>("NameBox/NameBoxSprite").Texture;

      _charSize = _defaultFont.GetStringSize("M").x;
      _charHeight = _defaultFont.GetStringSize("M").y;

      _boxWidth = dialogueBoxTexture.GetWidth() * _scaleFactor;
      _boxHeight = dialogueBoxTexture.GetHeight() * _scaleFactor;

      var viewport = GetViewport().GetVisibleRect();
      _guiWidth = viewport.Size.x;
      _guiHeight = viewport.Size.y;

      _gbDiff = _guiWidth - _boxWidth;
      _portraitWidth = portraitFrameTexture.GetWidth() * _scaleFactor;
      _finishedeNum = 0;
      _finishedeSpd = 15 / 60;

      _dialogBoxX = _gbDiff + _portraitWidth;
      _dialogBoxY = _guiHeight - (_boxHeight / 2) - 4;

      _nameBoxX = _dialogBoxX - (_boxWidth / 2) + (nameBoxTexture.GetWidth() / 2) + (8 * _scaleFactor);
      _nameBoxY = _dialogBoxY - (_boxHeight / 2) - ((nameBoxTexture.GetHeight() - 1) / 2);
      _nameBoxTextX = _nameBoxX + (nameBoxTexture.GetWidth() * _scaleFactor / 2);
      _nameBoxTextY = _nameBoxY + _yOffset;

      _finishedeX = _dialogBoxX + (_boxWidth / 2) - _xOffset;
      _finishedeY = _dialogBoxY - (_boxHeight / 2) - _yOffset;

      // Set dialogue box position.
      _dialogueBox.Position = new Vector2(_dialogBoxX, _dialogBoxY);

      // Set portrait position.
      _portraitFrameBox.Position = new Vector2(
          _dialogBoxX - (_boxWidth / 2) - (_portraitWidth / 2),
          _dialogBoxY);

      // Set name box position.
      _nameBox.Position = new Vector2(_nameBoxX, _nameBoxY);

      var res = BBCParser.BBCParser.Parse("Normal [shake]shake[/shake] [wave]wave[/wave] "
        + "[colour=red]colour[/colour] [wave_colour]colour wave[/wave_colour] [spin]spin[/spin] "
        + "[pulse]pulse[/pulse] [flicker]flicker[/flicker]", _defaultCol);

      _conversation.Add(
        new Dialog(res.Item1,
                   "res://addons/Suada/Assets/Portrait_base_anim.tres",
                   0,
                   res.Item2,
                   res.Item3));

      Setup();
    }

    public override void _Process(float delta)
    {
      base._Process(delta);

      // We check the _type of dialogue to see if it is:
      // 1) "normal"
      // 2) a player _choice dialogue.
      if (_conversation[_page].Type == 0)
      {
        if (_interactKeyPressed)
        {
          if (_charCount < _strLen)
          {
            // If we haven't "_typed out" all the _letters,
            // immediately "_type out" all _letters (works as a "skip").
            _charCount = _textNE.Length;
          }
          else if (_page + 1 < _conversation.Count)
          {
            // Only increase _page IF _page + 1,is less than the total number of entries.
            //TODO(feserr) Launch other dialogue function
            switch (_nextLine[_page][0])
            {
              case -1:
                QueueFree();
                return;
              case 0:
                {
                  SetPortrait();
                  ++_page;
                  break;
                }
              default:
                _page = _nextLine[_page][0];
                break;
            }
            Setup();
          }
          else
          {
            //TODO(feserr) Launch other dialogue function
            HandleExit(1000);
          }

          _interactKeyPressed = false;
        }
      }
      else
      {
        if (_chosen)
        {
          return;
        }

        if (_interactKeyPressed)
        {
          _chosen = true;
          HandleDialogueChoice();
          _interactKeyPressed = false;
          // alarm[2] = 10;
          // audio_play_sound(_selectSndEffect, priority_snd_effect, false);
        }

        // Change _choice
        int change__choice = _downKeyPressed - _upKeyPressed;
        if (change__choice != 0)
        {
          _choice += change__choice;
          // audio_play_sound(_choiceSndEffect, priority_snd_effect, false)
        }

        if (_choice < 0)
        {
          _choice = _conversation[_page].Text.Length - 1;
        }
        else if (_choice > _conversation[_page].Text.Length - 1)
        {
          _choice = 0;
        }
      }

      Update();
    }

    public override void _Draw()
    {
      base._Draw();

      if (_charCount >= _strLen && !_portraitFrame.Playing && ++_animationCnt >= _animationTrigger)
      {
        _portraitFrame.Play();
      }

      if (_charCount < _strLen && !_pause)
      {
        // Get Current Character
        char letter = _textNE[Mathf.FloorToInt(_charCount)];

        #region Check for Pause, Voice, Animated Sprite
        switch (letter)
        {
          case ' ':
            break;
          case ',':
          case '.':
            _pause = true;
            HandlePause(100);
            break;
          case '?':
          case '!':
            _pause = true;
            HandlePause(200);
            break;
          default:
            //Play the voice sound every 2 frames (you can change this number if this is too often)
            const int audio_increment = 2;

            #region Animated Sprite
            if (true) // if there is portrait.
            {
              if (!_pause)
              {
                // To include the consideration of vowels.
                char l = char.ToLower(letter);
                if (l == 'a' || l == 'e' || l == 'i' || l == 'o' || l == 'u')
                {
                  _portraitFrame.Animation = "Talk";
                  _portraitFrame.Play();
                  if (_charCount > _audioC)
                  {
                    _audioPlayer.Stream = _voiceSndEffect;
                    _audioPlayer.Play();
                    _audioC = _charCount + audio_increment;
                  }
                }
              }
            }
            #endregion
            // else if (charCount >= audio_c)
            // {
            //   audio_play_sound(voice[page], 1, false);
            //   audio_c = charCount + audio_increment;
            // }
            break;
        }
        #endregion

        if (_charCount < _textNE.Length)
        {
          _charCount += 0.25f;
        }

      }

      // Color col = _defaultCol;
      int cc = 0;
      float xx = _dialogBoxX + _xOffset;
      float yy = _dialogBoxY - (_boxHeight / 2) + _yOffset;
      int cx = 0;
      int cy = 0;
      // int ty = 0;
      int by = 0;
      int bp_len = -1;
      int nextSpace = 0;
      // int effectsC = 0;
      // int textColC = 0;

      int effect = 0;
      int itEffect = 0;
      var effects = _conversation[_page].Effects;

      Color colour = Colors.White;
      int itColours = 0;
      var colours = _conversation[_page].Colours;

      ++_cntEffect;

      // Check if there are breakpoints in this string, if there are save their lengths.
      if (_breakpoints.Count != 0)
      {
        bp_len = _breakpoints.Count;
        nextSpace = _breakpoints[by];
        ++by;
      }

      int char_cnt = 0;
      while (char_cnt < _charCount)
      {
        // Get current effect.
        if (itEffect < effects.Count && char_cnt >= effects[itEffect].Item1)
        {
          effect = effects[itEffect].Item2;
          ++itEffect;
        }

        // Get current colour.
        if (itColours < colours.Count && char_cnt >= colours[itColours].Item1)
        {
          colour = colours[itColours].Item2;
          ++itColours;
        }

        // Get current letter.
        _letter = _textNE[cc];

        // Get next space, deal with new lines.
        if (bp_len != -1 && cc == nextSpace)
        {
          ++cy;
          cx = 0;
          if (by < bp_len)
          {
            nextSpace = _breakpoints[by];
            ++by;
          }
        }

        // Set the position for drawing.
        _drawVector.x = xx + (cx * _charSize);
        _drawVector.y = yy + (cy * _charHeight);
        _drawColor = colour;
        _effectVector = Vector2.One;

        float rotation = 0;

        switch (effect)
        {
          case 1:  // Shake
            _drawVector.x += _randomGen.RandfRange(-1, 1);
            _drawVector.y += _randomGen.RandfRange(-1, 1);
            break;
          case 2:  // Wave
            {
              float shift = Mathf.Sin(_cntEffect * Mathf.Pi * _freq / _targetFps) * _amplitude;
              _drawVector.y += shift;
              break;
            }
          case 3:  // Colour shift
            {
              float colorValue = _cntEffect / 255f;
              float colorNormalized = colorValue - Mathf.Floor(colorValue);
              _drawColor = Color.FromHsv(colorNormalized, 1f, 1f);
              break;
            }
          case 4:  // Wave and colour shift
            {
              float shift = Mathf.Sin(_cntEffect * Mathf.Pi * _freq / _targetFps) * _amplitude;
              _drawVector.y += shift;
              float colorValue = _cntEffect / 255f;
              float colorNormalized = colorValue - Mathf.Floor(colorValue);
              _drawColor = Color.FromHsv(colorNormalized, 1f, 1f);
              break;
            }
          case 5:  // Spin
            {
              float val = _cntEffect + cc;
              float shift = Mathf.Sin(val * Mathf.Pi * _freq / _targetFps);
              rotation = shift / 4;
              break;
            }
          case 6:  // Pulse
            {
              float val = _cntEffect + cc;
              float shift = 0.5f * (1 + Mathf.Sin(val * Mathf.Pi * _freq / _targetFps));
              _effectVector.x = shift;
              _effectVector.y = shift;
              break;
            }
          case 7:  // Flicker
            {
              float val = _cntEffect + cc;
              float shift = Mathf.Sin(val * Mathf.Pi * _freq / _targetFps) + _randomGen.RandfRange(-1, 1);
              _drawColor.a = shift;
              break;
            }
          case 0:
          default:
            break;
        }

        DrawSetTransform(_drawVector, rotation, _effectVector);
        DrawString(_defaultFont, Vector2.Zero, _letter.ToString(), _drawColor);

        ++cc;
        ++cx;

        ++char_cnt;
      }

      #region Draw "Finished" effect
      if(_charCount >= _strLen)
      {
        var shift = Mathf.Sin((_cntEffect + cc) * Mathf.Pi * _freq / _targetFps) * _amplitude;
        _finishedeCount += _finishedeSpd;
        if(_finishedeCount >= _finishedeNum)
        {
          _finishedeCount = 0;
        }

        _drawVector.x = _finishedeX + shift;
        _drawVector.y = _finishedeY;
        _finishEffect.Show();
        _finishEffect.Position = _drawVector;

        // draw_sprite(finished_effect, _finishedeCount, finishede_x + shift, finishede_y);
      }
      else
      {
        _finishEffect.Hide();
      }
      #endregion
    }

    public override void _Input(InputEvent @event)
    {
      base._Input(@event);

      _interactKeyPressed = Input.IsKeyPressed(_interactKey);
      _upKeyPressed = Input.IsKeyPressed(_upKey) ? 1 : 0;
      _downKeyPressed = Input.IsKeyPressed(_downKey) ? 1 : 0;
    }

    private void OnPortraitAnimationFinished()
    {
      _portraitFrame.Stop();
      _portraitFrame.Animation = "Idle";
      _animationCnt = 0;
      _animationTrigger = _randomGen.RandiRange(_animationTriggerRangeX, _animationTriggerRangeY);
    }

    private void Setup()
    {
      // Must be done AFTER the handover occurs, so frame after created, and after every text _page change.

      // Reset variables
      _charCount = 0;
      // _finishedeCount = 0;
      // _portraitTalkC = 0;
      // _portraitIdleC = 0;
      // _textSpeedC = 0;
      // _audioC = 0;
      // _charCountF = 0;
      // effects_p = effects[_page];
      // text_col_p = text_col[_page];

      // text_speed_al = array_length_non_excp(text_speed[_page]) / 2;
      // effects_al = array_length_non_excp(effects[_page]) / 2;
      // text_col_al = array_length_non_excp(text_col[_page]) / 2;

      if (_conversation[_page].PortraitObject == null)
      {
        _dialogBoxX = (_gbDiff / 2);
        _finishedeX = _dialogBoxX + _boxWidth - _xOffset;
      }
      else
      {
        _dialogBoxX = (_gbDiff / 2) + (_portraitWidth / 2);
        _finishedeX = _dialogBoxX + _boxWidth - _xOffset;
      }

      // draw_set_font(font[_page])
      _charSize = _defaultFont.GetStringSize("M").x;  // Gets new charSize under current font.
                                                      // charHeight = _defaultFont.GetStringSize("M").x;  // Same for width.

      // GET THE _breakpoints AND TEXT EFFECTS
      // Again only need to do this if our CURRENT _page is "normal". Separated from above for readability.
      if (_conversation[_page].Type == 0)
      {
        _textNE = _conversation[_page].Text;
        _strLen = _textNE.Length;

        // Get variables ready
        int by = 0;
        // int ty = 0;
        int cc = 1;
        int breakpnt = 0;
        int next_space = 0;
        // char char_at = ' ';
        float txtwidth = _boxWidth - (2 * _xOffset);
        // float char_max = txtwidth / _charSize;

        // Reset the text effects and _breakpoints arrays
        // text_effects = -1
        _breakpoints.Clear();

        // Loop through and save the effect positions and _breakpoints
        float itStrLen = _strLen;
        while (itStrLen-- > 0)
        {
          // Get next space, deal with new lines
          if (cc >= next_space)
          {
            next_space = cc;
            while (next_space < _strLen && _textNE[next_space].CompareTo(' ') != 0)
            {
              ++next_space;
            }

            var linewidth = (next_space - breakpnt) * _charSize;
            if (linewidth >= txtwidth)
            {
              breakpnt = cc;
              _breakpoints.Add(by, cc);
              ++by;
            }
          }

          ++cc;
        }
      }

      // Get the emotes
      // if (emotes != -1 and emotes[_page] != -1):
      //     var sp = speaker[_page]; var ep = emotes[_page];
      //     var obj = instance_create_layer(sp.x,sp.y-sp.sprite_height-2,"Text",obj_emote);
      //     var spr = _emoteSprite;
      //     with (obj):
      //         sprite_index = spr;
      //         image_index = ep;
      //         creator = sp;
      //         mode = 1;

      SetPortrait();
    }

    private void SetPortrait()
    {
      var portrait = _conversation[_page].PortraitObject;

      if (portrait != null)
      {
        _portraitFrame.Frames = ResourceLoader.Load<SpriteFrames>(portrait.PortraitFile);
        _animationTrigger = portrait.AnimationTrigger;
        _animationTriggerRangeX = portrait.RangeX;
        _animationTriggerRangeY = portrait.RangeY;
      }
    }

    private async void HandlePause(int time)
    {
      await Task.Delay(time);
      _pause = false;
    }

    private async void HandleExit(int time)
    {
      if (_exiting) return;

      _exiting = true;
      await Task.Delay(time);
      QueueFree();
    }

    private async void HandleDialogueChoice()
    {
      await Task.Delay(100);

      // var cv = executeScript[page];
      // if (cv is_array(cv))
      // {
      //   cv = cv[choice];
      //   var len = array_length(cv)-1;
      //   var cva = array_create(len, 0);
      //   array_copy(cva, 0, cv, 1, len);
      //   script_execute_alt(cv[0], cva);
      // }

      // Update page.
      if (_page + 1 < _conversation.Count)
      {
        var nl = _nextLine[_page];
        switch (nl[_choice])
        {
          case -1:
            QueueFree();
            return;
          case 0:
            ++_page;
            break;
          default:
            _page = nl[_choice];
            break;
        }
        Setup();

      }
      else
      {
        QueueFree();
      }

      _chosen = false;
    }
  }
}
