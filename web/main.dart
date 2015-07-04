import 'dart:html';
import 'dart:core';
import 'dart:async';
import 'dart:math';
import 'package:stagexl/stagexl.dart';
import 'package:observe/observe.dart';
//import 'package:frappe/frappe.dart';
import 'package:jxlstatemachine/jxlstatemachine.dart';

import 'com/jessewarden/streamsarefun/battle/battlecore.dart';
import 'com/jessewarden/streamsarefun/components/components.dart';
import 'com/jessewarden/streamsarefun/sprites/sprites.dart';
import 'com/jessewarden/streamsarefun/managers/managers.dart';
import 'Fixtures.dart';

CanvasElement canvas;
Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;
CursorFocusManager cursorManager;

void main()
{
	querySelector('#output').text = 'Your Dart app is running.';

	canvas = querySelector('#stage');
	canvas.context2D.imageSmoothingEnabled = true;

	StageOptions options = new StageOptions();
	options.renderEngine = RenderEngine.Canvas2D;
	stage = new Stage(canvas, width: 1024, height: 768, options: options);
	renderLoop = new RenderLoop();
	renderLoop.addStage(stage);

	resourceManager = new ResourceManager();
	cursorManager = new CursorFocusManager(stage, resourceManager);

	//testGameLoop();
//  testBattleTimer();
//	testTextDropper();
//	testBattleTimerBar();
//	testBattleTimerBars();
//	testInitiative();
//	testMath();
//	testWarriorSprite();
//	testCharacterList();
//	testBattleMenu();
	testBasicAttack();
//testingMerge();
//	test();
//	testBasicAttack();
//	testBattleController();
//testingMultipleEventStream();
//testJuggler();
//testWait();
//	testIntentQueue();
//testAsyncTweens();
//	testAsyncTweens2();
//testAwaitStreams();
//testCursorManagerMonsterList();
//testFixtures();
//	testBasicAttack();
//testRandomListShuffle();
}


