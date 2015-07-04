library fixturesandmocksrarara;

import 'com/jessewarden/streamsarefun/battle/battlecore.dart';

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
		Monster monster1 = new Monster(Monster.ARENEID);
		monster1.hitPoints = 87;
		monster1.battlePower = 20;
		monster1.magicPower = 10;
		monster1.speed = 30;
		monster1.defense = 80;
		monster1.magicDefense = 135;
		monster1.evade = 0;
		monster1.magicBlock = 0;
		return monster1;
	}
}