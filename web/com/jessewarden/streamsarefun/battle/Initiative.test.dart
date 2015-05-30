library initiativetests;

import "package:test/test.dart";
import 'package:observe/observe.dart';
import 'battlecore.dart';
import '../core/streamscore.dart';


void main() {
	group("Initiative Tests", ()
	{
		test("basic test", ()
		{
			expect(true, true);
		});

		test("basic matcher works", ()
		{
			expect(true, isNotNull);
		});

		test("We have basic ObservablePlayers", ()
		{
			ObservableList<Player> players = new ObservableList<Player>();
			players.changes.listen((_)
			{
				expect(_, isNotNull);
			});
			players.add(new Player(Player.WARRIOR));
		});

		test("Initiative runs and generates a ready target", () async
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
			initiative.init();
			await initiative.stream.listen((event)
			{
//				print("Initiative's listen event: $event");
				loop.pause();
				expect(event, isNotNull);
			}).onError((error)
			{
				print("Initiative's error: $error");
				loop.pause();
			});
		});


	});
}
