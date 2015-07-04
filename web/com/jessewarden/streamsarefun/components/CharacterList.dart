part of components;

class CharacterList extends DisplayObjectContainer
{

	Initiative initiative;
	ResourceManager resourceManager;
	Stage stage;
	Juggler juggler;
	Map<SpriteSheet, Player> spriteCharacterMap = new Map<SpriteSheet, Player>();

	TextDropper _textDropper;

	CharacterList({Initiative this.initiative,
	              ResourceManager this.resourceManager,
	              Juggler juggler,
					Stage stage})
	{
		this.juggler = juggler;
		this.stage = stage;
	}

	void init()
	{
		_textDropper = new TextDropper(stage, juggler);

		num startXBar = 374;
		num startYBar = 154;

		num startXPlayer = 374;
		num startYPlayer = 174;

		num startXName = 208;
		num startYName = 318;

		num startXHitPoints= 320;
		num startYHitPoints = 318;

		initiative.players.forEach((Player player)
		{
			// create name
			TextField nameField = new TextField();
			nameField.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 36, Color.Black);
			nameField.text = player.characterType;
			nameField.x = startXName;
			nameField.y = startYName - 40 + 15;
			nameField.width = 200;
			nameField.height = 40;
			startYName += 24;
			nameField.wordWrap = false;
			nameField.multiline = false;
			addChild(nameField);

			// create name
			TextField hitPointsField = new TextField();
			hitPointsField.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 36, Color.Black);
			hitPointsField.text = player.hitPoints.toString();
			hitPointsField.x = startXHitPoints;
			hitPointsField.y = startYHitPoints - 40 + 15;
			hitPointsField.width = 200;
			hitPointsField.height = 40;
			startYHitPoints += 24;
			hitPointsField.wordWrap = false;
			hitPointsField.multiline = false;
			addChild(hitPointsField);

			// create bar
			BattleTimerBar bar = new BattleTimerBar(juggler);
			addChild(bar);
			bar.x = startXBar;
			bar.y = startYBar;

			initiative.stream
			.where((event)
			{
				return event is BattleTimerEvent &&
				event.character == player;
			})
			.listen((event)
			{
				BattleTimerEvent battleTimerEvent = event as BattleTimerEvent;
				bar.percentage = battleTimerEvent.percentage;
				if(event.type == BattleTimerEvent.COMPLETE)
				{
					bar.percentage = 1;
				}
			});

			// create sprite
			SpriteSheet sheet = getSpriteSheetForPlayerCharacterType(player);
			spriteCharacterMap[sheet] = player;
			addChild(sheet);
			sheet.init();
			sheet.x = startXPlayer;
			sheet.y = startYPlayer;
//			startXPlayer += 16;
			startYPlayer += 80;
			bar.x = sheet.x;
			bar.y = sheet.y - 6;

			player.stream.listen((CharacterEvent event)
			{
				if(event.type == CharacterEvent.HIT_POINTS_CHANGED)
				{
					hitPointsField.text = event.target.hitPoints.toString();
					int color;
					if(event.changeAmount < 0)
					{
						color = Color.White;
					}
					else
					{
						color = Color.Lime;
					}
					_textDropper.addTextDrop(sheet, event.changeAmount, color: color);
				}

				if(event.type == CharacterEvent.SWOON)
				{
					var sheet = getSpriteSheetFromPlayer(player);
					// TODO: not everyone has a hurt sprite, nor do they implement an interface for me to set
					sheet.hurt();
				}
			});
		});
	}

	void miss(Player targetPlayer)
	{
		spriteCharacterMap.forEach((SpriteSheet key, Player player)
		{
			if(player == targetPlayer)
			{
				_textDropper.addTextDrop(key, 0, color: Color.White, miss: true);
			}
		});
	}

	void hit(Player targetPlayer) async
	{
		var completer = new Completer();
		spriteCharacterMap.forEach((SpriteSheet key, Player player)
		{
			if(player == targetPlayer)
			{
				var oldCycle = key.currentCycle;
				print("oldCycle: $oldCycle");
				key.hit();
				var tween = new Tween(key, 0.6);
				tween.onComplete = ()
				{
					key.currentCycle = oldCycle;
					completer.complete();
				};
				juggler.addChain([tween]);
			}
		});
		return completer.future;
	}

	Bitmap getSpriteSheetFromPlayer(Player targetPlayer)
	{
		SpriteSheet spriteSheet;
		spriteCharacterMap.forEach((SpriteSheet key, Player player)
		{
			if(player == targetPlayer)
			{
				spriteSheet = key;
			}
		});
		return spriteSheet;
	}

//	void attacking(Player targetPlayer, Character targetToAttack) async
//	{
//		var completer = new Completer();
//		Bitmap targetPlayerBitmap = getBitmapFromCharacter(targetPlayer);
//		Bitmap targetToAttackBitmap = getBitmapFrom
//
//		juggler.addChain([
//			_getGrayTween(bitmap, 0),
//			_getResetTween(bitmap, 0.05),
//			_getGrayTween(bitmap, 0.05),
//			_getResetTween(bitmap, 0.05),
//			_getGrayTween(bitmap, 0.05),
//			_getResetTween(bitmap, 0.05)
//		])
//		.onComplete = ()
//		{
//			completer.complete();
//		};
//		return completer.future;
//	}

	SpriteSheet getSpriteSheetForPlayerCharacterType(Player player)
	{
		switch(player.characterType)
		{
			case Player.WARRIOR:
				return new WarriorSprite(resourceManager);

			case Player.BLACK_MAGE:
				return new BlackMageSprite(resourceManager);

			case Player.THIEF:
				return new ThiefSprite(resourceManager);
		}
		return null;
	}

//	Tween getAttackTween(DisplayObject attacker, DisplayObject targetToAttack, num time)
//	{
//		var tween = new Tween(displayObject, time);
//
//		return tween;
//	}


}
