library charactertests;

import "package:test/test.dart";
import 'battlecore.dart';
import 'dart:async';
import '../enums/enums.dart';

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
	});


}