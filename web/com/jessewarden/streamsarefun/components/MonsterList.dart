part of components;

class MonsterList extends DisplayObjectContainer
{

	Initiative initiative;
	ResourceManager resourceManager;
	Map<Bitmap, Monster> spriteCharacterMap = new Map<Bitmap, Monster>();

	TextDropper _textDropper;
	Juggler juggler;
	Stage stage;

	MonsterList({Initiative this.initiative,
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

		num startXMonster = 120;
		num startYMonster = 120;
		// flying can be higher...

		// range: 280x172

		num startXName = 16;
		num startYName = 318;

		initiative.monsters.forEach((Monster monster)
		{
			// create name
//			TextField nameField = new TextField();
//			nameField.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 36, Color.Black);
//			nameField.text = monster.monsterType;
//			nameField.x = startXName;
//			nameField.y = startYName - 40 + 15;
//			nameField.width = 200;
//			nameField.height = 40;
//			startYName += 24;
//			nameField.wordWrap = false;
//			nameField.multiline = false;
//			addChild(nameField);

			// create sprite
			Bitmap bitmap = new Bitmap(getBitmapForMonsterType(monster));
			spriteCharacterMap[bitmap] = monster;
			addChild(bitmap);
			bitmap.x = startXMonster;
			bitmap.y = startYMonster;
			startXMonster += 16;
			startYMonster += 36;

			monster.stream.listen((CharacterEvent event)
			{
				if(event.type == CharacterEvent.HIT_POINTS_CHANGED)
				{
					int color;
					if(event.changeAmount < 0)
					{
						color = Color.White;
					}
					else
					{
						color = Color.Lime;
					}
					_textDropper.addTextDrop(bitmap, event.changeAmount, color: color);
				}
			});
		});
	}

	void miss(Monster targetMonster)
	{
		spriteCharacterMap.forEach((Bitmap key, Monster monster)
		{
			if(monster == targetMonster)
			{
				_textDropper.addTextDrop(key, 0, color: Color.White, miss: true);
			}
		});
	}

	Bitmap getBitmapFromMonster(Monster targetMonster)
	{
		Bitmap bitmap;
		spriteCharacterMap.forEach((Bitmap key, Monster monster)
		{
			if(monster == targetMonster)
			{
				bitmap = key;
			}
		});
		return bitmap;
	}

	Monster getMonsterForBitmap(Bitmap bitmap)
	{
		return spriteCharacterMap[bitmap];
	}

	attacking(Monster targetMonster) async
	{
		var completer = new Completer();
		Bitmap bitmap;
		spriteCharacterMap.forEach((Bitmap key, Monster monster)
		{
			if(monster == targetMonster)
			{
				bitmap = key;
			}
		});
//		bitmap.filters = [new ColorMatrixFilter.grayscale()];

		juggler.addChain([
			_getGrayTween(bitmap, 0),
			_getResetTween(bitmap, 0.05),
			_getGrayTween(bitmap, 0.05),
			_getResetTween(bitmap, 0.05),
			_getGrayTween(bitmap, 0.05),
			_getResetTween(bitmap, 0.05)
		])
		.onComplete = ()
		{
			completer.complete();
		};
		return completer.future;
	}

	Tween _getGrayTween(DisplayObject displayObject, num time)
	{
		var tween = new Tween(displayObject, time);
		tween.onComplete = ()
		{
			displayObject.filters = [new ColorMatrixFilter.invert()];
			displayObject.applyCache(-20, -20, displayObject.width.round() + 20, displayObject.height.round() + 20);
		};
		return tween;
	}

	Tween _getResetTween(DisplayObject displayObject, num time)
	{
		var tween = new Tween(displayObject, time);
		tween.onComplete = ()
		{
			displayObject.filters = [];
			displayObject.applyCache(-20, -20, displayObject.width.round() + 20, displayObject.height.round() + 20);
		};
		return tween;
	}

	BitmapData getBitmapForMonsterType(Monster monster)
	{
		return resourceManager.getBitmapData(monster.monsterType);
	}
}
