part of battlecore;

class BattleUtils
{
	static int PERFECT_HIT_RATE = 255;

	static int divide(num a, num b)
	{
		return (a / b).floor();
	}

	static int getRandomNumberFromRange(int start, int end)
	{
		return new Random().nextInt((end - start) + 1) + start;
	}

	static int getCharacterPhysicalDamageStep1({
	                                           num strength: 1,
	                                           num battlePower: 1,
	                                           int level: 1,
	                                           bool equippedWithGauntlet: false,
	                                           bool equippedWithOffering: false,
	                                           bool standardFightAttack: true,
	                                           bool genjiGloveEquipped: false,
	                                           bool oneOrZeroWeapons: true
	                                           })
	{
		num strength2 = strength * 2;
		if(strength >= 128)
		{
			strength2 = 255;
		}

		num attack = battlePower + strength2;

		if(equippedWithGauntlet)
		{
			attack += (battlePower * 3/4);
		}

		num damage = battlePower + ( (level * level * attack) / 256) * 3/2;

		if(equippedWithOffering)
		{
			damage /= 2;
		}

		if(standardFightAttack && genjiGloveEquipped && oneOrZeroWeapons)
		{
			damage = (damage * 3/4).ceil();
		}

		return damage.round();
	}

	static int getRandomMonsterStrength()
	{
		return getRandomNumberFromRange(56, 63);
	}

	static num getMonsterPhysicalDamageStep1({int level: 1, num battlePower: 1, int strength: 1})
	{
		return level * level * (battlePower * 4 + strength) / 256;
	}

	static num getCharacterDamageStep2({num damage: 0,
	                                   bool isMagicalAttacker: false,
	                                   bool isPhysicalAttack: true,
	                                   bool isMagicalAttack: false,
	                                   bool equippedWithAtlasArmlet: false,
	                                   bool equippedWith1HeroRing: false,
	                                   bool equippedWith2HeroRings: false,
	                                   bool equippedWith1Earring: false,
	                                   bool equippedWith2Earrings: false
	                                   })
	{
		if(isPhysicalAttack && (equippedWithAtlasArmlet || equippedWith1HeroRing))
		{
			damage *= 5/4;
		}

		if(isMagicalAttack && (equippedWith1Earring || equippedWith2HeroRings))
		{
			damage *= 5/4;
		}

		if(isMagicalAttack && (equippedWith2Earrings || equippedWith2HeroRings))
		{
			damage += (damage / 4) + (damage / 4);
		}

		return damage;
	}

	static num getMagicalMultipleTargetsAttack(num damage)
	{
		return damage / 2;
	}

	static num getAttackerBackRowFightCommand(num damage)
	{
		return damage / 2;
	}

	static bool getCriticalHit()
	{
		Random digit = new Random();
		return digit.nextInt(31) == 31;
	}

	static num getDamageMultipliers({num damage: 0,
	                                bool hasMorphStatus: false,
	                                bool hasBerserkStatusAndPhysicalAttack: false,
	                                bool isCriticalHit: false})
	{
		num multiplier = 1;

		if(hasMorphStatus)
		{
			multiplier += 2;
		}

		if(hasBerserkStatusAndPhysicalAttack)
		{
			multiplier += 1;
		}

		if(isCriticalHit)
		{
			multiplier += 2;
		}

		damage += ((damage / 2) * multiplier);
		return damage;
	}

	static num getDamageModificationsVariance()
	{
		return getRandomNumberFromRange(224, 255);
	}

	static num getDamageModifications({num damage: 0,
	                                  num defense: 0,
	                                  num magicalDefense: 0,
									  num variance: 224,
	                                  bool isPhysicalAttack: true,
	                                  bool isMagicalAttack: false,
	                                  bool targetHasSafeStatus: false,
	                                  bool targetHasShellStatus: false,
	                                  bool targetDefending: false,
	                                  bool targetIsInBackRow: false,
	                                  bool targetHasMorphStatus: false,
	                                  bool targetIsSelf: false,
	                                  bool targetIsCharacter: false,
	                                  bool attackerIsCharacter: true})
	{

		num defenseToUse = 1;
		if(isPhysicalAttack)
		{
			defenseToUse = defense;
		}
		else
		{
			defenseToUse = magicalDefense;
		}

		damage += (damage * variance / 256) + 1;

		// safe / shell
		if((isPhysicalAttack && targetHasSafeStatus) || (isMagicalAttack && targetHasShellStatus))
		{
			damage = (damage * 170 / 256) + 1;
		}

		// target defending
		if(isPhysicalAttack && targetDefending)
		{
			damage /= 2;
		}

		// target's back row
		if(isPhysicalAttack && targetIsInBackRow)
		{
			damage /= 2;
		}

		// morph
		if(isMagicalAttack && targetHasMorphStatus)
		{
			damage /= 2;
		}

		// self damage (healing attack skips this step)
		if(targetIsSelf && targetIsCharacter && attackerIsCharacter)
		{
			damage /= 2;
		}

		return damage;
	}

