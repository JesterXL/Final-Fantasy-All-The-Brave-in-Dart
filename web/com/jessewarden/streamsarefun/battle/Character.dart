part of battlecore;

class Character
{
	static const int ROW_FRONT = 0;
	static const int ROW_BACK = 1;

	int speed;
	int strength;
	int stamina;
	int magicBlock;
	int vigor;
	int row = ROW_FRONT;
	int defense;
	int magicalDefense;
	bool dead = false;
	int level = 1;

	int ID = -1;
	static int INCREMENT = 0;

	String _battleState;
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

	String get battleState => _battleState;
	void set battleState(String newState)
	{
		if(newState == _battleState)
		{
			return;
		}
		String oldState = _battleState;
		_battleState = newState;
		_controller.add(new CharacterEvent(type: CharacterEvent.BATTLE_STATE_CHANGED, target: this, oldBattleState: oldState, newBattleState: newState));
	}

	StreamController<CharacterEvent> _controller;
	Stream<CharacterEvent> stream;

	Character({int this.speed: 0,
	          int this.strength: 0,
	          int this.stamina: 0,
	          int this.magicBlock: 0,
	          int this.vigor: 0,
	          int this.row: ROW_FRONT,
	          int this.defense: 0,
	          int this.magicalDefense: 0,
	          bool this.dead: false,
	          int this.level: 1})
	{
		_controller = new StreamController();
		stream = _controller.stream.asBroadcastStream();
		ID = INCREMENT++;
	}

	void toggleRow()
	{
		if(row == Character.ROW_FRONT)
		{
			row = Character.ROW_BACK;
		}
		else
		{
			row = Character.ROW_FRONT;
		}
	}

}