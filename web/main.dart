import 'dart:html';
import 'dart:core';
import 'dart:async';
import 'dart:math';
import 'package:stagexl/stagexl.dart';
import 'package:observe/observe.dart';
import 'com/jessewarden/streamsarefun/core/streamscore.dart';
import 'com/jessewarden/streamsarefun/battle/battlecore.dart';
import 'com/jessewarden/streamsarefun/components/components.dart';
import 'com/jessewarden/streamsarefun/sprites/sprites.dart';

CanvasElement canvas;
Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;
//CursorFocusManager cursorManager;

void main()
{
	querySelector('#output').text = 'Your Dart app is running.';

	canvas = querySelector('#stage');
	canvas.context2D.imageSmoothingEnabled = true;

	stage = new Stage(canvas, webGL: false);
	renderLoop = new RenderLoop();
	renderLoop.addStage(stage);

	resourceManager = new ResourceManager();
//	cursorManager = new CursorFocusManager(stage, resourceManager);

	//testGameLoop();
//  testBattleTimer();
//	testTextDropper();
//	testBattleTimerBar();
//	testInitiative();
//	testMath();
//	testWarriorSprite();
	testCharacterList();
}


void testGameLoop()
{
	GameLoop gameLoop = new GameLoop();
	gameLoop.stream.listen((GameLoopEvent event)
	{
		print("event: " + event.type);
	});
	gameLoop.start();
	new Future.delayed(new Duration(milliseconds: 300), ()
	{
		gameLoop.pause();
	});
	new Future.delayed(const Duration(milliseconds: 500), ()
	{
	});
}

void testBattleTimer()
{
	GameLoop gameLoop = new GameLoop();
	BattleTimer timer = new BattleTimer(gameLoop.stream, BattleTimer.MODE_CHARACTER);
	gameLoop.start();
	timer.start();
	timer.stream
	.where((BattleTimerEvent event)
	{
		return event.type == BattleTimerEvent.PROGRESS;
	})
	.listen((BattleTimerEvent event)
	{
		print("percent: ${event.percentage}");
	});

	new Future.delayed(new Duration(milliseconds: 300), ()
	{
		gameLoop.pause();
	});
}

void testTextDropper()
{
	Shape spot1 = new Shape();
	spot1.graphics.rectRound(0, 0, 40, 40, 6, 6);
	spot1.graphics.fillColor(Color.Blue);
	spot1.graphics.strokeColor(Color.White, 4);
	spot1.alpha = 0.4;
	stage.addChild(spot1);
	spot1.x = 40;
	spot1.y = 40;

	Shape spot2 = new Shape();
	spot2.graphics.rectRound(0, 0, 40, 40, 6, 6);
	spot2.graphics.fillColor(Color.Blue);
	spot2.graphics.strokeColor(Color.White, 4);
	spot2.alpha = 0.4;
	stage.addChild(spot2);
	spot2.x = 200;
	spot2.y = 200;

	TextDropper textDropper = new TextDropper(stage, renderLoop);

	new Stream.periodic(new Duration(seconds: 1), (_)
	{
		print("boom");
		return new Random().nextInt(9999);
	})
	.listen((int value)
	{
		print("chaka");
		textDropper.addTextDrop(spot1, value);
	});
}

void testBattleTimerBar()
{
	BattleTimerBar bar = new BattleTimerBar( new RenderLoop());
	stage.addChild(bar);
	bar.x = 20;
	bar.y = 20;

	GameLoop gameLoop = new GameLoop();
	BattleTimer timer = new BattleTimer(gameLoop.stream, BattleTimer.MODE_CHARACTER);
	gameLoop.start();
	timer.start();
	timer.stream
	.where((BattleTimerEvent event)
	{
		return event.type == BattleTimerEvent.PROGRESS;
	})
	.listen((BattleTimerEvent event)
	{
		bar.percentage = event.percentage;
	});
}

