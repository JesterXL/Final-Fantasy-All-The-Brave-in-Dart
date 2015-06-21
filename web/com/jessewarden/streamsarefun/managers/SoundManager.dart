part of managers;

class SoundManager
{
	SoundTransform soundTransform = new SoundTransform(1);

	ResourceManager _resourceManager;
	Map<String, Sound> _soundHash = new Map<String, Sound>();

	SoundManager(ResourceManager this._resourceManager)
	{
	}

	Future play(String name, {bool loop: false})
	{
		Sound sound;
		if(_soundHash.containsKey(name))
		{
			sound = _soundHash[name];
		}
		else
		{
			sound = _resourceManager.getSound(name);
			_soundHash[name] = sound;
		}
		sound.play(loop, soundTransform);
		num milliseconds = sound.length * 1000;
		return new Future.delayed(new Duration(milliseconds: milliseconds.ceil()), ()
		{
			return true;
		});
	}
}