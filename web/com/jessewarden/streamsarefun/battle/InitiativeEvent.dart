part of battlecore;

class InitiativeEvent
{
	static const String INITIALIZED = "initialized";
	static const String PLAYER_READY = "characterReady";
	static const String MONSTER_READY = "monsterReady";
	static const String PAUSED = "paused";
	static const String WON = "won";
	static const String LOST = "lost";

	String type;
	Character character;
	num percentage;

	InitiativeEvent(this.type, {Character character: null})
	{
		this.character = character;
	}
}