void testInitiative()
{
	GameLoop loop = new GameLoop();
	loop.start();

	ObservableList<Player> players = new ObservableList<Player>();
	players.add(new Player(Player.WARRIOR));
	players.add(new Player(Player.WARRIOR));
	players.add(new Player(Player.WARRIOR));

	ObservableList<Monster> monsters = new ObservableList<Monster>();
	monsters.add(new Monster(Monster.GOBLIN));
	monsters.add(new Monster(Monster.GOBLIN));
	monsters.add(new Monster(Monster.GOBLIN));

	Initiative initiative = new Initiative(loop.stream, players, monsters);
	initiative.stream.listen((event)
	{
		if(event.type == InitiativeEvent.CHARACTER_READY)
		{
			print("character: ${event.character}");
		}
	}).onError((error)
	{
		print("Initiative's error: $error");
		loop.pause();
	});
}

// ((96 * (Speed + 20)) * (255 - ((Battle Speed - 1) * 24))) / 16
// ((96 * (64 + 20)) * (255 - ((3 - 1) * 24))) / 16
// ((96 * 84) * (255 - (2 * 24))) / 16
// (8064 * (255 - (2 * 24))) / 16
// (8064 * (255 - 48)) / 16
// (8064 * 207) / 16
// 1669248 / 16
// 1669248 / 16
void testMath()
{
	var result = (8064 * 183) / 16;
	print(result);
	// -1407672.0
	// -1407672.0
}

void testWarriorSprite()
{
	Stage stage = new Stage(querySelector('#stage'), webGL: true);
	stage.scaleMode = StageScaleMode.SHOW_ALL;
	stage.align = StageAlign.NONE;

	RenderLoop renderLoop = new RenderLoop();
	ResourceManager resourceManager = new ResourceManager();

	renderLoop.addStage(stage);
	Juggler juggler = renderLoop.juggler;

	WarriorSprite warrior = new WarriorSprite(resourceManager);
	BlackMageSprite blackMage = new BlackMageSprite(resourceManager);
	ThiefSprite thief = new ThiefSprite(resourceManager);
	warrior.x = 100;
	warrior.y = 50;
	blackMage.x = 100;
	blackMage.y = 90;
	thief.x = 100;
	thief.y = 130;
	resourceManager.load()
	.then((_)
	{
		stage.addChild(warrior);
		stage.addChild(blackMage);
		stage.addChild(thief);
		warrior.init();
		blackMage.init();
		thief.init();
		return new Future.delayed(new Duration(seconds: 1), ()
		{
			warrior.ready();
			blackMage.ready();
			thief.ready();
		});
	})
	.then((_)
	{
		return new Future.delayed(new Duration(seconds: 1), ()
		{
			warrior.cheer();
			blackMage.cheer();
			thief.cheer();
		});
	})
	.then((_)
	{
		return new Future.delayed(new Duration(seconds: 1), ()
		{
			warrior.attack();

			var acWarrior = new AnimationChain();
			acWarrior.add(new Tween(warrior, 0.5, TransitionFunction.linear)..animate.x.to(20));
			acWarrior.add(new Tween(warrior, 0.5, TransitionFunction.linear)..animate.x.to(100));

			var acBlackMage = new AnimationChain();
			acBlackMage.add(new Tween(blackMage, 0.5, TransitionFunction.linear)..animate.x.to(20)..onComplete = () => blackMage.attack());
			acBlackMage.add(new Tween(blackMage, 0.5, TransitionFunction.linear)
				..animate.x.to(100)
				..delay = 0.5
				..onStart = () => blackMage.ready());

			var acThief = new AnimationChain();
			acThief.add(new Tween(thief, 0.5, TransitionFunction.easeInExponential)..animate.x.to(400)
				..onComplete = ()
				{
					thief.attack();
					thief.x = -40;
				});
			acThief.add(new Tween(thief, 0.4, TransitionFunction.linear)..animate.x.to(20)..onComplete = () => thief.ready());
			acThief.add(new Tween(thief, 0.5, TransitionFunction.easeInOutExponential)
				..animate.x.to(100));

			juggler.add(acWarrior);
			juggler.add(acBlackMage);
			juggler.add(acThief);


		});
	})
	.then((_)
	{
		return new Future.delayed(new Duration(seconds: 1), ()
		{
			warrior.idle();
			blackMage.idle();
			thief.idle();
		});
	})
	.catchError((e) => print(e));
}

