part of sprites;

class BlackMageSprite extends SpriteSheet
{

	BlackMageSprite(ResourceManager resourceManager)
	{
		this.resourceManager = resourceManager;
		if (resourceManager.containsTextureAtlas('blackmage') == false)
		{
			resourceManager.addTextureAtlas('blackmage', 'images/blackmage/blackmage.json', TextureAtlasFormat.JSONARRAY);
		}

		getAnimationList("idle")
			..add("blackmage_1");

		getAnimationList("ready")
			..add("blackmage_1");

		getAnimationList("cheer")
			..add("blackmage_1")
			..add("blackmage_3");

		getAnimationList("hit")
			..add("blackmage_4");

		getAnimationList("attack")
			..add("blackmage_5");
	}

	List<String> getAnimationList(String name)
	{
		List<String> list = new List<String>();
		cycles[name] = list;
		return list;
	}

	void init()
	{
		_textureAtlas = resourceManager.getTextureAtlas('blackmage');
		idle();
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
}