part of battlecore;

class BattleControllerEvent
{
	static const String CHARACTER_READY = "characterReady";
	static const String ACTION_RESULT = "actionResult";
	static const String LOST = "lost";
	static const String WON = "won";

	String type;
	BattleController target;
	Character character;
	ActionResult actionResult;

	BattleControllerEvent(this.type,
	                      this.target,
	                      {Character character: null,
	                      ActionResult actionResult: null
	                      })
	{
		this.character = character;
		this.actionResult = actionResult;
	}
}