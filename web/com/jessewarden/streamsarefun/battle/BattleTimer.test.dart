library battletimertest;

import "package:test/test.dart";
import 'battlecore.dart';


void main() {
	group("BattleTimer Tests", ()
	{
		test("basic test", ()
		{
			expect(true, true);
		});

		test("basic matcher works", ()
		{
			expect(true, isNotNull);
		});

		test("BattleTimer runs and generates a percentage", () async
		{
			GameLoop gameLoop = new GameLoop();
			BattleTimer timer = new BattleTimer(gameLoop.stream, BattleTimer.MODE_PLAYER);
			gameLoop.start();
			timer.start();
			await timer.stream
			.where((BattleTimerEvent event)
			{
				return event.type == BattleTimerEvent.PROGRESS;
			})
			.listen((BattleTimerEvent event)
			{
				expect(event.percentage, isNotNull);
				expect(event.percentage, isNotNaN);
				expect(event.percentage, equals(timer.progress));
			});
		});

		test("Default BattleTimer progress is 0", ()
		{
			BattleTimer timer = new BattleTimer(new GameLoop().stream, BattleTimer.MODE_PLAYER);
			expect(timer.progress, equals(0));
		});

		test("constructed character mode matches character", ()
		{
			expect(new BattleTimer(new GameLoop().stream, BattleTimer.MODE_PLAYER).mode, equals(BattleTimer.MODE_PLAYER));
		});

		test("constructed monster mode matches monster", ()
		{
			expect(new BattleTimer(new GameLoop().stream, BattleTimer.MODE_MONSTER).mode, equals(BattleTimer.MODE_MONSTER));
		});

		test("timer enabled by deafult", ()
		{
			expect(new BattleTimer(new GameLoop().stream, BattleTimer.MODE_PLAYER).enabled, isTrue);
		});

		test("timer running false by default", ()
		{
			BattleTimer timer = new BattleTimer(new GameLoop().stream, BattleTimer.MODE_PLAYER);
			expect(timer.running, isFalse);
		});

		test("timer running true when started", ()
		{
			BattleTimer timer = new BattleTimer(new GameLoop().stream, BattleTimer.MODE_PLAYER);
			timer.start();
			expect(timer.running, isTrue);
		});

		test("timer stops running when you disable it", ()
		{
			BattleTimer timer = new BattleTimer(new GameLoop().stream, BattleTimer.MODE_PLAYER);
			timer.start();
			timer.enabled = false;
			expect(timer.running, isFalse);
		});
	});
}
