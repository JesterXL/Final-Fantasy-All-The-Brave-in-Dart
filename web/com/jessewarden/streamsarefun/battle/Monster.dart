part of battlecore;

class Monster extends Character
{
	static const String LEAFER = "Leafer";
	static const String ARENEID = "Areneid";

	String monsterType;

	Monster(String this.monsterType)
	{
		vigor = BattleUtils.getRandomMonsterVigor();
	}
}