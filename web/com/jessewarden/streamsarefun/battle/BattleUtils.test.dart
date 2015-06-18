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

		test("getCharacterPhysicalDamageStep1 with defaults low", ()
		{
			var result = BattleUtils.getCharacterPhysicalDamageStep1(strength: 37,
																	battlePower: 40,
																	level: 7);
			expect(result, equals(73));
		});

		test("getRandomMonsterStrength has range that works", ()
		{
			expect(withinRange(BattleUtils.getRandomMonsterStrength(), 56, 63), isTrue);
		});

		test("getMonsterPhysicalDamageStep1", ()
		{
			// basic Leafer stats
//			var str = BattleUtils.getRandomMonsterStrength();
			var str = 56;
			var result = BattleUtils.getMonsterPhysicalDamageStep1(level: 10, battlePower: 9, strength: str);
			expect(result, equals(35.9375));
		});

		test("getCharacterDamageStep2 defaults", ()
		{
			var result = BattleUtils.getCharacterDamageStep2();
			expect(result, equals(0));
		});

		test("getCharacterDamageStep2 with 1", ()
		{
			var result = BattleUtils.getCharacterDamageStep2(damage: 1);
			expect(result, equals(1));
		});

		test("getCharacterDamageStep2 with Atlas Armlet", ()
		{
			var result = BattleUtils.getCharacterDamageStep2(damage: 1, equippedWithAtlasArmlet: true);
			expect(result, equals(1.25));
		});

		test("getMagicalMultipleTargetsAttack 0", ()
		{
			var result = BattleUtils.getMagicalMultipleTargetsAttack(0);
			expect(result, equals(0));
		});

		test("getMagicalMultipleTargetsAttack 1", ()
		{
			var result = BattleUtils.getMagicalMultipleTargetsAttack(1);
			expect(result, equals(0.5));
		});

		test("getMagicalMultipleTargetsAttack 100", ()
		{
			var result = BattleUtils.getMagicalMultipleTargetsAttack(100);
			expect(result, equals(50));
		});

		test("getAttackerBackRowFightCommand 0", ()
		{
			var result = BattleUtils.getAttackerBackRowFightCommand(0);
			expect(result, equals(0));
		});

		test("getAttackerBackRowFightCommand 1", ()
		{
			var result = BattleUtils.getAttackerBackRowFightCommand(1);
			expect(result, equals(0.5));
		});

		test("getAttackerBackRowFightCommand 100", ()
		{
			var result = BattleUtils.getAttackerBackRowFightCommand(100);
			expect(result, equals(50));
		});

		group("getDamageMultipliers", ()
		{
			test("defaults", ()
			{
				expect(BattleUtils.getDamageMultipliers(damage: 72), equals(108));
			});

			test("hasMorphStatus", ()
			{
				expect(BattleUtils.getDamageMultipliers(damage: 72, hasMorphStatus: true), equals(180));
			});

			test("hasBerserkStatusAndPhysicalAttack", ()
			{
				expect(BattleUtils.getDamageMultipliers(damage: 72, hasBerserkStatusAndPhysicalAttack: true), equals(144));
			});

			test("isCriticalHit", ()
			{
				expect(BattleUtils.getDamageMultipliers(damage: 72, isCriticalHit: true), equals(180));
			});

			test("all", ()
			{
				expect(BattleUtils.getDamageMultipliers(damage: 72,
														hasMorphStatus: true,
														hasBerserkStatusAndPhysicalAttack: true,
														isCriticalHit: true),
				equals(288));
			});
		});

		group("getDamageModifications", ()
		{
			test("defaults", ()
			{
				expect(BattleUtils.getDamageModifications(damage: 72), equals(136));
			});

			test("physical safe", ()
			{
				expect(BattleUtils.getDamageModifications(damage: 72, targetHasSafeStatus: true), equals(91.3125));
			});

			test("magic", ()
			{
				expect(BattleUtils.getDamageModifications(damage: 72, isPhysicalAttack: false, isMagicalAttack: true), equals(136));
			});

			test("magic shell", ()
			{
				expect(BattleUtils.getDamageModifications(damage: 72,
				isPhysicalAttack: false,
				isMagicalAttack: true,
				targetHasShellStatus: true), equals(91.3125));
			});

			// TODO: mooaaar tests
		});

		group("getDamageMultiplierStep7", ()
		{
			test("defaults", ()
			{
				expect(BattleUtils.getDamageMultiplierStep7(damage: 72), equals(108));
			});

			test("back attack adds damage", ()
			{
				expect(BattleUtils.getDamageMultiplierStep7(damage: 72, hittingTargetsBack: true), equals(144));
			});
		});

	});
}

bool withinRange(num value, num start, num end)
{
	return value >= start && value <= end;
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