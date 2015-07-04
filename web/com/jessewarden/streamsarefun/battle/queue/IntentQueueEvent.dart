part of battlecore;

class IntentQueueEvent
{
	static const String ATTACK = "attack";

	String type;
	Intent intent;
	TargetHitResult targetHitResult;

	IntentQueueEvent(String this.type, Intent this.intent, TargetHitResult this.targetHitResult)
	{

	}
}