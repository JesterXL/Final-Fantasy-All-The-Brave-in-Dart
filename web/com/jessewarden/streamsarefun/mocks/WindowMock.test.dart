library windowmocktests;

import "package:test/test.dart";
import "mocks.dart";

void main() {
	group("WindowMock Tests", ()
	{
		test("basic test", ()
		{
			expect(true, true);
		});

		test("basic matcher works", ()
		{
			expect(true, isNotNull);
		});

		test("create works", ()
		{
			WindowMock mock = new WindowMock();
			expect(mock, isNotNull);
		});

		test("animationFrame completes", ()
		async
		{
			WindowMock mock = new WindowMock();
			mock.start();
			await mock.animationFrame.then((num time)
			{
				expect(time, isNotNull);
			});
			print("done");
		});
	});
}
