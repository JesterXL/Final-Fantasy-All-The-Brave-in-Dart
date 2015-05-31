part of sprites;

class ThiefSprite extends SpriteSheet
{

	ThiefSprite(ResourceManager resourceManager)
	{
		this.resourceManager = resourceManager;
		if (resourceManager.containsTextureAtlas('thief') == false)
		{
			resourceManager.addTextureAtlas('thief', 'images/thief/thief.json', TextureAtlasFormat.JSONARRAY);
		}

		getAnimationList("idle")
			..add("thief_1");

		getAnimationList("ready")
			..add("thief_2");

		getAnimationList("cheer")
			..add("thief_1")
			..add("thief_3");

		getAnimationList("hit")
			..add("thief_4");

		getAnimationList("attack")
			..add("thief_5");

		getAnimationList("hurt")
			..add("thief_6");
	}

	List<String> getAnimationList(String name)
	{
		List<String> list = new List<String>();
		cycles[name] = list;
		return list;
	}

	void init()
	{
		_textureAtlas = resourceManager.getTextureAtlas('thief');
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

	void hurt()
	{
		currentCycle = cycles["hurt"];
	}
}