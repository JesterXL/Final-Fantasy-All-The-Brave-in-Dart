part of battlecore;

class CharacterEvent
{
	static const HIT_POINTS_CHANGED = "hitPointsChanged";
	static const NO_LONGER_SWOON = "noLongerSwoon";
	static const SWOON = "swoon";
	static const BATTLE_STATE_CHANGED = "battleStateChanged";
	static const ROW_CHANGED = "rowChanged";

	String type;
	Character target;
	BattleState oldBattleState;
	BattleState newBattleState;
	Row oldRow;
	Row newRow;
	int changeAmount;

	CharacterEvent({String this.type,
	               Character this.target,
	               BattleState this.oldBattleState,
	               BattleState this.newBattleState,
					Row this.oldRow,
					Row this.newRow,
					int this.changeAmount}){}
}