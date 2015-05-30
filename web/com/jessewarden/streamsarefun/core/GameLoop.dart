part of streamscore;

class GameLoop
{
  num lastTick = 0;
  bool running = false;
  bool resetDirty = false;
  num pausedTime = 0;

  Stream<GameLoopEvent> stream;
  StreamController<GameLoopEvent> _streamController;
  WindowMock mock;

  GameLoop()
  {
    _streamController = new StreamController<GameLoopEvent>(onPause: _onPause,
    onResume: _onResume);
    stream = _streamController.stream.asBroadcastStream();
    mock = new WindowMock();
    mock.start();
  }

  void _onPause()
  {
    pause();
  }

  void _onResume()
  {
    start();
  }

  void tick(num time)
  {
    print("time: $time");
    if(running)
    {
      if(resetDirty)
      {
        lastTick = time;
      }

      // TODO: figure out a better pause solution; without system.getTimer(), I'm t3h lost.
      if(pausedTime != 0)
      {
        num timeElapsed = new DateTime.now().millisecondsSinceEpoch - pausedTime;
        lastTick -= timeElapsed;
        time -= timeElapsed;
        pausedTime = 0;
      }

      num difference = time - lastTick;
      lastTick = time;
      _streamController.add(new GameLoopEvent(GameLoopEvent.TICK, time: difference));
      _request();
    }
  }

  void pause()
  {
    running = false;
    pausedTime = new DateTime.now().millisecondsSinceEpoch;
    _streamController.add(new GameLoopEvent(GameLoopEvent.PAUSED));
  }

  void reset()
  {
    resetDirty = true;
    _streamController.add(new GameLoopEvent(GameLoopEvent.RESET));
  }

  void start()
  {
    if(running == false)
    {
      running = true;
      _request();
      _streamController.add(new GameLoopEvent(GameLoopEvent.STARTED));
    }
  }

  void _request()
  {
    mock.animationFrame.then(tick);
  }
}