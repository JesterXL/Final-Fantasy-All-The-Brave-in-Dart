library intentqueuetest;

import '../battlecore.dart';
import "../../../../../../packages/test/test.dart";
import "../../../../../../packages/stagexl/stagexl.dart";

void main() {
	group("IntentQueue Tests", ()
	{
		test("has default stream", () async
		{
			var juggler = new Juggler();
			var queue = new IntentQueue(juggler);
			await queue.stream.listen((_)
			{
				print("event: $_");
			});
		});

	});
}
