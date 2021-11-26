
namespace Suada
{
  internal class Portrait
  {
    private readonly string _portrait;
    public string PortraitFile { get { return _portrait; } }

    private int _animationTrigger;
    public int AnimationTrigger { set { _animationTrigger = value; } get { return _animationTrigger; } }

    private readonly int _animationTriggerRangeX;
    public int RangeX { get { return _animationTriggerRangeX; } }

    private readonly int _animationTriggerRangeY;
    public int RangeY { get { return _animationTriggerRangeY; } }

    public Portrait()
    {
      _portrait = null;
      _animationTrigger = 120;
      _animationTriggerRangeX = 100;
      _animationTriggerRangeY = 100;
    }

    public Portrait(
      string portrait,
      int animationTrigger = 120,
      int animationTriggerRangeX = 100,
      int animationTriggerRangeY = 200)
    {
      _portrait = portrait;

      _animationTrigger = animationTrigger;

      _animationTriggerRangeX = animationTriggerRangeX;
      _animationTriggerRangeY = animationTriggerRangeY;
    }
  }
}