	static num getDamageMultiplierStep7({num damage: 0,
	                                    bool hittingTargetsBack: false,
	                                    bool isPhysicalAttack: true})
	{
		num multiplier = 1;
		if(isPhysicalAttack && hittingTargetsBack)
		{
			multiplier += 1;
		}

		damage += ((damage / 2) * multiplier);
		return damage;
	}

	static num getDamageStep8(num damage, bool targetHasPetrifyStatus)
	{
		if(targetHasPetrifyStatus)
		{
			damage = 0;
		}
		return damage;
	}

	static num getDamageStep9(num damage, {
	bool elementHasBeenNullified: false,
	bool targetAbsorbsElement: false,
	bool targetIsImmuneToElement: false,
	bool targetIsResistantToElement: false,
	bool targetIsWeakToElement: false,
	bool attackCanBeBlockedByStamina: false
	})
	{
		// TODO: re-read article, I can't remember if it was pass through,
		// or immediate returning on each flag.
		if(elementHasBeenNullified)
		{
			return 0;
		}

		if(targetAbsorbsElement)
		{
			return -damage;
		}

		if(targetIsImmuneToElement)
		{
			return 0;
		}

		if(targetIsResistantToElement)
		{
			damage /= 2;
			return damage;
		}

		if(targetIsWeakToElement)
		{
			damage *= 2;
			return damage;
		}

		return damage;
	}

	static HitResult getHit(Attack attack)
	{
		bool isPhysicalAttack = attack.isPhysicalAttack;
		bool isMagicalAttack = attack.isMagicalAttack;
		bool targetHasClearStatus = attack.targetHasClearStatus;
		bool protectedFromWound = attack.protectedFromWound;
		bool attackMissesDeathProtectedTargets = attack.attackMissesDeathProtectedTargets;
		bool spellUnblockable = attack.spellUnblockable;
		bool targetHasSleepStatus = attack.targetHasSleepStatus;
		bool targetHasPetrifyStatus = attack.targetHasPetrifyStatus;
		bool targetHasFreezeStatus = attack.targetHasFreezeStatus;
		bool targetHasStopStatus = attack.targetHasStopStatus;
		bool backOfTarget = attack.backOfTarget;
		num hitRate = attack.hitRate;
		bool targetHasImageStatus = attack.targetHasImageStatus;
		num magicBlock = attack.magicBlock;
		AttackType specialAttackType = attack.specialAttackType;
		num targetStamina = attack.targetStamina;

		if(isPhysicalAttack && targetHasClearStatus)
		{
			return new HitResult(false);
		}

		if(isMagicalAttack && targetHasClearStatus)
		{
			return new HitResult(true);
		}

		if(protectedFromWound && attackMissesDeathProtectedTargets)
		{
			return new HitResult(false);
		}

		if(isMagicalAttack && spellUnblockable)
		{
			return new HitResult(true);
		}

		if(specialAttackType == null)
		{
			if(targetHasSleepStatus || targetHasPetrifyStatus || targetHasFreezeStatus || targetHasStopStatus)
			{
				return new HitResult(true);
			}

			if(isPhysicalAttack && backOfTarget)
			{
				return new HitResult(true);
			}

			if(hitRate == PERFECT_HIT_RATE)
			{
				return new HitResult(true);
			}

			if(isPhysicalAttack && targetHasImageStatus)
			{
				// TODO: 1 in 4 chance of removing Image status
				num result = getRandomNumberFromRange(0, 3);
				if(result == 0)
				{
					// this'll remove Image status
					return new HitResult(false);
				}
				else
				{
					return new HitResult(false);
				}
			}

			num blockValue = (255 - (magicBlock * 2));
			blockValue = blockValue.floor();
			blockValue++;
			blockValue = blockValue.clamp(1, 255);
//			num blockValue = ((255 - magicBlock * 2).floor() + 1).clamp(1, 255);

			if((hitRate * blockValue / 256) > getRandomNumberFromRange(0, 99))
			{
				return new HitResult(true);
			}
			else
			{
				return new HitResult(false);
			}
		}

		num blockValue = ((255 - magicBlock * 2) + 1).floor().clamp(1, 255);

		if( ((hitRate * blockValue) / 256) > getRandomNumberFromRange(0, 99))
		{
			if(targetStamina >= getRandomNumberFromRange(0, 127))
			{
				return new HitResult(false);
			}
			else
			{
				return new HitResult(true);
			}
		}
		else
		{
			return new HitResult(false);
		}
	}
}