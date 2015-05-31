part of battlecore;

class CharacterEvent
{
	static const HIT_POINTS_CHANGED = "hitPointsChanged";
	static const NO_LONGER_SWOON = "noLongerSwoon";
	static const SWOON = "swoon";
	static const BATTLE_STATE_CHANGED = "battleStateChanged";

	String type;
	Character target;
	String oldBattleState;
	String newBattleState;
	int changeAmount;

	CharacterEvent({String this.type,
	               Character this.target,
	               String this.oldBattleState,
	               String this.newBattleState}){}
}