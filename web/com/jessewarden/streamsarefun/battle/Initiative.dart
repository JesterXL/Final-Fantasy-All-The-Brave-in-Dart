part of battlecore;

class Initiative
{
	ObservableList<Player> _players;
	ObservableList<Monster> _monsters;
	List<TimerCharacterMap> _battleTimers = new List<TimerCharacterMap>();
	StreamController _streamController;

	ObservableList<Player> get players => _players;
	ObservableList<Monster> get monsters => _monsters;
	Stream stream;
	Juggler juggler;

	Initiative(Juggler this.juggler, this._players, this._monsters)
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
	}

	void addBattleTimerForCharacter(Character character)
	{
		BattleTimer timer = new BattleTimer(getModeBasedOnType(character));

		// whenever BattleTimer is complete, we dispatch a 'ready'
		StreamSubscription<BattleTimerEvent> timerSubscription = timer.stream
		.where((event)
		{
			if(event is BattleTimerEvent)
			{
				event.character = character;
				_streamController.add(event);
			}
			return true;
		})
		.where((BattleTimerEvent event)
		{
			return event.type == BattleTimerEvent.COMPLETE;
		})
		.listen((BattleTimerEvent event)
		{
			TimerCharacterMap matched = _battleTimers.firstWhere((TimerCharacterMap map)
			{
				return map.battleTimer == event.target;
			});
			Character targetCharacter = matched.character;
			if(targetCharacter is Player)
			{
				print("Player Ready");
				_streamController.add(new InitiativeEvent(InitiativeEvent.PLAYER_READY,
				character: targetCharacter));
			}
			else
			{
				print("Monster Ready");
				_streamController.add(new InitiativeEvent(InitiativeEvent.MONSTER_READY,
				character: targetCharacter));
			}
		});

		// match the timer's speed to character speed.
		// TODO: listen for event changes to update later
		timer.speed = character.speed;

		if(character is Player)
		{
			StreamSubscription<CharacterEvent> characterSubscription = character.stream.listen((CharacterEvent event)
			{
				switch(event.type)
				{
					case CharacterEvent.NO_LONGER_SWOON:
						timer.enabled = true;
						timer.reset();
						break;

					case CharacterEvent.SWOON:
						onDeath(event.target);
						break;

					case CharacterEvent.HIT_POINTS_CHANGED:
						if(event.target.hitPoints <= 0)
						{
							timer.enabled = false;
						}
						break;
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
				removeBattleTimerForCharacter(event.target);
				onDeath(event.target);
			});
			_battleTimers.add(new TimerCharacterMap(timer, timerSubscription, character, characterSubscription));
		}

		juggler.add(timer);
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

	void removeBattleTimerForCharacter(Character character)
	{
		TimerCharacterMap object = _battleTimers.firstWhere((object)
		{
			return object.character == character;
		});
		object.battleTimer.enabled = false;
		object.battleTimerSubscription.cancel();
		object.characterSubscription.cancel();
		_battleTimers.remove(object);
		juggler.remove(object.battleTimer);
	}

	void resetCharacterTimer(Character character)
	{
		print("Initiative::resetCharacterTimer");
		TimerCharacterMap object = _battleTimers.firstWhere((object)
		{
			return object.character == character;
		});
		print("state before: ${object.battleTimer.fsm.currentState.name}");
		object.battleTimer.reset();
		object.battleTimer.enabled = true;
		print("state after: ${object.battleTimer.fsm.currentState.name}");
		print("Juggler contains: ${juggler.contains(object.battleTimer)}");
		juggler.add(object.battleTimer);
	}

	void addOrRemoveBattleTimerForPlayer(List<ListChangeRecord> records, ObservableList<Character> list)
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
				record.removed.forEach(removeBattleTimerForCharacter);
			}
		});
	}

	void onDeath(Character character)
	{
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
			_streamController.add(new InitiativeEvent(InitiativeEvent.LOST));
			return;
		}

		if(allMonstersDead)
		{
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