part of sprites;

abstract class SpriteSheet extends DisplayObjectContainer
{
	double _currentTime = 0.0;
	ResourceManager resourceManager;
	Bitmap _bitmap;
	bool _redrawn = false;

	double frameTime = 0.3;
	Map<String, List<String>> cycles = new Map<String, List<String>>();

	TextureAtlas _textureAtlas;
	int _count = 0;
	List<String> _currentCycle;
	List<String> get currentCycle => _currentCycle;
	void set currentCycle(List<String> newCycle)
	{
//		print("newCycle: $newCycle");
		if(_currentCycle != newCycle)
		{
			_currentCycle = newCycle;
			_currentTime = 0.0;
			_count = 0;
			_redrawn = false;
		}
	}

//	SpriteSheet(ResourceManager resourceManager)
//	{
//		this.resourceManager = resourceManager;
//
//		 _bitmap = new Bitmap();
//         addChild(_bitmap);
//	}

	SpriteSheet()
	{
		_bitmap = new Bitmap();
		addChild(_bitmap);
	}

	void init(){}

	void render(RenderState renderState)
	{
		super.render(renderState);

		if(currentCycle == null)
		{
			return;
		}

		if(currentCycle.length < 1)
		{
			return;
		}

		if(currentCycle.length == 1 && _redrawn == false)
		{
			_redrawn = true;
			BitmapData bitmapData = _textureAtlas.getBitmapData(currentCycle[_count]);
			_bitmap.bitmapData = bitmapData;
			return;
		}

		_currentTime += renderState.deltaTime;
		if(_currentTime < frameTime)
		{
			return;
		}
		else
		{
			_currentTime = 0.0;
		}

		if(_count < currentCycle.length - 1)
		{
			_count++;
		}
		else
		{
			_count = 0;
		}

		BitmapData bitmapData = _textureAtlas.getBitmapData(currentCycle[_count]);
		_bitmap.bitmapData = bitmapData;
	}
}