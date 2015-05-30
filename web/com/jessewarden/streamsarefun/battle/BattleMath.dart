part of battlecore;

class BattleMath
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

	static int getCharacterPhysicalDamageStep1(num strength,
	                                           num battlePower,
	                                           int level,
	                                           bool equippedWithGauntlet,
	                                           bool equippedWithOffering,
	                                           bool standardFightAttack,
	                                           bool genjiGloveEquipped,
	                                           bool oneOrZeroWeapons
	                                           )
	{
		num strength2 = strength * 2;
		if(strength >= 128)
		{
			strength2 = 255;
		}

		num attack = battlePower + strength2;

		if(equippedWithGauntlet)
		{
			attack += battlePower * 3/4;
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

		return damage;
	}

	static int getRandomMonsterStrength()
	{
		return getRandomNumberFromRange(56, 63);
	}

	static num getMonsterPhysicalDamageStep1(int level, num battlePower, int strength)
	{
		return level * level * (battlePower * 4 + strength) / 256;
	}

	static num getCharacterDamageStep2(num damage,
	                                   bool isMagicalAttacker,
	                                   bool isPhysicalAttack,
	                                   bool isMagicalAttack,
	                                   bool equippedWithAtlasArmlet,
	                                   bool equippedWith1HeroRing,
	                                   bool equippedWith2HeroRings,
	                                   bool equippedWith1Earring,
	                                   bool equippedWith2Earrings
	                                   )
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
		int digit = new Random().nextInt(31);
		return digit == 31;
	}

	static num getDamageMultipliers(num damage,
	                                bool hasMorphStatus,
	                                bool hasBerserkStatus,
	                                bool isCriticalHit)
	{
		num multiplier = 1;

		if(hasMorphStatus)
		{
			multiplier += 2;
		}

		if(hasBerserkStatus)
		{
			multiplier += 1;
		}

		if(isCriticalHit)
		{
			multiplier += 2;
		}

		damage += ((damage / 2) * damage * multiplier);
		return damage;
	}

	static num getDamageModifications(num damage,
	                                  num defense,
	                                  num magicalDefense,
	                                  bool isPhysicalAttack,
	                                  bool isMagicalAttack,
	                                  bool targetHasSafeStatus,
	                                  bool targetHasShellStatus,
	                                  bool targetDefending,
	                                  bool targetIsInBackRow,
	                                  bool targetHasMorphStatus,
	                                  bool targetIsSelf,
	                                  bool targetIsCharacter,
	                                  bool attackerIsCharacter)
	{
		num variance = getRandomNumberFromRange(224, 255);

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

	static num getDamageMultiplierStep7(num damage,
	                                    bool hittingTargetsBack,
	                                    bool isPhysicalAttack)
	{
		num multiplier = 1;
		if(isPhysicalAttack && hittingTargetsBack)
		{
			multiplier++;
		}

		damage += ((damage / 2) * damage * multiplier);
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
		String specialAttackType = attack.specialAttackType;
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

		bool match = false;
		if(specialAttackType != null)
		{
			match = AttackTypes.ALL_THE_TYPES.any((item) => specialAttackType == item);
		}

		if(match == false)
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

			num blockValue = ((255 - magicBlock * 2).floor() + 1).clamp(1, 255);

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