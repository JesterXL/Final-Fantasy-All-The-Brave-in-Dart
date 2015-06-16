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
//			var str = BattleUtils.getRandomMonsterStrength();
			var str = 56;
			var result = BattleUtils.getMonsterPhysicalDamageStep1(level: 10, battlePower: 9, strength: str);
			expect(result, equals(35.9375));
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