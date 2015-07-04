library fixturesandmocksrarara;

import 'com/jessewarden/streamsarefun/battle/battlecore.dart';
import 'package:stagexl/stagexl.dart';
import 'package:observe/observe.dart';

class Fixtures
{
	static Player getLockeLevel7()
	{
		Player player1 = new Player(
			characterType: Player.WARRIOR,
			name: 'Locke',
			speed: getRandomSpeed()
		);
		player1.battlePower = 40;
		player1.defense = 85;
		player1.evade = 15;
		player1.magicDefense = 49;
		player1.magicBlock = 20;
		player1.vigor = 37;
		player1.stamina = 31;
		player1.magicPower = 28;
		player1.level = 7;
		player1.hitPoints = 144;
		player1.hitRate = 180;
		return player1;
	}

	static int getRandomSpeed()
	{
//		int min = 20;
//		int max = 80;
		int min = 80;
		int max = 100;
		int result = BattleUtils.getRandomNumberFromRange(min, max);
		return result;
//		new Random().nextInt(10);
	}

	static Monster getAreneid()
	{
		Monster monster = new Monster(Monster.ARENEID);
		monster.level = 6;
		monster.hitPoints = 87;
		monster.battlePower = 20;
		monster.magicPower = 10;
		monster.speed = 30;
		monster.defense = 80;
		monster.magicDefense = 135;
		monster.evade = 0;
		monster.magicBlock = 0;
		return monster;
	}

	static Monster getLeafer()
	{
		Monster monster = new Monster(Monster.LEAFER);
		monster.level = 5;
		monster.hitPoints = 33;
		monster.battlePower = 13;
		monster.magicPower = 10;
		monster.speed = 30;
		monster.defense = 60;
		monster.magicDefense = 140;
		monster.evade = 0;
		monster.magicBlock = 0;
		return monster;
	}

	static Juggler getJugglerAndAddToStage(Stage stage)
	{
		Juggler juggler = new Juggler();
		stage.renderLoop.juggler.add(juggler);
		return juggler;
	}

	static List<Player> getPlayerList()
	{
		var speed = 130;
		ObservableList<Player> players = new ObservableList<Player>();
		players.add(new Player(characterType: Player.WARRIOR, speed: speed));
		players.add(new Player(characterType: Player.BLACK_MAGE, speed: speed));
		players.add(new Player(characterType: Player.THIEF, speed: speed));
		return players;
	}

	static List<Monster> getMonsterList()
	{
		ObservableList<Monster> monsters = new ObservableList<Monster>();
		monsters.add(Fixtures.getAreneid());
//		monsters.add(Fixtures.getLeafer());
//		monsters.add(Fixtures.getLeafer());
		return monsters;
	}
}