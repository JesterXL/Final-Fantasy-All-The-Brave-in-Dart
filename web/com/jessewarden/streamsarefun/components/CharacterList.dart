part of components;

class CharacterList extends DisplayObjectContainer
{

	Initiative initiative;
	ResourceManager resourceManager;
	Stage stage;
	RenderLoop renderLoop;

	TextDropper _textDropper;

	CharacterList({Initiative this.initiative,
	              ResourceManager this.resourceManager,
	              Stage this.stage,
	              RenderLoop this.renderLoop})
	{
	}

	void init()
	{
		_textDropper = new TextDropper(stage, renderLoop);

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
//			// create name
//			TextField nameField = new TextField();
//			nameField.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 36, Color.Black);
//			nameField.text = player.characterType;
//			nameField.x = startXName;
//			nameField.y = startYName - 40 + 15;
//			nameField.width = 200;
//			nameField.height = 40;
//			startYName += 24;
//			nameField.wordWrap = false;
//			nameField.multiline = false;
//			addChild(nameField);
//
//			// create name
//			TextField hitPointsField = new TextField();
//			hitPointsField.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 36, Color.Black);
//			hitPointsField.text = player.hitPoints.toString();
//			hitPointsField.x = startXHitPoints;
//			hitPointsField.y = startYHitPoints - 40 + 15;
//			hitPointsField.width = 200;
//			hitPointsField.height = 40;
//			startYHitPoints += 24;
//			hitPointsField.wordWrap = false;
//			hitPointsField.multiline = false;
//			addChild(hitPointsField);

			// create bar
			BattleTimerBar bar = new BattleTimerBar(renderLoop);
			addChild(bar);
			bar.x = startXBar;
			bar.y = startYBar;

			initiative.stream
			.where((event)
			{
				return event is BattleTimerEvent &&
				event.type == BattleTimerEvent.PROGRESS &&
				event.character == player;
			})
			.listen((event)
			{

				BattleTimerEvent battleTimerEvent = event as BattleTimerEvent;
				bar.percentage = battleTimerEvent.percentage;
			});

			// create sprite
			SpriteSheet sheet = getSpriteSheetForPlayerCharacterType(player);
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
					//hitPointsField.text = event.target.hitPoints.toString();
					int color;
					if(event.changeAmount < 0)
					{
						color = Color.White;
					}
					else
					{
						color = Color.Green;
					}
					_textDropper.addTextDrop(sheet, event.changeAmount, color: color);
				}
			});
		});
	}

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

//	void render(RenderState renderState)
//	{
//		super.render(renderState);
//	}
}