void testFixtures()
{
	var player = Fixtures.getLockeLevel7();
	print("player: $player");
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
	BattleTimer timer = new BattleTimer(BattleTimer.MODE_PLAYER);
	timer.stream
	.where((BattleTimerEvent event)
	{
		return event.type == BattleTimerEvent.PROGRESS;
	})
	.listen((BattleTimerEvent event)
	{
		print("percent: ${event.percentage}");
	});
	stage.renderLoop.juggler.add(timer);

	new Future.delayed(new Duration(milliseconds: 300), ()
	{
		stage.renderLoop.juggler.remove(timer);
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
	Juggler juggler = new Juggler();

	BattleTimerBar bar = new BattleTimerBar(juggler);
	stage.addChild(bar);
	bar.x = 20;
	bar.y = 20;

	BattleTimer timer = new BattleTimer(BattleTimer.MODE_PLAYER);
	timer.stream
	.listen((BattleTimerEvent event)
	{
		bar.percentage = event.percentage;
		print("bar.percentage: ${bar.percentage}");
		if(event.type == BattleTimerEvent.COMPLETE)
		{
			timer.enabled = false;
			new Future.delayed(new Duration(seconds: 2), ()
			{
				timer.reset();
				timer.enabled = true;
				juggler.add(timer);
			});
		}
	});
	juggler.add(timer);
	stage.renderLoop.juggler.add(juggler);
}

void testBattleTimerBars()
{
	Juggler juggler = new Juggler();

	BattleTimerBar getBattleTimerBar(num x, num y)
	{
		BattleTimerBar bar = new BattleTimerBar(juggler);
		stage.addChild(bar);
		bar.x = x;
		bar.y = y;
		return bar;
	}

	BattleTimer getBattleTimer(BattleTimerBar bar)
	{
		BattleTimer timer = new BattleTimer(BattleTimer.MODE_PLAYER);
		timer.stream
		.listen((BattleTimerEvent event)
		{
			bar.percentage = event.percentage;
		});
		timer.speed = BattleUtils.getRandomNumberFromRange(80, 100);
		juggler.add(timer);
		return timer;
	}

	var bars = new List(100);
	bars.fillRange(0, 100, 0);
	var index = 1;
	bars = bars.map((_)
	{
		return getBattleTimerBar(20, 20 * index++);
	});
	bars.forEach((bar)
	{
		getBattleTimer(bar);
	});

	stage.renderLoop.juggler.add(juggler);
}

void testInitiative()
{
	Juggler juggler = new Juggler();

	ObservableList<Player> players = new ObservableList<Player>();
	players.add(new Player(characterType: Player.WARRIOR));
	players.add(new Player(characterType: Player.WARRIOR));
	players.add(new Player(characterType: Player.WARRIOR));

	ObservableList<Monster> monsters = new ObservableList<Monster>();
	monsters.add(new Monster(Monster.LEAFER));
	monsters.add(new Monster(Monster.LEAFER));
	monsters.add(new Monster(Monster.LEAFER));

	Initiative initiative = new Initiative(players, monsters, juggler);
	initiative.stream.listen((event)
	{
		print("event: ${event.type}");

		if(event.type == InitiativeEvent.PLAYER_READY)
		{
			print("character: ${event.character}");
			stage.renderLoop.juggler.remove(juggler);
		}
	});
	initiative.start();

	stage.renderLoop.juggler.add(juggler);

//	.onError((error)
//	{
//		print("Initiative's error: $error");
//		loop.pause();
//	});
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
			acWarrior.add(new Tween(warrior, 0.5, Transition.linear)..animate.x.to(20));
			acWarrior.add(new Tween(warrior, 0.5, Transition.linear)..animate.x.to(100));

			var acBlackMage = new AnimationChain();
			acBlackMage.add(new Tween(blackMage, 0.5, Transition.linear)..animate.x.to(20)..onComplete = () => blackMage.attack());
			acBlackMage.add(new Tween(blackMage, 0.5, Transition.linear)
				..animate.x.to(100)
				..delay = 0.5
				..onStart = () => blackMage.ready());

			var acThief = new AnimationChain();
			acThief.add(new Tween(thief, 0.5, Transition.easeInExponential)..animate.x.to(400)
				..onComplete = ()
				{
					thief.attack();
					thief.x = -40;
				});
			acThief.add(new Tween(thief, 0.4, Transition.linear)..animate.x.to(20)..onComplete = () => thief.ready());
			acThief.add(new Tween(thief, 0.5, Transition.easeInOutExponential)
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
	var juggler = Fixtures.getJugglerAndAddToStage(stage);

	ObservableList<Player> players = new ObservableList<Player>();
	players.add(new Player(characterType: Player.WARRIOR));
	players.add(new Player(characterType: Player.BLACK_MAGE));
	players.add(new Player(characterType: Player.THIEF));

	ObservableList<Monster> monsters = new ObservableList<Monster>();
	monsters.add(new Monster(Monster.LEAFER));
	monsters.add(new Monster(Monster.LEAFER));
	monsters.add(new Monster(Monster.LEAFER));

	Initiative initiative = new Initiative(juggler, players, monsters);
	initiative.stream.where((event)
	{
		return event is InitiativeEvent &&
		event.type == InitiativeEvent.PLAYER_READY;
	})
	.listen((event)
	{
		//print("character ready: ${event.character}");
		ObservableList<MenuItem> items = new ObservableList<MenuItem>();
		items.add(new MenuItem("Fight"));
		items.add(new MenuItem("Magic"));
		items.add(new MenuItem("Item"));

		Menu menu = new Menu(300, 280, items);
		stage.addChild(menu);
		menu.x = 20;
		menu.y = 20;

		menu.stream
		.listen((String item)
		{
			switch(item)
			{
				case "Fight":
					// attack and get hit + damage result
					// animate
					// apply damage
					// animate
					// unpause battle timer

			}
		});
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
		juggler: juggler);
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

		var tween = new Tween(fadeShapeScreen, 0.8, Transition.easeOutExponential);
		tween.animate.alpha.to(0);
		tween.onComplete = ()
		=> fadeShapeScreen.removeFromParent();

		const double TINT_FADE_TIME = 1.0;

		var topTintTween = new Tween(topTint, TINT_FADE_TIME, Transition.easeOutExponential);
		topTintTween.animate.alpha.to(0);
		topTintTween.animate.y.to(-200);
		topTintTween.delay = 0.1;
		topTintTween.onComplete = ()
		=> topTint.removeFromParent();

		var bottomTintTween = new Tween(bottomTint, TINT_FADE_TIME, Transition.easeOutExponential);
		bottomTintTween.animate.alpha.to(0);
		bottomTintTween.animate.y.to(294);
		bottomTintTween.delay = 0.1;
		bottomTintTween.onComplete = ()
		=> bottomTint.removeFromParent();

		stage.setChildIndex(fadeShapeScreen, stage.numChildren - 1);

		renderLoop.juggler.addGroup([tween, topTintTween, bottomTintTween]);

		initiative.start();
	});
}

void testBattleMenu()
{
	resourceManager.addSound("menuBeep", "audio/menu-beep.mp3");
	CursorFocusManager cursorManager = new CursorFocusManager(stage, resourceManager);

	GameLoop loop = new GameLoop();
	loop.start();

	BattleMenu battleMenu = new BattleMenu(resourceManager, cursorManager, stage);
	battleMenu.stream
	.listen((BattleMenuEvent event)
	{
		print("item selected: ${event.item}");
	});

	resourceManager.load()
	.then((_)
	{
		battleMenu.show();
	});
}

void testBasicAttack()
{
	var juggler = Fixtures.getJugglerAndAddToStage(stage);
	var players = Fixtures.getPlayerList();
	var monsters = Fixtures.getMonsterList();
	var initiative = new Initiative(juggler, players, monsters);
	var characterList = new CharacterList(
		initiative: initiative,
		resourceManager: resourceManager,
		juggler: juggler,
		stage: stage
	);
	stage.addChild(characterList);
	var monsterList = new MonsterList(
		initiative: initiative,
		resourceManager: resourceManager,
		juggler: juggler,
		stage: stage
	);
	stage.addChild(monsterList);
	var battleMenu = new BattleMenu(resourceManager, cursorManager, stage, monsterList, characterList);
	var queue = new IntentQueue(juggler, initiative, characterList, monsterList);
	juggler.add(queue);
	queue.stream.listen((Intent completedIntent)
	{
		print("queue::stream::listen::intent completed, resetting timer for: ${completedIntent.attacker}");
		initiative.resetCharacterTimer(completedIntent.attacker);
	});

	Character getRandomTarget(ObservableList<Character> targets)
	{
		List copy = targets.toList();
		copy = copy.map((Character character)
		{
			if(character.dead == false)
			{
				return character;
			}
		}).toList();
		Random random = new Random();
		copy.shuffle(random);
		if(copy.length > 0)
		{
			return copy[0];
		}
		else
		{
			return null;
		}
	}

	var streamSubscription;
	var battleMenuStreamSubscription;
	var actingPlayer;
	var battleStateMachine = new StateMachine();
	battleStateMachine.addState('loading');
	battleStateMachine.addState('waiting',
		enter: ()
		{
			if(streamSubscription == null)
			{
				streamSubscription = initiative.stream
				.where((event)
				{
					return event is InitiativeEvent;
				})
				.listen((InitiativeEvent event)
				{
					switch(event.type)
					{
						case InitiativeEvent.PLAYER_READY:
							actingPlayer = event.character;
							battleStateMachine.changeState('characterChoosing');
							break;

						case InitiativeEvent.MONSTER_READY:
							var intent = new Intent();
							var target = getRandomTarget(players);
							intent.attacker = event.character;
							intent.targets = [target];
							intent.isPhysicalAttack = true;
							intent.hitRate = event.character.hitRate;
							queue.addIntent(intent);
							break;

						case InitiativeEvent.LOST:
							print("****************** LOST ******************");
							break;

						case InitiativeEvent.WON:
							print("****************** WON ******************");
							break;


					}

				});
			}
		}
	);
	battleStateMachine.addState('characterChoosing',
		from: ['waiting'],
		enter: ()
		{
			battleMenuStreamSubscription = battleMenu.stream
			.listen((BattleMenuEvent event)
			{
				if(event.item is Bitmap)
				{
					var monster = monsterList.getMonsterForBitmap(event.item);
					var intent = new Intent();
					intent.attacker = actingPlayer;
					intent.targets = [monster];
					intent.isPhysicalAttack = true;
					intent.hitRate = actingPlayer.hitRate;
					queue.addIntent(intent);
				}
				battleStateMachine.changeState('waiting');

			});
			battleMenu.show();
		},
		exit: ()
		{
			actingPlayer = null;
			battleMenuStreamSubscription.cancel();
			battleMenuStreamSubscription = null;
		}
	);
	battleStateMachine.addState('win');
	battleStateMachine.addState('lost');
	battleStateMachine.changes.listen((StateMachineEvent event)
	{
		print("battleStateMachine state change: ${battleStateMachine.currentState.name}");
	});
	battleStateMachine.initialState = 'loading';

	resourceManager.addTextureAtlas('warrior', 'images/warrior/warrior.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addTextureAtlas('blackmage', 'images/blackmage/blackmage.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addTextureAtlas('thief', 'images/thief/thief.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addBitmapData("Leafer", "images/monsters/leafer.png");
	resourceManager.addBitmapData("Areneid", "images/monsters/areneid.png");
	resourceManager.addSound("menuBeep", "audio/menu-beep.mp3");

	resourceManager.load()
	.then((_)
	{
		characterList.init();
		monsterList.init();
		battleStateMachine.changeState('waiting');
	});
}

void testBattleController()
{
	GameLoop loop = new GameLoop();
	loop.start();

	ObservableList<Player> players = new ObservableList<Player>();
	players.add(new Player(Player.WARRIOR));
	players.add(new Player(Player.BLACK_MAGE));
	players.add(new Player(Player.THIEF));

	ObservableList<Monster> monsters = new ObservableList<Monster>();
	monsters.add(new Monster(Monster.LEAFER));
	monsters.add(new Monster(Monster.LEAFER));
	monsters.add(new Monster(Monster.LEAFER));

	Initiative initiative = new Initiative(loop.stream, players, monsters);
	BattleController battleController = new BattleController(initiative);

}

void testingMultipleEventStream()
{
	var one = new StreamController();
	one.stream.listen((_)
	{
		print("stream listen: $_");
	});
	one.stream.where((_)
	{
		return _ == "tres";
	})
	.listen((_)
	{
		print("where: $_");
	});
	one.add("uno");
	one.add("dos");
	one.add("tres");
}

void testJuggler()
{
	Juggler juggler = renderLoop.juggler;

	void run() async
	{
		await for (var elapsedTime in juggler.onElapsedTimeChange) {
			print(elapsedTime);
		}
	}

	run();
	new Future.delayed(new Duration(seconds: 2), ()
	{
		renderLoop.stop();
	});
}

void testWait1()
{
	StreamController con = new StreamController();
	void run() async
	{
		await for(num number in con.stream)
		{
			print("number: $number");
		}
	}
	run();
	new Timer.periodic(new Duration(seconds: 1), (Timer timer)
	{
		con.add(new Random().nextInt(10));
	});
}

void testWait2()
{
	StreamController con = new StreamController();
	con.stream.listen((num number)
	{
		print("number: $number");
	});
	new Timer.periodic(new Duration(seconds: 1), (Timer timer)
	{
		con.add(new Random().nextInt(10));
	});
}

void testIntentQueue()
{
	var juggler = new Juggler();
	var queue = new IntentQueue(juggler);
	stage.renderLoop.juggler.add(juggler);
	juggler.add(queue);
	queue.stream.listen((_)
	{
		print("event: $_");
	});
	queue.addIntent(new Intent());
}

void testAsyncTweens()
{
	Future doThreeTweens()
	{
		var completer = new Completer();
		var chain = stage.renderLoop.juggler.addChain([
			new Tween(stage, 1),
			new Tween(stage, 1),
			new Tween(stage, 1)
		]);
		chain.onComplete = ()
		{
			print("All 3 tweens completed, calling completer.complete...");
			completer.complete(true);
		};
		return completer.future;
	}
	print("Calling...");
	doThreeTweens().then((_)
	{
		print("Future complete: $_");
	});
	print("After Future then.");
}

void testAsyncTweens2() async
{
	Future doThreeTweens()
	{
		var completer = new Completer();
		var chain = stage.renderLoop.juggler.addChain([
			new Tween(stage, 1),
			new Tween(stage, 1),
			new Tween(stage, 1)
		]);
		chain.onComplete = ()
		{
			print("All 3 tweens completed, calling completer.complete...");
			completer.complete(true);
		};
		return completer.future;
	}
	print("Calling...");
	var result = await doThreeTweens();
	print("result: $result");
	print("After Future then.");
}

void testAwaitStreams() async
{
	print("testAwaitStreams");
	var controller = new StreamController();
	var stream = controller.stream;
	void bunchOfStuff() async
	{
		new Future.delayed(new Duration(seconds: 1), ()
		{
			print("1");
			controller.add(1);
		})
		.then((_)
		{
			return new Future.delayed(new Duration(seconds: 1), ()
			{
				print("2");
				controller.add(2);
			});
		});
	}

	bunchOfStuff();
	await for (var i in stream)
	{
		print('i $i');
	}
}

void testCursorManagerMonsterList()
{
	var juggler = new Juggler();
	stage.renderLoop.juggler.add(juggler);

	ObservableList<Player> players = new ObservableList<Player>();
	Player player1 = Fixtures.getLockeLevel7();
	players.add(player1);

	ObservableList<Monster> monsters = new ObservableList<Monster>();
	Monster monster1 = Fixtures.getAreneid();
	monsters.add(monster1);

	Initiative initiative = new Initiative(stage.renderLoop.juggler, players, monsters);

	CharacterList characterList = new CharacterList(
		initiative: initiative,
		resourceManager: resourceManager,
		juggler: juggler,
		stage: stage
	);
	stage.addChild(characterList);

	MonsterList monsterList = new MonsterList(
		initiative: initiative,
		resourceManager: resourceManager,
		juggler: juggler,
		stage: stage
	);
	stage.addChild(monsterList);

	BattleMenu battleMenu = new BattleMenu(resourceManager, cursorManager, stage, monsterList, characterList);

	IntentQueue queue = new IntentQueue(juggler, initiative, characterList, monsterList);
	juggler.add(queue);
	queue.stream.listen((Intent completedIntent)
	{
		initiative.resetCharacterTimer(completedIntent.attacker);
	});

	battleMenu.stream
	.listen((BattleMenuEvent event)
	{
		var bitmap = event.item;
		var monster = monsterList.getMonsterForBitmap(bitmap);
		print("monster: ${monster}");
	});

	resourceManager.addTextureAtlas('warrior', 'images/warrior/warrior.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addTextureAtlas('blackmage', 'images/blackmage/blackmage.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addTextureAtlas('thief', 'images/thief/thief.json', TextureAtlasFormat.JSONARRAY);
	resourceManager.addBitmapData("Leafer", "images/monsters/leafer.png");
	resourceManager.addBitmapData("Areneid", "images/monsters/areneid.png");

	resourceManager.load()
	.then((_)
	{
		characterList.init();
		monsterList.init();
		battleMenu.show();
	});
}

void testRandomListShuffle()
{
	var list = ["one", "two", "three"];
	List copy = list.toList();
	Random random = new Random();
	copy.shuffle(random);
	print("copy: ${copy[0]}");
}