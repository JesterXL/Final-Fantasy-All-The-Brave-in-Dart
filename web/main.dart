import 'dart:html';
import 'dart:core';
import 'dart:async';
import 'dart:math';
import 'package:stagexl/stagexl.dart';
import 'package:observe/observe.dart';
import 'com/jessewarden/streamsarefun/core/streamscore.dart';
import 'com/jessewarden/streamsarefun/battle/battlecore.dart';
import 'com/jessewarden/streamsarefun/components/components.dart';

CanvasElement canvas;
Stage stage;
RenderLoop renderLoop;
//ResourceManager resourceManager;
//CursorFocusManager cursorManager;

void main()
{
	querySelector('#output').text = 'Your Dart app is running.';

	canvas = querySelector('#stage');
	canvas.context2D.imageSmoothingEnabled = true;

	stage = new Stage(canvas, webGL: false);
	renderLoop = new RenderLoop();
	renderLoop.addStage(stage);

//	resourceManager = new ResourceManager();
//	cursorManager = new CursorFocusManager(stage, resourceManager);

	//testGameLoop();
//  testBattleTimer();
//	testTextDropper();
//	testBattleTimerBar();
	testInitiative();

//	testMath();
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
	BattleTimerBar bar = new BattleTimerBar();
	stage.addChild(bar);

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