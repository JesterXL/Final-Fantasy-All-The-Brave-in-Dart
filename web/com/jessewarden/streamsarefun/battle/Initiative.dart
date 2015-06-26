part of battlecore;

class Initiative
{
	Stream<GameLoopEvent> _gameLoopStream;
	ObservableList<Player> _players;
	ObservableList<Monster> _monsters;
	List<TimerCharacterMap> _battleTimers = new List<TimerCharacterMap>();
	StreamController _streamController;

	ObservableList<Player> get players => _players;
	ObservableList<Monster> get monsters => _monsters;
	StreamSubscription<BattleTimerEvent> timerSubscription;
	Stream stream;

	StateMachine _stateMachine;
	StreamController _timerStreamController;
	Stream _timerStream;

	Initiative(this._gameLoopStream, this._players, this._monsters)
	{
		init();
	}

	void init()
	{

		_streamController = new StreamController.broadcast();
		stream = _streamController.stream;
		List participants = new List();
		participants.add(players);
		participants.add(monsters);
		participants.forEach((ObservableList list)
		{
			// listen for new changes
			list.listChanges.listen((List<ListChangeRecord> records)
			{
				addOrremoveBattleTimerForPlayer(records, list);
			});

			// configure the participants in the battle we have now
			list.forEach(addBattleTimerForCharacter);
		});

		_timerStreamController = new StreamController();
		_timerStream = _timerStreamController.stream;
		StreamSubscription<TimerEvent> sub = _timerStream.listen((TimerEvent event)
		{
			print("Initaitive::timerStream listen, event: ${event.type}");
			switch(event.type)
			{
				case TimerEvent.PAUSE:
					_stateMachine.changeState("paused");
					break;

				case TimerEvent.START:
					_stateMachine.changeState("waiting");
					break;

				case TimerEvent.RESET_TIMER_FOR_CHARACTER:
					_enableAndResetTimerForCharacter(event.character);
					break;

			}
		});

		_stateMachine = new StateMachine();
		_stateMachine.addState(
			"waiting",
			enter: ()
			{
				sub.resume();
			},
			exit: ()
			{
				sub.pause();
			}
		);
		_stateMachine.addState(
			"paused",
			enter: ()
			{
				_pause();
				timerSubscription.pause();
			},
			exit: ()
			{
				_start();
				timerSubscription.resume();
			});
		_stateMachine.changes.listen((StateMachineEvent event)
		{
			print("Initiative state change: ${_stateMachine.currentState.name}");
		});
		_stateMachine.initialState = 'waiting';

		_streamController.add(new InitiativeEvent(InitiativeEvent.INITIALIZED));
	}

	void _enableAndResetTimerForCharacter(Character character)
	{
		TimerCharacterMap matched = _battleTimers.firstWhere((TimerCharacterMap map)
		{
			return map.character == character;
		});
		if(character.dead == false)
		{
			matched.battleTimer.enabled = true;
			matched.battleTimer.reset();
			if(_stateMachine.currentState.name == "waiting")
			{
				matched.battleTimer.start();
			}
		}
	}

	void resetCharacterTimer(Character character)
	{
		_timerStreamController.add(new TimerEvent(type: TimerEvent.RESET_TIMER_FOR_CHARACTER, character: character));
	}

	void addBattleTimerForCharacter(Character character)
	{
		String mode = getModeBasedOnType(character);
		BattleTimer timer = new BattleTimer(_gameLoopStream, mode);
		timerSubscription = timer.stream
		.listen((BattleTimerEvent event)
		{
			TimerCharacterMap matched = _battleTimers.firstWhere((TimerCharacterMap map)
			{
				return map.battleTimer == event.target;
			});
			if(event.type == BattleTimerEvent.COMPLETE)
			{
				matched.battleTimer.enabled = false;
				Character targetCharacter = matched.character;
				if(targetCharacter is Player)
				{
					_streamController.add(new InitiativeEvent(InitiativeEvent.PLAYER_READY,
					character: targetCharacter));
				}
				else
				{
					_streamController.add(new InitiativeEvent(InitiativeEvent.MONSTER_READY,
					character: targetCharacter));
				}
			}
			else if(event.type == BattleTimerEvent.PROGRESS)
			{
				event.character = matched.character;
				_streamController.add(event);
			}
		});

		timer.speed = character.speed;

		if(character is Player)
		{
			StreamSubscription<CharacterEvent> characterSubscription = character.stream.listen((CharacterEvent event)
			{
				if(event.type == CharacterEvent.NO_LONGER_SWOON)
				{
					// TODO: ensure we're not in a paused state
					timer.enabled = true;
					timer.reset();
					timer.start();
				}

				if(event.target.hitPoints <= 0)
				{
					timer.enabled = false;
				}
			});
			_battleTimers.add(new TimerCharacterMap(timer, timerSubscription, character, characterSubscription));
		}
		else
		{
			StreamSubscription<CharacterEvent> characterSubscription = character.stream
			.where((CharacterEvent event)
			{
				return event.type == CharacterEvent.SWOON;
			})
			.listen((CharacterEvent event)
			{
				timer.enabled = false;
				removeBattleTimerForPlayer(event.target);
			});
			_battleTimers.add(new TimerCharacterMap(timer, timerSubscription, character, characterSubscription));
		}

		timer.start();
	}

	String getModeBasedOnType(Character character)
	{
		if(character is Player)
		{
			return BattleTimer.MODE_PLAYER;
		}
		else
		{
			return BattleTimer.MODE_MONSTER;
		}
	}

	void removeBattleTimerForPlayer(Character character)
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

	void addOrremoveBattleTimerForPlayer(List<ListChangeRecord> records, ObservableList<Character> list)
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

	void _pause()
	{
		_battleTimers.forEach((TimerCharacterMap timerCharacterMap)
		{
			timerCharacterMap.pause();
		});
	}

	void pause()
	{
		_timerStreamController.add(new TimerEvent(type: TimerEvent.PAUSE));
	}

	void _start()
	{
		_battleTimers.forEach((TimerCharacterMap timerCharacterMap)
		{
			timerCharacterMap.resume();
		});
	}

	void start()
	{
		_stateMachine.changeState("waiting");
		_timerStreamController.add(new TimerEvent(type: TimerEvent.START));
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

	void pause()
	{
		battleTimer.pause();
		battleTimerSubscription.pause();
		characterSubscription.pause();
	}

	void resume()
	{
		battleTimer.start();
		battleTimerSubscription.resume();
		characterSubscription.resume();
	}

}

class TimerEvent
{
	String type;
	Character character;
	BattleTimer timer;

	static const String PAUSE = "pause";
	static const String START = "start";
	static const String RESET_TIMER_FOR_CHARACTER = "reset";

	TimerEvent({String this.type, Character this.character})
	{
	}
}