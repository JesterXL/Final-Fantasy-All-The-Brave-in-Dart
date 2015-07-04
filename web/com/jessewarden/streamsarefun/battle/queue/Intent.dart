part of battlecore;

class Intent
{
	Character attacker;
	List<Character> targets;
	bool isPhysicalAttack;
	bool isMagicalAttack;
	bool attackMissesDeathProtectedTargets;
	bool attackCanBeBlockedByStamina;
	bool spellUnblockable;
	int hitRate;
	AttackType specialAttackType;
	Spell spell;
	Item item;

	Intent({
		Character this.attacker,
		List<Character> this.targets,
		bool this.isPhysicalAttack: true,
		bool this.isMagicalAttack: false,
		bool this.attackMissesDeathProtectedTargets: false,
		bool this.attackCanBeBlockedByStamina: true,
		bool this.spellUnblockable: false,
		int this.hitRate: 180,
		AttackType this.specialAttackType: null,
		Spell this.spell: null,
		Item this.item: null
	})
	{
	}
}
