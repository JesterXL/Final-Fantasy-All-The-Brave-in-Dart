part of battlecore;

class CharacterEvent
{
	static const HIT_POINTS_CHANGED = "hitPointsChanged";
	static const NO_LONGER_SWOON = "noLongerSwoon";
	static const SWOON = "swoon";
	static const BATTLE_STATE_CHANGED = "battleStateChanged";

	String type;
	Character target;
	BattleState oldBattleState;
	BattleState newBattleState;
	int changeAmount;

	CharacterEvent({String this.type,
	               Character this.target,
	               BattleState this.oldBattleState,
	               BattleState this.newBattleState}){}
}