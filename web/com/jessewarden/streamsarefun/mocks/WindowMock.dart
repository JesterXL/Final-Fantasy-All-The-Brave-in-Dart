part of mocks;

/* Emulate window since dart:html can't be unit tested, so stupid... */

class WindowMock
{
	Stopwatch stopwatch;
	Timer timer;
	bool running = false;

	StreamController<num> _streamController;
	List callbacks = new List();

	WindowMock()
	{
		_streamController = new StreamController<num>(onPause: _onPause, onResume: _onResume);
		stopwatch = new Stopwatch();
		timer = new Timer.periodic(new Duration(milliseconds: 20), onTimer);
	}

	Future<num> get animationFrame
	{
		var completer = new Completer<num>.sync();
		callbacks.add((time)
		{
			completer.complete(time);
		});
		return completer.future;
	}

	void _onPause()
	{
		pause();
	}

	void _onResume()
	{
		start();
	}

	void onTimer(Timer timer)
	{
//		print("onTimer");
		if (running == true)
		{
//			print("we're running, so adding milliseconds: ${stopwatch.elapsedMilliseconds}");
			_streamController.add(stopwatch.elapsedMilliseconds);
			if(callbacks.length > 0)
			{
//				print("found a callback, so calling it");
				var callback = callbacks.removeLast();
				callback(stopwatch.elapsedMilliseconds);
			}
		}
	}

//  void tick(num time)
//  {
//    if(running)
//    {
//      if(resetDirty)
//      {
//        lastTick = time;
//      }
//
//      // TODO: figure out a better pause solution; without system.getTimer(), I'm t3h lost.
//      if(pausedTime != 0)
//      {
//        num timeElapsed = new DateTime.now().millisecondsSinceEpoch - pausedTime;
//        lastTick -= timeElapsed;
//        time -= timeElapsed;
//        pausedTime = 0;
//      }
//
//      num difference = time - lastTick;
//      lastTick = time;
//      _streamController.add(new GameLoopEvent(GameLoopEvent.TICK, time: difference));
//      _request();
//    }
//  }

	void pause()
	{
		running = false;
		stopwatch.stop();
	}

	void reset()
	{
		stopwatch.reset();
	}

	void start()
	{
		if (running == false)
		{
			running = true;
			stopwatch.start();
		}
	}
}