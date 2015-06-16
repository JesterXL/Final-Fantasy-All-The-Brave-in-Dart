part of components;

class Menu extends DisplayObjectContainer
{

	num _width;
	num _height;
	ObservableList<MenuItem> _menuItems;
	ObservableList<MenuItem> get menuItems => _menuItems;
	StreamSubscription _streamSubscription;
	void set menuItems(ObservableList<MenuItem> newItems)
	{
		if(_streamSubscription != null)
		{
			_streamSubscription.cancel();
			_streamSubscription = null;
		}
		_menuItems = newItems;
		_streamSubscription = _menuItems.changes.listen((List<ChangeRecord> changes)
		{
			redraw();
		});
	}

	StreamController _controller;

	Shape _border;
	Sprite _items;
	List<TextField> _fieldPool = new List<TextField>();
	List<Sprite> _spritePool = new List<Sprite>();

	List<Sprite> hitAreas;
	Stream stream;

	Menu(num this._width, num this._height, ObservableList<MenuItem> this._menuItems){
		createChildren();
		init();
	}

	void createChildren()
	{
		_border = new Shape();
		_border.graphics.rectRound(0, 0, _width, _height, 6, 6);
		_border.graphics.fillColor(Color.Blue);
		_border.graphics.strokeColor(Color.White, 4);
		addChild(_border);

		_items = new Sprite();
		addChild(_items);

		redraw();
	}

	void init()
	{
		onMouseClick.where((MouseEvent event)
		{
			return event.target is Sprite;
		})
		.listen((MouseEvent event)
		{
			Object data = event.target.userData;
			_controller.add(data["data"]);
		});

		_controller = new StreamController();
		stream = _controller.stream;
	}


	TextField getTextField()
	{
		if(_fieldPool.length > 0)
		{
			return _fieldPool.removeLast();
		}
		else
		{
			return new TextField();
		}
	}

	Sprite getSprite()
	{
		if(_spritePool.length > 0)
		{
			return _spritePool.removeLast();
		}
		else
		{
			return new Sprite();
		}
	}

	void redraw()
	{
		if(_items.numChildren > 1)
		{
			while(_items.numChildren > 0)
			{
//				print("len: " + _items.numChildren.toString());
				DisplayObject removedKid = _items.getChildAt(_items.numChildren - 1);
				_items.removeChildAt(_items.numChildren - 1);
				if(removedKid is TextField)
				{
					_fieldPool.add(removedKid);
				}
				else if(removedKid is Sprite)
				{
					_spritePool.add(removedKid);
				}
				else
				{
					throw new Error("omg, border, we've got a Dodson here!");
				}
			}
		}

		num startX = 24;
		num startY = 0;
		if(hitAreas == null)
		{
			hitAreas = new List<Sprite>();
		}
		else
		{
			hitAreas.clear();
		}

		if(_menuItems == null)
		{
			return;
		}

		_menuItems.forEach((MenuItem item)
		{
			// create name
			TextField field = getTextField();
			field.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 36, Color.White);
			field.text = item.name;
			field.x = startX;
			field.y = startY;
			field.width = 200;
			field.height = 36;
			startY += 24;
			field.wordWrap = false;
			field.multiline = false;
//			field.border = true;
//			field.borderColor = Color.White;
			_items.addChild(field);

			// TODO: more efficient to measure where you clicked on Y
			// vs. creating 20 billion hitAreas, n00b.

			// given up on figuring out the box thing for TextField's,
			// making shapes for hit areas
			Sprite hitArea = getSprite();
			_items.addChild(hitArea);
			hitArea.graphics.rect(0, 0, field.width, 24);
			hitArea.graphics.fillColor(Color.Green);
			hitArea.graphics.strokeColor(Color.Black);
			hitArea.alpha = 0.0;
			hitArea.x = field.x;
			hitArea.y = field.y + field.height - hitArea.height;
			hitArea.userData = {"type": "hitArea", "data": item.name};
			hitAreas.add(hitArea);
//			hitArea.onMouseClick.listen((MouseEvent event)
//			{
//                _controller.add(item.name);
//			});
		});

		hitAreas.forEach((Sprite sprite)
		{
			_items.setChildIndex(sprite, _items.numChildren - 1);
		});
	}

	void render(RenderState renderState)
	{
		super.render(renderState);
	}
}