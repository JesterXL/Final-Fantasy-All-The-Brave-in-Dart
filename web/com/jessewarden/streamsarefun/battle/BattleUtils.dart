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

	static num getDamageStep1({
	                                           num vigor: 1,
	                                           num battlePower: 1,
												num spellPower: 1,
												num magicPower: 1,
	                                           int level: 1,
	                                           bool equippedWithGauntlet: false,
	                                           bool equippedWithOffering: false,
	                                           bool standardFightAttack: true,
												bool isPhysicalAttack: true,
												bool isMagicalAttack: false,
												bool isPlayerAndNotMonster: true,
	                                           bool genjiGloveEquipped: false,
	                                           bool oneOrZeroWeapons: true
	                                           })
	{

		num damage;

		if(isPhysicalAttack == false && isMagicalAttack == true && isPlayerAndNotMonster == true)
		{
			damage = spellPower * 4 + (level * magicPower * spellPower / 32);
		}
		else if(isPhysicalAttack == false && isMagicalAttack == true && isPlayerAndNotMonster == false)
		{
			damage = spellPower * 4 + (level * (magicPower * 3/2) * spellPower / 32);
		}
		else if(isPhysicalAttack == true && isPlayerAndNotMonster == true)
		{
			num vigor2 = vigor * 2;
			if (vigor >= 128)
			{
				vigor2 = 255;
			}

			num attack = battlePower + vigor2;

			if (equippedWithGauntlet)
			{
				attack += (battlePower * 3 / 4);
			}

			damage = battlePower + ( (level * level * attack) / 256) * 3 / 2;

			if (equippedWithOffering)
			{
				damage /= 2;
			}

			if (standardFightAttack && genjiGloveEquipped && oneOrZeroWeapons)
			{
				damage = (damage * 3/4).ceil();
			}
		}
		else if(isPhysicalAttack == true && isPlayerAndNotMonster == false)
		{
			damage = level * level * (battlePower * 4 + vigor) / 256;
		}

		return damage;
	}

	static int getRandomMonsterVigor()
	{
		return getRandomNumberFromRange(56, 63);
	}

	static num getDamageStep2({num damage: 0,
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

	static num getDamageStep3({
		num damage: 0,
		bool isMagicalAttack: false,
		bool attackingMultipleTargets: false})
	{
		if(isMagicalAttack == true && attackingMultipleTargets == true)
		{
			return damage / 2;
		}
		else
		{
			return damage;
		}
	}

	// TODO: figure out 'if fight command'
	static num getDamageStep4({num damage: 0, attackerIsInBackRow: false})
	{
		if(attackerIsInBackRow == true)
		{
			return damage / 2;
		}
		else
		{
			return damage;
		}
	}

	static bool getCriticalHit()
	{
		Random digit = new Random();
		return digit.nextInt(31) == 31;
	}

	static num getDamageStep5({num damage: 0,
	                                bool hasMorphStatus: false,
	                                bool hasBerserkStatusAndPhysicalAttack: false,
	                                bool isCriticalHit: false})
	{
		num multiplier = 0;

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

	static num getDamageStep6({num damage: 0,
	                                  num defense: 0,
	                                  num magicalDefense: 0,
									  num variance: 224,
	                                  bool isPhysicalAttack: true,
	                                  bool isMagicalAttack: false,
										bool isHealingAttack: false,
	                                  bool targetHasSafeStatus: false,
	                                  bool targetHasShellStatus: false,
	                                  bool targetDefending: false,
	                                  bool targetIsInBackRow: false,
	                                  bool targetHasMorphStatus: false,
	                                  bool targetIsSelf: false,
	                                  bool targetIsCharacter: false,
	                                  bool attackerIsCharacter: true})
	{

		damage = (damage * variance / 256) + 1;

		// defense modification
		if(isPhysicalAttack)
		{
			damage = (damage * (255 - defense) / 256) + 1;
		}
		else
		{
			damage = (damage * (255 - magicalDefense) / 256) + 1;
		}

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
		if(isHealingAttack == false)
		{
			if (targetIsSelf && targetIsCharacter && attackerIsCharacter)
			{
				damage /= 2;
			}
		}

		return damage;
	}

	static num getDamageStep7({num damage: 0,
	                                    bool hittingTargetsBack: false,
	                                    bool isPhysicalAttack: true})
	{
		num multiplier = 0;
		if(isPhysicalAttack && hittingTargetsBack)
		{
			multiplier += 1;
		}

		damage += ((damage / 2) * multiplier);
		return damage;
	}

	static num getDamageStep8({num damage: 0, bool targetHasPetrifyStatus: false})
	{
		if(targetHasPetrifyStatus)
		{
			damage = 0;
		}
		return damage;
	}

	static num getDamageStep9({
	                                   num damage: 0,
										bool elementHasBeenNullified: false,
										bool targetAbsorbsElement: false,
										bool targetIsImmuneToElement: false,
										bool targetIsResistantToElement: false,
										bool targetIsWeakToElement: false
	})
	{
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

	static int getRandomHitOrMissValue()
	{
		return getRandomNumberFromRange(0, 99);
	}

	static int getRandomStaminaHitOrMissValue()
	{
		return getRandomNumberFromRange(0, 127);
	}

	static int getRandomImageStatusRemoval()
	{
		return getRandomNumberFromRange(0, 3);
	}

	static HitResult getHit({int randomHitOrMissValue: 0,
		int randomStaminaHitOrMissValue: 0,
		int randomImageStatusRemovalValue: 0,
		bool isPhysicalAttack: true,
		bool isMagicalAttack: false,
		bool targetHasClearStatus: false,
		bool protectedFromWound: false,
		bool attackMissesDeathProtectedTargets: false,
		bool attackCanBeBlockedByStamina: true,
		bool spellUnblockable: false,
		bool targetHasSleepStatus: false,
		bool targetHasPetrifyStatus: false,
		bool targetHasFreezeStatus: false,
		bool targetHasStopStatus: false,
		bool backOfTarget: false,
		bool targetHasImageStatus: false,
		int hitRate: 180,  // TODO: need weapon's info, this is where hitRate comes from
		int magicBlock: 0,
		int targetStamina: null,
		AttackType specialAttackType: null})
	{
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
				num result = randomImageStatusRemovalValue;
				if(result == 0)
				{
					// this'll remove Image status
					return new HitResult(false, removeImageStatus: true);
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

			if((hitRate * blockValue / 256) > randomHitOrMissValue)
			{
				return new HitResult(true);
			}
			else
			{
				return new HitResult(false);
			}
		}

		num blockValue = ((255 - magicBlock * 2) + 1).floor().clamp(1, 255);

		if( ((hitRate * blockValue) / 256) > randomHitOrMissValue)
		{
			if(targetStamina >= randomStaminaHitOrMissValue)
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

	static bool isStandardFightAttack(bool isPhysicalAttack, bool isMagicalAttack)
	{
		return isPhysicalAttack == true && isMagicalAttack == false;
	}

	static HitResult getHitAndApplyDamage(Character attacker,
	                              {bool isPhysicalAttack: true,
	                              bool isMagicalAttack: false,
	                              bool targetHasClearStatus: false,
	                              bool protectedFromWound: false,
	                              bool attackMissesDeathProtectedTargets: false,
	                              bool attackCanBeBlockedByStamina: true,
	                              bool spellUnblockable: false,
	                              bool targetHasSleepStatus: false,
	                              bool targetHasPetrifyStatus: false,
	                              bool targetHasFreezeStatus: false,
	                              bool targetHasStopStatus: false,
	                              bool targetHasSafeStatus: false,
	                              bool targetHasShellStatus: false,
	                              bool targetDefending: false,
	                              bool targetIsInBackRow: false,
	                              bool targetHasMorphStatus: false,
	                              bool targetIsSelf: false,
	                              bool targetIsCharacter: false,
	                              bool backOfTarget: false,
	                              bool targetHasImageStatus: false,
	                              int hitRate: 180,  // TODO: need weapon's info, this is where hitRate comes from
	                              int magicBlock: 0,
	                              int targetStamina: null,
	                              AttackType specialAttackType: null,
	                              bool attackerIsCharacter: true,
	                              bool attackingMultipleTargets: false,
	                              bool attackerIsInBackRow: false,
	                              bool attackerHasMorphStatus: false,
	                              bool attackerHasBerserkStatusAndPhysicalAttack: false,
	                              bool elementHasBeenNullified: false,
	                              bool targetAbsorbsElement: false,
	                              bool targetIsImmuneToElement: false,
	                              bool targetIsResistantToElement: false,
	                              bool targetIsWeakToElement: false})
	{
		HitResult hitResult = BattleUtils.getHit(
			randomHitOrMissValue: getRandomHitOrMissValue(),
			randomStaminaHitOrMissValue: getRandomStaminaHitOrMissValue(),
			randomImageStatusRemovalValue: getRandomImageStatusRemoval(),
			isPhysicalAttack: isPhysicalAttack,
			isMagicalAttack: isMagicalAttack,
			targetHasClearStatus: targetHasClearStatus,
			protectedFromWound: protectedFromWound,
			attackMissesDeathProtectedTargets: attackMissesDeathProtectedTargets,
			attackCanBeBlockedByStamina: attackCanBeBlockedByStamina,
			spellUnblockable: spellUnblockable,
			targetHasSleepStatus: targetHasSleepStatus,
			targetHasPetrifyStatus: targetHasPetrifyStatus,
			targetHasFreezeStatus: targetHasFreezeStatus,
			targetHasStopStatus: targetHasStopStatus,
			backOfTarget: backOfTarget,
			targetHasImageStatus: targetHasImageStatus,
			hitRate: hitRate,
			magicBlock: magicBlock,
			targetStamina: targetStamina,
			specialAttackType: specialAttackType
		);
		int damage = 0;
		bool criticalHit = getCriticalHit();
		int damageModificationVariance = getDamageModificationsVariance();
		bool standardFightAttack = isStandardFightAttack(isPhysicalAttack, isMagicalAttack);
		if(hitResult.hit)
		{
			damage = BattleUtils.getDamageStep1(
				vigor: attacker.vigor,
				battlePower: attacker.battlePower,
				level: attacker.level,
				equippedWithGauntlet: attacker.equippedWithGauntlet(),
				equippedWithOffering: attacker.equippedWithOffering(),
				standardFightAttack: standardFightAttack,
				genjiGloveEquipped: attacker.genjiGloveEquipped(),
				oneOrZeroWeapons: attacker.oneOrZeroWeapons()
			);

			damage = BattleUtils.getDamageStep2(
				damage: damage,
				isPhysicalAttack: isPhysicalAttack,
				isMagicalAttack: isMagicalAttack,
				equippedWithAtlasArmlet: attacker.equippedWithAtlasArmlet(),
				equippedWith1HeroRing: attacker.equippedWith1HeroRing(),
				equippedWith2HeroRings: attacker.equippedWith2HeroRings(),
				equippedWith1Earring: attacker.equippedWith1Earring(),
				equippedWith2Earrings: attacker.equippedWith2Earrings()
			);

			damage = BattleUtils.getDamageStep3(
				damage: damage,
				isMagicalAttack: isMagicalAttack,
				attackingMultipleTargets: attackingMultipleTargets);

			damage = BattleUtils.getDamageStep4(
				damage: damage,
				attackerIsInBackRow: attackerIsInBackRow
			);

			damage = BattleUtils.getDamageStep5(
				damage: damage,
				hasMorphStatus: attackerHasMorphStatus,
				hasBerserkStatusAndPhysicalAttack: attackerHasBerserkStatusAndPhysicalAttack,
				isCriticalHit: criticalHit
			);

			damage = BattleUtils.getDamageStep6(
				damage: damage,
				defense: attacker.defense,
				magicalDefense: attacker.magicDefense,
				variance: damageModificationVariance,
				isPhysicalAttack: isPhysicalAttack,
				isMagicalAttack: isMagicalAttack,
				targetHasSafeStatus: targetHasSafeStatus,
				targetHasShellStatus: targetHasShellStatus,
				targetDefending: targetDefending,
				targetIsInBackRow: targetIsInBackRow,
				targetHasMorphStatus: targetHasMorphStatus,
				targetIsSelf: targetIsSelf,
				targetIsCharacter: targetIsCharacter,
				attackerIsCharacter: attackerIsCharacter
			);

			damage = BattleUtils.getDamageStep7(
				damage: damage,
				hittingTargetsBack: backOfTarget,
				isPhysicalAttack: isPhysicalAttack
			);

			damage = BattleUtils.getDamageStep8(
				damage: damage,
				targetHasPetrifyStatus: targetHasPetrifyStatus
			);

			damage = BattleUtils.getDamageStep9(
				damage: damage,
				elementHasBeenNullified: elementHasBeenNullified,
				targetAbsorbsElement: targetAbsorbsElement,
				targetIsImmuneToElement: targetIsImmuneToElement,
				targetIsResistantToElement: targetIsResistantToElement,
				targetIsWeakToElement: targetIsWeakToElement
			);
		}

		damage = damage.clamp(-9999, 9999);
		damage = damage.round();

		// TODO: support attacking mulitple targets
		return new TargetHitResult(
			criticalHit: criticalHit,
			hit: hitResult.hit,
			damage: damage,
			removeImageStatus: hitResult.removeImageStatus
		);

//		targetHitResults.add(
//			new TargetHitResult(
//				criticalHit: criticalHit,
//				hit: hitResult.hit,
//				damage: damage,
//				removeImageStatus: hitResult.removeImageStatus,
//				target: target
//			)
//		);
	}
}