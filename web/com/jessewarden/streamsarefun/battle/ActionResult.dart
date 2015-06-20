part of battlecore;

class ActionResult
{
	Character attacker;
	List<Character> targets;
	AttackType attackType;
	List<TargetHitResult> targetHitResults;

	ActionResult({
	             Character this.attacker,
	             List<Character> this.targets,
	             AttackType this.attackType,
	             List<TargetHitResult> this.targetHitResults
	             })
	{
	}
}