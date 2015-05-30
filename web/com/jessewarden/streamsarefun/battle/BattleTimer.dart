part of battlecore;

class BattleTimer
{
  static const String MODE_CHARACTER = "character";
  static const String MODE_MONSTER = "monster";

  static const int EFFECT_NORMAL = 96;
  static const int EFFECT_HASTE = 126;
  static const int EFFECT_SLOW = 48;

  final int MAX = 65536;
  final int TIME_SLICE = 33;

  num lastTick = 0;

  int speed = 0;
  int battleSpeed = 128;
  int effect = EFFECT_NORMAL;
  String _mode = null;

  int gauge = 0;
  Function modeFunction = null;
  bool _enabled = true;
  bool running = false;

  StreamController<BattleTimerEvent> _streamController;
  Stream<BattleTimerEvent> stream;
  Stream<GameLoopEvent> _gameLoopStream;
  StreamSubscription _gameLoopStreamSubscription;

  num get progress => gauge / MAX;

  bool get enabled => _enabled;
  void set enabled(bool newValue) {
    _enabled = newValue;
    if (_enabled == false) {
      pause();
    }
  }

  String get mode => _mode;
  void set mode(String newValue) {
    _mode = newValue;
    if (_mode == MODE_CHARACTER) {
      modeFunction = onCharacterTick;
    } else {
      modeFunction = onMonsterTick;
    }
  }

  BattleTimer(Stream<GameLoopEvent> _gameLoopStream, String mode)
  {
    _streamController = new StreamController<BattleTimerEvent>(onPause: _onPause, onResume: _onResume);
    stream = _streamController.stream;
    this._gameLoopStream = _gameLoopStream;
    this.mode = mode;
  }

  void _onPause()
  {
    pause();
  }

  void _onResume()
  {
    start();
  }

  void startListenToGameLoop()
  {
    if (_gameLoopStreamSubscription == null) {
      _gameLoopStreamSubscription = _gameLoopStream
      .where((GameLoopEvent event)
      {
        return event.type == GameLoopEvent.TICK;
      })
      .handleError((Error error)
      {
        print("BattleTimer, startListenToGameLoop, error: " + error.toString());
      })
      .listen((GameLoopEvent event)
      {
        tick(event.time);
      });

    }
  }

  void stopListenToGameLoop()
  {
    _gameLoopStreamSubscription.cancel();
    _gameLoopStreamSubscription = null;
  }

  bool start()
  {
    if (enabled == false)
    {
      return false;
    }
    if (running == false)
    {
      running = true;
      startListenToGameLoop();
      _streamController.add(new BattleTimerEvent(BattleTimerEvent.STARTED, this));
    }
    return true;
  }

  void pause()
  {
    if(running)
    {
      running = false;
      stopListenToGameLoop();
      _streamController.add(new BattleTimerEvent(BattleTimerEvent.PAUSED, this));
    }
  }

  void reset()
  {
    pause();
    gauge = 0;
    lastTick = 0;
    _streamController.add(new BattleTimerEvent(BattleTimerEvent.RESET, this));
  }

  void tick(num time)
  {
    Function modeFunc = modeFunction;
    if (modeFunc == null) {
      return;
    }

    lastTick = lastTick + time.round();
    num result = lastTick / TIME_SLICE;
    int resultInt = (lastTick / TIME_SLICE).floor();
    if (result > 0) {
      num remainder = lastTick - (result * TIME_SLICE);
      lastTick = remainder;
      // TODO: if someone pauses this while running modeFunc
      // we should respect this... this should be a Stream
      // so we can respect subscriber control
      while (result > 0) {
        modeFunc();
        result--;
      }
      num percentage = gauge / MAX;
//			print("gauge: $gauge, MAX: $MAX, percentage: $percentage");
//			print("---percentage: $percentage");
      if(percentage == null)
      {
        throw "This can't be null home slice dice mice thrice lice kites... kites doesn't rhyme.";
      }
      _streamController.add(new BattleTimerEvent(BattleTimerEvent.PROGRESS, this, percentage: percentage));
    }
  }

  void dispose()
  {
    running = false;
    stopListenToGameLoop();
  }

  void onCharacterTick()
  {
//		print("BattleTimer::onCharacterTick, effect: $effect, speed: $speed");
    num result = (((effect * (speed + 20)) / 16));
    gauge += result.round();
    // dispatch progress = gauge / MAX;
    if (gauge >= MAX)
    {
      // dispatch complete
      gauge = MAX;
      _streamController.add(new BattleTimerEvent(BattleTimerEvent.COMPLETE, this));
    }
  }

  void onMonsterTick()
  {
    //		-- BUG: I don't get why this algo doesn't work, I give up, moving on
    //        	function battleTimer:onMonsterTick()
    //        		print("before:", self.gauge)
    //        		-- ((96 * (Speed + 20)) * (255 - ((Battle Speed - 1) * 24))) / 16
    //        		--self.gauge = self.gauge + ((96 * (self.speed + 20)) * (255 - ((self.battleSpeed - 1) * 24))) / 16
    //        		self.gauge = self.gauge + (((self.effect * (self.speed + 20)) * (255 - ((self.battleSpeed - 1) * 24))) / 16)
    //        		print("after:", self.gauge)
    //        		self:dispatchEvent({name="onBattleTimerProgress", target=self, progress=self.gauge / self.MAX})
    //
    //        		if self.gauge >= self.MAX then
    //        			print("self.gauge:", self.gauge, ", self.MAX:", self.MAX)
    //        			self:dispatchEvent({name="onBattleTimerComplete", target=self})
    //        			self.gauge = 0
    //_streamController.add(new BattleTimerEvent(BattleTimerEvent.COMPLETE), this);
    //        		end
    //        	end
  }
}
