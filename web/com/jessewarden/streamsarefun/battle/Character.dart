part of battlecore;

class Character
{
	int speed;
	int strength;
	int stamina;
	int magicBlock;
	int vigor;
	int defense;
	int magicalDefense;
	bool dead = false;
	int level = 1;

	int ID = -1;
	static int INCREMENT = 0;

	BattleState _battleState;
	int _hitPoints = 0;

	int get hitPoints => _hitPoints;
	void set hitPoints(int newValue)
	{
		num oldValue = _hitPoints;
		if(_hitPoints != newValue)
		{
			_hitPoints = newValue;
			CharacterEvent hitPointsEvent = new CharacterEvent(type: CharacterEvent.HIT_POINTS_CHANGED, target: this);
			hitPointsEvent.changeAmount = oldValue - newValue;
			_controller.add(new CharacterEvent(type: CharacterEvent.HIT_POINTS_CHANGED, target: this));
			if(oldValue <= 0 && newValue >= 1)
			{
				_controller.add(new CharacterEvent(type: CharacterEvent.NO_LONGER_SWOON, target: this));
			}
			else if(oldValue >= 1 && newValue <= 0)
			{
				_controller.add(new CharacterEvent(type: CharacterEvent.SWOON, target: this));
			}
		}
	}

	BattleState get battleState => _battleState;
	void set battleState(BattleState newState)
	{
		if(newState == _battleState)
		{
			return;
		}
		BattleState oldState = _battleState;
		_battleState = newState;
		_controller.add(new CharacterEvent(
			type: CharacterEvent.BATTLE_STATE_CHANGED,
			target: this,
			oldBattleState: oldState,
			newBattleState: newState));
	}

	Row _row = Row.FRONT;
	Row get row => _row;
	void set row(Row newRow)
	{
		if(newRow == _row)
		{
			return;
		}
		Row oldRow = _row;
		_row = newRow;
		_controller.add(new CharacterEvent(
			type: CharacterEvent.ROW_CHANGED,
			target: this,
			oldRow: oldRow,
			newRow: newRow));
	}

	StreamController<CharacterEvent> _controller;
	Stream<CharacterEvent> stream;

	Character({int this.speed: 80,
	          int this.strength: 10,
	          int this.stamina: 10,
	          int this.magicBlock: 10,
	          int this.vigor: 10,
				Row row: Row.FRONT,
				int hitPoints: 0,
	          int this.defense: 10,
	          int this.magicalDefense: 10,
	          bool this.dead: false,
	          int this.level: 3})
	{
		_row = row;
		_hitPoints = hitPoints;

		_controller = new StreamController();
		stream = _controller.stream.asBroadcastStream();
		ID = INCREMENT++;
	}

	void toggleRow()
	{
		if(row == Row.FRONT)
		{
			row = Row.BACK;
		}
		else
		{
			row = Row.FRONT;
		}
	}

}