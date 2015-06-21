library charactertests;

import "package:test/test.dart";
import 'battlecore.dart';
import 'dart:async';
import '../enums/enums.dart';
import '../relics/relics.dart';

void main()
{

	group("Character tests", ()
	{
		Character character;

		group("row", ()
		{
			setUp(()
			{
				character = new Character();
			});

			tearDown(()
			{
				character = null;
			});

			test("row setter works", ()
			{
				character.stream.listen((CharacterEvent event)
				{
					expect(event.newRow, equals(Row.BACK));
				});
				character.row = Row.BACK;
			});

			test("row toggle works", ()
			{
				character.stream.listen((CharacterEvent event)
				{
					expect(event.newRow, equals(Row.BACK));
				});
				character.toggleRow();
			});

			test("row constructor works", ()
			{
				Character tempChar = new Character(row: Row.BACK);
				tempChar.stream.listen((CharacterEvent event)
				{
					expect(event.newRow, equals(Row.FRONT));
				});
				tempChar.toggleRow();
			});
		});

		group("hitPoints", ()
		{
			setUp(()
			{
				character = new Character(hitPoints: 200);
			});

			tearDown(()
			{
				character = null;
			});

			test("changing changes triggers change event", ()
			{
				character.stream.first.then((CharacterEvent event)
				{
					expect(event.type, equals(CharacterEvent.HIT_POINTS_CHANGED));
				});
				character.hitPoints = 180;
			});

			test("no longer swoon should not be triggered merely by reducing hitpoints", ()
			{
				character.stream.listen((CharacterEvent event)
				{
					expect(event.type, equals(CharacterEvent.HIT_POINTS_CHANGED));
				});
				character.hitPoints = 180;
			});

			test("reducing hitpoints to swoon triggers swoon", ()
			{
				character.stream.firstWhere((CharacterEvent event)
				{
					return event.type == CharacterEvent.SWOON;
				})
				.then((CharacterEvent event)
				{
					expect(event.type, equals(CharacterEvent.SWOON));
				});
				character.hitPoints = 0;
			});

			test("reducing hitpoints to swoon then back triggers no longer swoon", ()
			{
				character.stream.firstWhere((CharacterEvent event)
				{
					return event.type == CharacterEvent.NO_LONGER_SWOON;
				})
				.then((CharacterEvent event)
				{
					expect(event.type, equals(CharacterEvent.NO_LONGER_SWOON));
				});
				character.hitPoints = 0;
				character.hitPoints = 100;
			});
		});

		group('equip relic predicates', ()
		{
			setUp(()
			{
				character = new Character(hitPoints: 200);
			});

			tearDown(()
			{
				character = null;
			});

			test("no default relics", ()
			{
				expect(character.equippedWithNoRelics(), isTrue);
			});

			test("no Gauntlet by default", ()
			{
				expect(character.equippedWithGauntlet(), isFalse);
			});

			test("equipping Gauntlet works", ()
			{
				Gauntlet gauntlet = new Gauntlet();
				character.relic1 = gauntlet;
				expect(character.equippedWithGauntlet(), isTrue);
			});

			test("equipping HeroRing works", ()
			{
				Gauntlet gauntlet = new Gauntlet();
				character.relic1 = gauntlet;
				expect(character.equippedWithGauntlet(), isTrue);
			});

			group("HeroRing predicates", ()
			{
				HeroRing ring1 = new HeroRing();
				HeroRing ring2 = new HeroRing();

				tearDown(()
				{
					character.relic1 = null;
					character.relic2 = null;
				});

				test("HeroRing work", ()
				{
					character.relic1 = ring1;
					expect(character.equippedWithHeroRing(), isTrue);
					expect(character.equippedWith2HeroRings(), isFalse);
				});

				test("2 HeroRings work", ()
				{
					character.relic1 = ring1;
					character.relic2 = ring2;
					expect(character.equippedWith1HeroRing(), isFalse);
					expect(character.equippedWith2HeroRings(), isTrue);
				});

				test("2 HeroRings work", ()
				{
					character.relic1 = ring1;
					expect(character.equippedWith1HeroRing(), isTrue);
					expect(character.equippedWith2HeroRings(), isFalse);
				});
			});
		});
	});


}