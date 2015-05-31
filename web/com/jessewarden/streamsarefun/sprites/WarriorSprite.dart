part of sprites;

class WarriorSprite extends SpriteSheet
{

	WarriorSprite(ResourceManager resourceManager)
	{
		this.resourceManager = resourceManager;
		if (resourceManager.containsTextureAtlas('warrior') == false)
		{
			resourceManager.addTextureAtlas('warrior', 'images/warrior.json', TextureAtlasFormat.JSONARRAY);
		}

		getAnimationList("idle")
			..add("warrior_1");

		getAnimationList("ready")
			..add("warrior_2");

		getAnimationList("cheer")
			..add("warrior_1")
			..add("warrior_3");

		getAnimationList("hit")
			..add("warrior_4");

		getAnimationList("attack")
			..add("warrior_5");

		getAnimationList("hurt")
			..add("warrior_6");
	}

	List<String> getAnimationList(String name)
	{
		List<String> list = new List<String>();
		cycles[name] = list;
		return list;
	}

	Future init()
	{
		return new Future(()
		{
			print("resourceManager loading warrior's stuff...");
			return resourceManager.load()
			.then((_)
			{
				_textureAtlas = resourceManager.getTextureAtlas('warrior');
				idle();
			})
			.catchError((e)
			=> print("WarriorSprite init error: $e"));
		});
	}

	void idle()
	{
		currentCycle = cycles["idle"];
	}

	void ready()
	{
		currentCycle = cycles["ready"];
	}

	void cheer()
	{
		frameTime = 0.2;
		currentCycle = cycles["cheer"];
	}

	void hit()
	{
		currentCycle = cycles["hit"];
	}

	void attack()
	{
		currentCycle = cycles["attack"];
	}

	void hurt()
	{
		currentCycle = cycles["hurt"];
	}
}