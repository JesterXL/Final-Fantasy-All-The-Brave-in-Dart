part of battlecore;

class IntentQueue implements Animatable
{
	List<Intent> _intents = new List<Intent>();
	Juggler juggler;
	Intent _currentIntent;
	Intent get currentIntent => _currentIntent;
	Initiative initiative;
	CharacterList characterList;
	MosnterList monsterList;
	StreamController<Intent> _controller;
	Stream<Intent> stream;


	IntentQueue(
		Juggler this.juggler,
		Initiative this.initiative,
		CharacterList this.characterList,
		MonsterList this.monsterList)
	{
		_controller = new StreamController.broadcast();
		stream = _controller.stream;
	}

	bool advanceTime(num time)
	{
		if(_currentIntent == null)
		{
			processNext();
		}
		return true;
	}

	void addIntent(Intent intent)
	{
		_intents.add(intent);
	}

	void removeIntent(Intent intent)
	{
		_intents.remove(intent);
	}

	void processNext()
	{
		if(_intents.length > 0)
		{
			_currentIntent = _intents.first;
			processIntent(_currentIntent);
		}
	}

	void processIntent(Intent intent)
	{
		makePhysicalAttack(intent);
//		if(intent.isPhysicalAttack == true)
//		{
//			makePhysicalAttack(intent);
//		}
//		else if(intent.isMagicalAttack == true)
//		{
//			makeMagicalAttack(intent);
//		}
//		else if(intent)
//		{
//			makeItemAttack(intent);
//		}
//		else
//		{
//			makeMiscellaneousAttack(intent);
//		}
	}

	void makePhysicalAttack(Intent intent) async
	{
		if(intent.attacker is Player)
		{
			await makePlayerPhysicalAttack(intent);
		}
		else
		{
			await makeMonsterPhysicalAttack(intent);
		}
	}

	Future makeMonsterPhysicalAttack(Intent intent) async
	{
		var completer = new Completer();
		var target = intent.targets[0];
		TargetHitResult targetHitResult = BattleUtils.getHitAndApplyDamage(
			intent.attacker,
			isPhysicalAttack: true,
			isMagicalAttack: false,
			targetHasClearStatus: intent.targets[0].clear,
			protectedFromWound: intent.targets[0].protectedFromWound,
			attackMissesDeathProtectedTargets: intent.attackMissesDeathProtectedTargets,
			attackCanBeBlockedByStamina: intent.attackCanBeBlockedByStamina,
			targetHasSleepStatus: intent.targets[0].sleep,
			targetHasPetrifyStatus: intent.targets[0].petrify,
			targetHasFreezeStatus: intent.targets[0].freeze,
			targetHasStopStatus: intent.targets[0].stop,
			targetHasSafeStatus: intent.targets[0].safe,
			targetHasShellStatus: intent.targets[0].shell,
			targetDefending: intent.targets[0].defending,
			targetIsInBackRow: intent.targets[0].row == Row.BACK,
			targetHasMorphStatus: intent.targets[0].morph,
			targetIsCharacter: intent.targets[0] == intent.attacker,
			backOfTarget: intent.targets[0].back,
			targetHasImageStatus: intent.targets[0].image,
			hitRate: intent.hitRate,
			magicBlock: intent.targets[0].magicBlock,
			targetStamina: intent.targets[0].stamina,
			specialAttackType: intent.specialAttackType,
			attackerIsCharacter: true,
			attackingMultipleTargets: intent.targets.length > 1,
			attackerIsInBackRow: intent.attacker.row == Row.BACK,
			attackerHasMorphStatus: intent.attacker.morph,
			attackerHasBerserkStatusAndPhysicalAttack: intent.attacker.berserk
		);
		// TODO: need to handle weapons with an element type
		await monsterList.attacking(intent.attacker);
		if(targetHitResult.hit == true)
		{
			target.hitPoints = target.hitPoints - targetHitResult.damage;
			if(target is Player)
			{
				await characterList.hit(target);
			}
		}
		else
		{
			if(target is Player)
			{
				characterList.miss(target);
			}
			else if(target is Monster)
			{
				monsterList.miss(target);
			}
		}
		var tween = new Translation(0, 1000, 1);
		tween.onComplete = ()
		{
			intentComplete(intent);
			completer.complete();
		};
		juggler.add(tween);
		return completer.future;
	}

	void makePlayerPhysicalAttack(Intent intent) async
	{
		var completer = new Completer();
		var target = intent.targets[0];
		TargetHitResult targetHitResult = BattleUtils.getHitAndApplyDamage(
			intent.attacker,
			isPhysicalAttack: true,
			isMagicalAttack: false,
			targetHasClearStatus: target.clear,
			protectedFromWound: target.protectedFromWound,
			attackMissesDeathProtectedTargets: intent.attackMissesDeathProtectedTargets,
			attackCanBeBlockedByStamina: intent.attackCanBeBlockedByStamina,
			targetHasSleepStatus: target.sleep,
			targetHasPetrifyStatus: target.petrify,
			targetHasFreezeStatus: target.freeze,
			targetHasStopStatus: target.stop,
			targetHasSafeStatus: target.safe,
			targetHasShellStatus: target.shell,
			targetDefending: target.defending,
			targetIsInBackRow: target.row == Row.BACK,
			targetHasMorphStatus: target.morph,
			targetIsSelf: target == intent.attacker,
			targetIsCharacter: target is Player,
			backOfTarget: target.back,
			targetHasImageStatus: target.image,
			hitRate: intent.hitRate,
			magicBlock: target.magicBlock,
			targetStamina: target.stamina,
			specialAttackType: intent.specialAttackType,
			attackerIsCharacter: true,
			attackingMultipleTargets: intent.targets.length > 1,
			attackerIsInBackRow: intent.attacker.row == Row.BACK,
			attackerHasMorphStatus: intent.attacker.morph,
			attackerHasBerserkStatusAndPhysicalAttack: intent.attacker.berserk
		);
		// TODO: need to handle weapons with an element type
		var playerBitmap = characterList.getBitmapFromPlayer(intent.attacker);
		var targetBitmap = monsterList.getBitmapFromMonster(intent.targets[0]);
		var startX = playerBitmap.x;
		var startY = playerBitmap.y;
		await playerAttack(playerBitmap, targetBitmap);
		if(targetHitResult.hit == true)
		{
			target.hitPoints = target.hitPoints - targetHitResult.damage;
			if(target is Player)
			{
				await characterList.hit(target);
			}
		}
		else
		{
			if(target is Player)
			{
				characterList.miss(target);
			}
			else if(target is Monster)
			{
				monsterList.miss(target);
			}
		}
		var playerReturnTween = new Tween(playerBitmap, 0.5);
		playerReturnTween.animate.x = startX;
		playerReturnTween.animate.y = startY;
		playerReturnTween.onComplete = ()
		{
			intentComplete();
			completer.complete();
		};
		juggler.addTween(tween);
		return completer.future;
	}

	void playerAttack(Bitmap playerBitmap, Bitmap targetBitmap)
	{
		var completer = new Completer();
		var playerTween = new Tween(playerBitmap, 0.5);
		playerTween.animate.x = targetBitmap.x;
		playerTween.animate.y = targetBitmap.y;
		playerTween.onComplete = ()
		{
			completer.complete();
		};
		return completer.future;
	}

	void intentComplete(Intent intent)
	{
		_currentIntent = null;
		_controller.add(intent);
	}

}