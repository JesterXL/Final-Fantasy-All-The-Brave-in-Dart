part of battlecore;

class Player extends Character
{
	static const String WARRIOR = "Warrior";
	static const String BLACK_MAGE = "Black Mage";
	static const String THIEF = "Thief";

	String _characterType;

	String get characterType => _characterType;

	Player({String characterType, String name: 'Default'})
	{
		_characterType = characterType;
		this.name = name;

	}
}