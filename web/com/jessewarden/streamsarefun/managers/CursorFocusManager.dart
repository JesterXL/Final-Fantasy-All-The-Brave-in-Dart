part of managers;

class CursorFocusManager
{
	Stage _stage;
	ResourceManager _resourceManager;
	Bitmap _cursorBitmap;
	StreamController _controller;

	Stream stream;

	CursorFocusManager(Stage this._stage, ResourceManager this._resourceManager)
	{
		init();
	}

	// TODO/FIXME: *Spaceballs voice* Really dude? You're an ex-Flash Developer, come ON mahhhn.....
	void hackToTop()
	{
		_stage.setChildIndex(_cursorBitmap, _stage.numChildren - 1);
	}

	void init()
	{
		_controller = new StreamController.broadcast();
		stream = _controller.stream;

		if(_resourceManager.containsBitmapData('cursor') == false)
		{
			_resourceManager.addBitmapData('cursor', 'images/cursor.png');
		}
		_resourceManager.load()
		.then((_)
		{
			_cursorBitmap = new Bitmap(_resourceManager.getBitmapData('cursor'));
			_stage.addChild(_cursorBitmap);
			_cursorBitmap.visible = false;
		});

		targets.listChanges.listen((List<ListChangeRecord> changes)
		{
			if(targets.length < 1)
			{
				_setCursorVisible(false);
			}
			else
			{
				_setCursorVisible(true);
			}
		});

		_stage.onKeyDown.listen((KeyboardEvent event)
		{
			print(event.keyCode);
			switch(event.keyCode)
			{
				case 87: // w
				case 38: // up arrow
					previousTarget();
					break;

				case 83: // s
				case 40: // down arrow
					nextTarget();
					break;

				case 13: // enter
					_controller.add(new CursorFocusManagerEvent(CursorFocusManagerEvent.SELECTED));
					break;

				case 39: // right
					_controller.add(new CursorFocusManagerEvent(CursorFocusManagerEvent.MOVE_RIGHT));
					break;

				case 37: // left
					_controller.add(new CursorFocusManagerEvent(CursorFocusManagerEvent.MOVE_LEFT));
					break;
			}
		});
	}

	void setTargets(List newTargets)
	{
		targets.clear();
		newTargets.forEach((DisplayObject item)
		{
			targets.add(item);
		});
		selectedIndex = 0;
		hackToTop();
	}

	void clearAllTargets()
	{
		targets.clear();
		_setCursorVisible(false);
	}


	ObservableList<DisplayObject> targets = new ObservableList<DisplayObject>();

	int _selectedIndex = -1;

	int get selectedIndex => _selectedIndex;
	void set selectedIndex(int newValue)
	{
		_selectedIndex = newValue;
		_selectCurrentElement();
	}

	void _setCursorVisible(bool show)
	{
		if(_cursorBitmap != null)
		{
			_cursorBitmap.visible = show;
		}
	}

	void _selectCurrentElement()
	{
		_cursorBitmap.visible = false;

		if(_selectedIndex < 0)
		{
			return;
		}

		if(targets.length < 1)
		{
			return;
		}

		DisplayObject target = targets[_selectedIndex];
		_cursorBitmap.visible = true;
		Point point = target.parent.localToGlobal(new Point(target.x, target.y));
		_cursorBitmap.x = point.x - _cursorBitmap.width - 2;
		_cursorBitmap.y = point.y + target.height / 2;
	}

	void nextTarget()
	{
		if(targets.length < 2)
		{
			return;
		}

		if(_selectedIndex + 1 < targets.length)
		{
			_selectedIndex++;
		}
		else
		{
			_selectedIndex = 0;
		}
		_controller.add(new CursorFocusManagerEvent(CursorFocusManagerEvent.INDEX_CHANGED));
		_selectCurrentElement();
	}

	void previousTarget()
	{
		if(targets.length < 2)
		{
			return;
		}

		if(_selectedIndex - 1 > -1)
		{
			_selectedIndex--;
		}
		else
		{
			_selectedIndex = targets.length - 1;
		}
		_controller.add(new CursorFocusManagerEvent(CursorFocusManagerEvent.INDEX_CHANGED));
		_selectCurrentElement();
	}



}