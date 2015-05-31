part of battlecore;

class Initiative
{
	Stream<GameLoopEvent> _gameLoopStream;
	Stream<GameLoopEvent> get gameLoopStream => _gameLoopStream;
	ObservableList<Player> _players;
	ObservableList<Monster> _monsters;
	List<TimerCharacterMap> _battleTimers = new List<TimerCharacterMap>();
	StreamController _streamController;

	ObservableList<Player> get players => _players;
	ObservableList<Monster> get monsters => _monsters;

	ObservableList<Character> charactersReady = new ObservableList<Character>();
	Stream stream;

	Initiative(this._gameLoopStream, this._players, this._monsters)
	{
		init();
	}

	void init()
	{
		_streamController = new StreamController(onPause: onPause, onResume: onResume);
		stream = _streamController.stream.asBroadcastStream();
		List participants = new List();
		participants.add(players);
		participants.add(monsters);
		participants.forEach((ObservableList list)
		{
			// listen for new changes
			list.listChanges.listen((List<ListChangeRecord> records)
			{
				addOrRemoveBattleTimerForCharacter(records, list);
			});

			// configure the participants in the battle we have now
			list.forEach(addBattleTimerForCharacter);
		});

		_streamController.add(new InitiativeEvent(InitiativeEvent.INITIALIZED));
	}

	void addBattleTimerForCharacter(Character character)
	{
		String mode = getModeBasedOnType(character);
		BattleTimer timer = new BattleTimer(_gameLoopStream, mode);
		StreamSubscription<BattleTimerEvent> timerSubscription = timer.stream
		.listen((BattleTimerEvent event)
		{
			TimerCharacterMap matched = _battleTimers.firstWhere((TimerCharacterMap map)
			{
				return map.battleTimer == event.target;
			});
			if(event.type == BattleTimerEvent.COMPLETE)
			{
				// NOTE: pausing the BattleTimer, not the Stream listener... lol, streams!
				matched.battleTimer.pause();
				Character targetCharacter = matched.character;
				print("character.id: ${targetCharacter.ID}");
				charactersReady.add(targetCharacter);
				_streamController.add(new InitiativeEvent(InitiativeEvent.CHARACTER_READY,
				character: targetCharacter));
			}
			else if(event.type == BattleTimerEvent.PROGRESS)
			{
				event.character = matched.character;
				_streamController.add(event);
			}
		});
		timer.speed = character.speed;
		if(character is Monster)
		{
			character.strength = BattleMath.getRandomMonsterStrength();
		}

		StreamSubscription<CharacterEvent> characterSubscription = character.stream.listen((CharacterEvent event)
		{
			if(event.type == CharacterEvent.NO_LONGER_SWOON)
			{
				timer.reset();
			}

			if(event.target.hitPoints <= 0)
			{
				timer.pause();
			}
		});

		_battleTimers.add(new TimerCharacterMap(timer, timerSubscription, character, characterSubscription));
		timer.start();
	}

	String getModeBasedOnType(Character character)
	{
		if(character is Player)
		{
			print("player...");
			return BattleTimer.MODE_CHARACTER;
		}
		else
		{
			print("monster...");
			return BattleTimer.MODE_MONSTER;
		}
	}

	void removeBattleTimerForCharacter(Character character)
	{
		TimerCharacterMap object = _battleTimers.firstWhere((object)
		{
			return object.character == character;
		});
		object.battleTimer.dispose();
		object.battleTimerSubscription.cancel();
		object.characterSubscription.cancel();
		_battleTimers.remove(object);
	}

	void addOrRemoveBattleTimerForCharacter(List<ListChangeRecord> records, ObservableList<Character> list)
	{
		// data: [#<ListChangeRecord index: 0, removed: [], addedCount: 2>]
		records.forEach((ListChangeRecord record)
		{
			if(record.addedCount > 0)
			{
				for(int index = record.index; index < record.index + record.addedCount; index++)
				{
					addBattleTimerForCharacter(list.elementAt(index));
				}
			}
			if(record.removed.length > 0)
			{
				record.removed.forEach(addBattleTimerForCharacter);
			}
		});
	}

	void reset()
	{
		_battleTimers.forEach((TimerCharacterMap object)
		{
			BattleTimer timer = object.battleTimer;
			timer.reset();
			timer.start();
		});
	}

	void pause()
	{
		_battleTimers.forEach((TimerCharacterMap object)
		{
			BattleTimer timer = object.battleTimer;
			timer.pause();
		});
	}

	void start()
	{
		_battleTimers.forEach((TimerCharacterMap object)
		{
			BattleTimer timer = object.battleTimer;
			timer.start();
		});
	}

	void onPause()
	{
		pause();
	}

	void onResume()
	{
		start();
	}

	void onDeath(Character character)
	{
		TimerCharacterMap hash = _battleTimers.firstWhere((TimerCharacterMap object)
		{
			return object.character == character;
		});
		BattleTimer characterTimer = hash.battleTimer;
		characterTimer.pause();
		bool allMonstersDead = monsters.every((Monster monster)
		{
			return monster.dead;
		});

		bool allPlayersDead = players.every((Player player)
		{
			return player.dead;
		});

		// TODO: handle Life 3
		if(allPlayersDead)
		{
			pause();
			_streamController.add(new InitiativeEvent(InitiativeEvent.LOST));
			return;
		}

		if(allMonstersDead)
		{
			pause();
			_streamController.add(new InitiativeEvent(InitiativeEvent.WON));
			return;
		}
	}
}

class TimerCharacterMap
{
	BattleTimer battleTimer;
	StreamSubscription battleTimerSubscription;
	Character character;
	StreamSubscription characterSubscription;

	TimerCharacterMap(this.battleTimer, this.battleTimerSubscription, this.character, this.characterSubscription)
	{

	}
}