part of battlecore;

class BattleTimer implements Animatable
{
	static const String MODE_PLAYER = "player";
	static const String MODE_MONSTER = "monster";

	static const int EFFECT_NORMAL = 96;
	static const int EFFECT_HASTE = 126;
	static const int EFFECT_SLOW = 48;

	final int MAX = 65536;
	final int TIME_SLICE = 33;

	num lastTick = 0;

	int speed = 200;
	int battleSpeed = 10;
	int effect = EFFECT_NORMAL;
	String _mode = null;
	StateMachine fsm;

	int gauge = 0;
	Function modeFunction = null;

	StreamController<BattleTimerEvent> _streamController;
	Stream<BattleTimerEvent> stream;

	num get progress
	=> gauge / MAX;

	String get mode
	=> _mode;

	bool _enabled = true;
	bool get enabled => _enabled;
	bool set enabled(bool newValue)
	{
		_enabled = newValue;
		if(newValue == true)
		{
			fsm.changeState('active');
		}
		else
		{
			fsm.changeState('disabled');
		}
	}

	void set mode(String newValue)
	{
		_mode = newValue;
		if (_mode == MODE_PLAYER)
		{
			modeFunction = onCharacterTick;
		} else
		{
			modeFunction = onMonsterTick;
		}
	}

	BattleTimer(String mode)
	{
		this.mode = mode;

		_streamController = new StreamController.broadcast();
		stream = _streamController.stream;

		fsm = new StateMachine();
		fsm.addState('active');
		fsm.addState('complete');
		fsm.addState('disabled');
		fsm.initialState = 'active';
	}

	void reset()
	{
		gauge = 0;
		lastTick = 0;
	}

	bool advanceTime(num time)
	{
		switch(fsm.currentState.name)
		{
			case 'active':
				return _advanceActiveTime(time);

			case 'complete':
				return false;

			case 'disabled':
				return true;
		}
	}

	bool _advanceActiveTime(num time)
	{
		Function modeFunc = modeFunction;
		if (modeFunc == null)
		{
			return false;
		}

		bool tickResult = false;
		lastTick = lastTick + time;
		int result = (lastTick / TIME_SLICE);
//		if(mode == MODE_MONSTER)
//		{
//			print("================");
//			print("time: $time, lastTick: $lastTick");
//			print("lastTick / TIME_SLICE: $result");
//		}
		if (result > 0)
		{
			num remainder = lastTick - (result * TIME_SLICE);
			lastTick = remainder;
			// TODO: if someone pauses this while running modeFunc
			while (result > 0)
			{
				tickResult = modeFunc();
				result--;
			}
			if(tickResult == false)
			{
				return false;
			}
			num percentage = gauge / MAX;
//			print("percentage: $percentage");
			if (percentage == null)
			{
				throw "This can't be null home slice dice mice thrice lice kites... kites doesn't rhyme.";
			}
			_streamController.add(new BattleTimerEvent(BattleTimerEvent.PROGRESS, this, percentage: percentage));
			return tickResult;
		}
		return true;
	}

	bool onCharacterTick()
	{
		num result = (((effect * (speed + 20)) / 16));
		gauge += result.round();
		if (gauge >= MAX)
		{
			gauge = MAX;
			fsm.changeState("complete");
			print("BattleTimer::complete");
			_streamController.add(new BattleTimerEvent(BattleTimerEvent.COMPLETE, this));
			return false;
		}
		return true;
	}

	// ((96 * (Speed + 20)) * (255 - ((Battle Speed - 1) * 24))) / 16
	bool onMonsterTick()
	{
		/* 2nd try and I still failed, lol! I think home slice has like a * where he meant to have a /... andyway,
		I cannot for the life of me get a reasonable value from this calculation.
		 */
//		print("monster tick");
//		num result = ((effect * (speed + 20)) * (255 - ((battleSpeed - 1) * 24))) / 16;
//		gauge += result.round();
//		print("result: $result and gauge: $gauge");
//		if(gauge >= MAX)
//		{
//			gauge = MAX;
//			_streamController.add(new BattleTimerEvent(BattleTimerEvent.COMPLETE, this));
//		}

//					  ((96     * (Speed + 20)) * (255 - ((Battle Speed - 1) * 24))) / 16

		num result = (((effect * (speed + 20)) / 16));
//		num result = ((effect * (speed + 20)) * (255 - ((battleSpeed - 1) * 24))) / 16;
//		print("result: $result");
//		print("result1: $result1");
		gauge += result.round();
		// dispatch progress = gauge / MAX;
		if (gauge >= MAX)
		{
//			print("gauge is larger than MAX, dispatching complete.");
			// dispatch complete
			gauge = MAX;
			fsm.changeState("complete");
			_streamController.add(new BattleTimerEvent(BattleTimerEvent.COMPLETE, this));
			return false;
		}
		return true;
	}
}
