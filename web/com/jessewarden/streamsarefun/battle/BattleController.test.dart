library battlecontrollertests;

import "package:test/test.dart";
import 'battlecore.dart';
import 'package:observe/observe.dart';

void main()
{
	GameLoop loop;
	ObservableList<Player> players;
	ObservableList<Monster> monsters;
	Initiative initiative;
	BattleController battleController;

	setUp(()
	{
		loop = new GameLoop();
		loop.start();

		players = new ObservableList<Player>();
		players.add(new Player(Player.WARRIOR));
		players.add(new Player(Player.BLACK_MAGE));
		players.add(new Player(Player.THIEF));

		monsters = new ObservableList<Monster>();
		monsters.add(new Monster(Monster.GOBLIN));
		monsters.add(new Monster(Monster.GOBLIN));
		monsters.add(new Monster(Monster.GOBLIN));

		initiative = new Initiative(loop.stream, players, monsters);
		battleController = new BattleController(initiative);
	});


	group("BattleController tests", ()
	{

		test("class is legit", ()
		{
			expect(battleController.stream, isNotNull);
		});

		test("test basic service", () async
		{
			expect(battleController.stream, isNotNull);
			battleController.stream
			.listen((_)
			{
				expect(true, isTrue);
			});
		});
	});
}