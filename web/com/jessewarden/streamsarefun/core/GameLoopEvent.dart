part of streamscore;

class GameLoopEvent
{
  static const String STARTED = "started";
  static const String PAUSED = "paused";
  static const String RESET = "reset";
  static const String TICK = "tick";

  String type;
  num time;

  GameLoopEvent(String type, {num time: null})
  {
    this.type = type;
    this.time = time;
  }
}