part of battlecore;

class Attack
{
	bool isPhysicalAttack = true;
	bool isMagicalAttack = false;
	bool targetHasClearStatus = false;
	bool protectedFromWound = false;
	bool attackMissesDeathProtectedTargets = false;
	bool attackCanBeBlockedByStamina = true;
	bool spellUnblockable = false;
	bool targetHasSleepStatus = false;
	bool targetHasPetrifyStatus = false;
	bool targetHasFreezeStatus = false;
	bool targetHasStopStatus = false;
	bool backOfTarget = false;
	bool targetHasImageStatus = false;
	int hitRate = 180; // TODO: need weapon's info, this is where hitRate comes from
	int magicBlock = 0;
	int targetStamina = null;
	AttackType specialAttackType = null;

	Attack({
	       bool isPhysicalAttack: true,
	       bool isMagicalAttack: false,
	       bool targetHasClearStatus: false,
	       bool protectedFromWound: false,
	       bool attackMissesDeathProtectedTargets: false,
	       bool attackCanBeBlockedByStaminia: true,
	       bool spellUnblockable: false,
	       bool targetHasSleepStatus: false,
	       bool targetHasPetrifyStatus: false,
	       bool targetHasFreezeStatus: false,
	       bool targetHasStopStatus: false,
	       bool backOfTarget: false,
	       bool targetHasImageStatus: false,
	       int hitRate: 180,
	       int magicBlock: null,
	       int targetStamina: null,
	       AttackType specialAttackType: null
	       })
	{
	}
}