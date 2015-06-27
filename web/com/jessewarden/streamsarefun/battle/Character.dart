part of battlecore;

class Character
{
	String name;

	int vigor = 1;
	int speed = 1;
	int stamina = 1;
	int magicPower = 1;
	int evade = 1;
	int magicBlock = 1;

	int defense = 1;
	int magicDefense = 1;
	int battlePower = 1;
	int hitRate = 100;

	bool dead = false;
	int level = 1;

	int ID = -1;
	static int INCREMENT = 0;


	Item rightHand = null;
	Item leftHand = null;
	Item head = null;
	Item body = null;

	Relic relic1 = null;
	Relic relic2 = null;

	// TODO: figure out reflection/mirrors
	bool equippedWithNoRelics()
	{
		return relic1 == null && relic2 == null;
	}

	bool equippedWithGauntlet()
	{
		return relic1 is Gauntlet || relic2 is Gauntlet;
	}

	bool equippedWithOffering()
	{
		return relic1 is Offering || relic2 is Offering;
	}

	bool genjiGloveEquipped()
	{
		return relic1 is GenjiGlove || relic2 is GenjiGlove;
	}

	bool equippedWithAtlasArmlet()
	{
		return relic1 is AtlasArmlet || relic2 is AtlasArmlet;
	}

	bool equippedWithHeroRing()
	{
		return relic1 is HeroRing || relic2 is HeroRing;
	}

	bool equippedWith1HeroRing()
	{
		return (relic1 is HeroRing && relic2 is !HeroRing) || (relic1 is !HeroRing && relic2 is HeroRing);
	}

	bool equippedWith2HeroRings()
	{
		return relic1 is HeroRing && relic2 is HeroRing;
	}

	bool equippedWithEarring()
	{
		return relic1 is Earring || relic2 is Earring;
	}

	bool equippedWith1Earring()
	{
		return (relic1 is Earring && relic2 is !Earring) || (relic1 is !Earring && relic2 is Earring);
	}

	bool equippedWith2Earrings()
	{
		return relic1 is Earring && relic2 is Earring;
	}


	bool rightHandHasWeapon() => rightHand != null;
	bool leftHandHasWeapon() => leftHand != null;
	bool rightHandHasNoWeapon() => !rightHandHasWeapon();
	bool leftHandHasNoWeapon() => !rightHandHasWeapon();
	bool hasZeroWeapons() => rightHandHasNoWeapon() && leftHandHasNoWeapon();

	bool oneOrZeroWeapons()
	{
		if(rightHandHasWeapon() && leftHandHasNoWeapon())
		{
			return true;
		}
		else if(rightHandHasNoWeapon() && leftHandHasWeapon())
		{
			return true;
		}
		else if(hasZeroWeapons())
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	BattleState _battleState;
	int _hitPoints = 0;

	int get hitPoints => _hitPoints;
	void set hitPoints(int newValue)
	{
		num oldValue = _hitPoints;
		if(_hitPoints != newValue)
		{
			_hitPoints = newValue;
			_controller.add(new CharacterEvent(
				type: CharacterEvent.HIT_POINTS_CHANGED,
				target: this,
				changeAmount: newValue - oldValue));
			if(oldValue <= 0 && newValue >= 1)
			{
				dead = false;
				_controller.add(new CharacterEvent(type: CharacterEvent.NO_LONGER_SWOON, target: this));
			}
			else if(oldValue >= 1 && newValue <= 0)
			{
				dead = true;
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
	          int this.vigor: 10,
	          int this.stamina: 10,
	          int this.magicBlock: 10,
				Row row: Row.FRONT,
				int hitPoints: 0,
	          int this.defense: 10,
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