void testCharacterList()
{
	Shape border = new Shape();
	border.graphics.rect(0, 0, 480, 420);
	border.graphics.strokeColor(Color.Black);
	stage.addChild(border);

	GameLoop loop = new GameLoop();
	loop.start();

	ObservableList<Player> players = new ObservableList<Player>();
	players.add(new Player(Player.WARRIOR));
	players.add(new Player(Player.BLACK_MAGE));
	players.add(new Player(Player.THIEF));

	ObservableList<Monster> monsters = new ObservableList<Monster>();
	monsters.add(new Monster(Monster.GOBLIN));
	monsters.add(new Monster(Monster.GOBLIN));
	monsters.add(new Monster(Monster.SILVER_LOBO));

	Initiative initiative = new Initiative(loop.stream, players, monsters);
	initiative.stream.where((event)
	{
		return event is InitiativeEvent &&
		event.type == InitiativeEvent.CHARACTER_READY;
	})
	.listen((event)
	{
		print("character ready: ${event.character}");
	});

//	MonsterList monsterList = new MonsterList(initiative: initiative,
//	resourceManager: resourceManager,
//	stage: stage,
//	renderLoop: renderLoop);
//	stage.addChild(monsterList);

	Shape fadeShapeScreen = new Shape();
	fadeShapeScreen.graphics.rect(0, 0, 480, 420);
	fadeShapeScreen.graphics.fillColor(Color.Black);
	stage.addChild(fadeShapeScreen);

	resourceManager.addBitmapData("battleTintTop", "images/battle-tint-top.png");
	resourceManager.addBitmapData("battleTintBottom", "images/battle-tint-bottom.png");
	//resourceManager.addBitmapData(Monster.TYPE_LEAFER, "design/spritesheets/monsters/" + Monster.TYPE_LEAFER + ".png");
//	resourceManager.addBitmapData("Leafer", "design/spritesheets/monsters/Leafer.png");
	resourceManager.addTextureAtlas('warrior', 'images/warrior/warrior.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addTextureAtlas('blackmage', 'images/blackmage/blackmage.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addTextureAtlas('thief', 'images/thief/thief.json', TextureAtlasFormat.JSONARRAY);


	resourceManager.addSound("battleTheme", "audio/battle-theme.mp3");
	resourceManager.addSound("encounter", "audio/encounter.mp3");

	SoundTransform soundTransform = new SoundTransform(1);
	Bitmap topTint;
	Bitmap bottomTint;
	CharacterList characterList;
	resourceManager.load()
	.then((_)
	{
		characterList = new CharacterList(initiative: initiative,
		resourceManager: resourceManager,
		stage: stage,
		renderLoop: renderLoop);
		stage.addChild(characterList);
		characterList.init();

		topTint = new Bitmap(resourceManager.getBitmapData("battleTintTop"));
		bottomTint = new Bitmap(resourceManager.getBitmapData("battleTintBottom"));
		stage.addChild(topTint);
		bottomTint.y = 94;
		stage.addChild(bottomTint);


		Sound sound = resourceManager.getSound("encounter");
		SoundChannel soundChannel = sound.play(false, soundTransform);
		num milliseconds = sound.length * 1000;
		return new Future.delayed(new Duration(milliseconds: milliseconds.ceil()), ()
		{
			return true;
		});
	})
	.then((_)
	{
		var sound = resourceManager.getSound("battleTheme");
		var soundChannel = sound.play(true, soundTransform);

		var tween = new Tween(fadeShapeScreen, 0.8, TransitionFunction.easeOutExponential);
		tween.animate.alpha.to(0);
		tween.onComplete = ()
		=> fadeShapeScreen.removeFromParent();

		const double TINT_FADE_TIME = 1.0;

		var topTintTween = new Tween(topTint, TINT_FADE_TIME, TransitionFunction.easeOutExponential);
		topTintTween.animate.alpha.to(0);
		topTintTween.animate.y.to(-200);
		topTintTween.delay = 0.1;
		topTintTween.onComplete = ()
		=> topTint.removeFromParent();

		var bottomTintTween = new Tween(bottomTint, TINT_FADE_TIME, TransitionFunction.easeOutExponential);
		bottomTintTween.animate.alpha.to(0);
		bottomTintTween.animate.y.to(294);
		bottomTintTween.delay = 0.1;
		bottomTintTween.onComplete = ()
		=> bottomTint.removeFromParent();

		stage.setChildIndex(fadeShapeScreen, stage.numChildren - 1);

		renderLoop.juggler.addGroup([tween, topTintTween, bottomTintTween]);
	});
}