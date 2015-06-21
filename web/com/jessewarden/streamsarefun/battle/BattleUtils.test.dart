library battleutilstests;

import "package:test/test.dart";
import 'battlecore.dart';

void main() {
	group("BattleUtils tests", ()
	{
		test("basic test", ()
		{
			expect(true, true);
		});

		test("basic matcher works", ()
		{
			expect(true, isNotNull);
		});

		test("negate works", ()
		{
			Function cowTrue = () => false;
			expect(cowTrue(), isFalse);
			bool cowFalse()
			{
				return !cowTrue();
			}
			expect(cowFalse(), isTrue);
		});

		test("divide", ()
		{
			expect(BattleUtils.divide(2, 1), equals(2));
		});

		test("divide big", ()
		{
			expect(BattleUtils.divide(20, 2), equals(10));
		});

		test("range 0 to 1 works", ()
		{
			expect(withinRange(BattleUtils.getRandomNumberFromRange(0, 1), 0, 1), isTrue);
		});

		test("range 1 to 3 works", ()
		{
			expect(withinRange(BattleUtils.getRandomNumberFromRange(1, 3), 1, 3), isTrue);
		});

		group("getDamageStep1", ()
		{
			test("with defaults low", ()
			{
				var result = BattleUtils.getDamageStep1(vigor: 37,
				battlePower: 40,
				level: 7);
				expect(result, equals(72.73046875));
			});

			test("getRandomMonsterVigor has range that works", ()
			{
				expect(withinRange(BattleUtils.getRandomMonsterVigor(), 56, 63), isTrue);
			});

			test("monster results for Leafer", ()
			{
				var result = BattleUtils.getDamageStep1(level: 10, battlePower: 9, vigor: 56, isPlayerAndNotMonster: false);
				expect(result, equals(35.9375));
			});
		});

		group("getDamageStep2", ()
		{
			test("defaults", ()
			{
				var result = BattleUtils.getDamageStep2();
				expect(result, equals(0));
			});

			test("with 1", ()
			{
				var result = BattleUtils.getDamageStep2(damage: 1);
				expect(result, equals(1));
			});

			test("with Atlas Armlet", ()
			{
				var result = BattleUtils.getDamageStep2(damage: 1, equippedWithAtlasArmlet: true);
				expect(result, equals(1.25));
			});
		});

		group("getDamageStep3", ()
		{

			test("getDamageStep3 0", ()
			{
				var result = BattleUtils.getDamageStep3(damage: 0);
				expect(result, equals(0));
			});

			test("getDamageStep3 1", ()
			{
				var result = BattleUtils.getDamageStep3(damage: 1, isMagicalAttack: true, attackingMultipleTargets: true);
				expect(result, equals(0.5));
			});

			test("getDamageStep3 100", ()
			{
				var result = BattleUtils.getDamageStep3(damage: 100, isMagicalAttack: true, attackingMultipleTargets: true);
				expect(result, equals(50));
			});
		});

		group("getDamageStep4", ()
		{
			test("0", ()
			{
				var result = BattleUtils.getDamageStep4(damage: 0);
				expect(result, equals(0));
			});

			test("1", ()
			{
				var result = BattleUtils.getDamageStep4(damage: 1, attackerIsInBackRow: true);
				expect(result, equals(0.5));
			});

			test("100", ()
			{
				var result = BattleUtils.getDamageStep4(damage: 100, attackerIsInBackRow: true);
				expect(result, equals(50));
			});
		});

		group("getDamageStep5", ()
		{
			test("100", ()
			{
				var result = BattleUtils.getDamageStep5(
					damage: 100,
					hasMorphStatus: false,
					hasBerserkStatusAndPhysicalAttack: false,
					isCriticalHit: false
				);
				expect(result, equals(100));
			});

			test("200 from 100 if critical hit", ()
			{
				var result = BattleUtils.getDamageStep5(
					damage: 100,
					hasMorphStatus: false,
					hasBerserkStatusAndPhysicalAttack: false,
					isCriticalHit: true
				);
				expect(result, equals(200));
			});
		});

		group("getDamageStep6", ()
		{
			test("defaults", ()
			{
				expect(BattleUtils.getDamageStep6(damage: 72), equals(64.75));
			});

			test("defense of 1", ()
			{
				expect(BattleUtils.getDamageStep6(damage: 72, defense: 1), equals(64.5));
			});

			test("physical safe", ()
			{
				expect(BattleUtils.getDamageStep6(damage: 72, targetHasSafeStatus: true), equals(43.998046875));
			});

			test("magic", ()
			{
				expect(BattleUtils.getDamageStep6(damage: 72, isPhysicalAttack: false, isMagicalAttack: true), equals(64.75));
			});

			test("magic shell", ()
			{
				expect(BattleUtils.getDamageStep6(damage: 72,
				isPhysicalAttack: false,
				isMagicalAttack: true,
				targetHasShellStatus: true), equals(43.998046875));
			});

			// TODO: mooaaar tests
		});

		group("getDamageStep7", ()
		{
			test("defaults", ()
			{
				expect(BattleUtils.getDamageStep7(damage: 72), equals(72));
			});

			test("back attack adds damage", ()
			{
				expect(BattleUtils.getDamageStep7(damage: 72, hittingTargetsBack: true), equals(108));
			});
		});

		group("getDamageStep8", ()
		{
			test("defaults", ()
			{
				expect(BattleUtils.getDamageStep8(damage: 72), equals(72));
			});

			test("stoned results in 0 damage", ()
			{
				expect(BattleUtils.getDamageStep8(damage: 72, targetHasPetrifyStatus: true), equals(0));
			});
		});

		group("getDamageStep9", ()
		{
			test("defaults", ()
			{
				expect(BattleUtils.getDamageStep9(damage: 72), equals(72));
			});

			test("force field", ()
			{
				expect(BattleUtils.getDamageStep9(damage: 72, elementHasBeenNullified: true), equals(0));
			});

			test("immune to element heals", ()
			{
				expect(BattleUtils.getDamageStep9(damage: 72, targetAbsorbsElement: true), equals(-72));
			});
		});

		group("getHit", ()
		{
			test("defaults", ()
			{
				HitResult result = BattleUtils.getHit(
					randomHitOrMissValue: 99,
					randomStaminaHitOrMissValue: 127,
					randomImageStatusRemovalValue: 3);
				expect(hitResultIstrue(result), isTrue);
				expect(hitResultImageStatusWasNotRemoved(result), isTrue);
			});

			test("remove image status", ()
			{
				HitResult result = BattleUtils.getHit(
					randomHitOrMissValue: 99,
					randomStaminaHitOrMissValue: 127,
					targetHasImageStatus: true,
					randomImageStatusRemovalValue: 0);
				expect(hitResultIstrue(result), isFalse);
				expect(hitResultImageStatusWasRemoved(result), isTrue);
			});
		});

	});
}

bool withinRange(num value, num start, num end)
{
	return value >= start && value <= end;
}

bool hitResultIstrue(HitResult result)
{
	return result.hit;
}

bool hitResultImageStatusWasNotRemoved(HitResult result)
{
	return result.removeImageStatus == false;
}

bool hitResultImageStatusWasRemoved(HitResult result)
{
	return result.removeImageStatus == true;
}

//
//const Matcher withinRange = const _withinRange();
//class _withinRange extends Matcher
//{
//	const _withinRange();
//	bool matches(num value, num start, num end)
//	{
//		print("value: $value");
//		print("start: $start");
//		print("end: $end");
//		return value >= start && value <= end;
//	}
//	Description describe(Description description) => description.add('not within range');
//}