part of components;

class TextDropper
{
	List<TextField> _pool = new List<TextField>();
	Stage _stage;
	Juggler _juggler;

	TextDropper(Stage this._stage, Juggler this._juggler)
	{
	}

	void addTextDrop(DisplayObject target, int value, {int color: Color.White, bool miss: false})
	{
		TextField field = _getField();
		_stage.addChild(field);
		Point point = new Point(target.x, target.y);
//		point = target.localToGlobal(point);
		field.x = point.x + (target.width / 2) - (field.width / 2);
		field.y = point.y + target.height - field.height;
//		field.border = true;
//		field.borderColor = Color.Green;
		if(miss == false)
		{
			field.text = value.abs().toString();
		}
		else
		{
			field.text = "MISS";
		}
//		print("color: $color");
		field.defaultTextFormat.color = color;

		// TODO: object pool these
		Tween tweenUp = new Tween(field, 0.25, Transition.easeOutExponential);
		tweenUp.animate.y.to(field.y - 40);

		Tween tweenDown = new Tween(field, 0.45, Transition.easeOutBounce);
		tweenDown.animate.y.to(field.y);

		Tween tweenRemove = new Tween(field, 0.6);
		tweenRemove.onComplete = () => _cleanUp(field);

		_juggler.addChain([tweenUp, tweenDown, tweenRemove]);
	}

	TextField _getField()
	{
		if(_pool.length > 0)
		{
			return _pool.removeLast();
		}
		else
		{
			TextField field = new TextField();
			field.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 36, Color.Black);
			field.text = "???";
			field.width = 100;
			field.height = 40;
			field.wordWrap = false;
			field.multiline = false;
			field.defaultTextFormat.strokeColor = Color.Black;
			field.defaultTextFormat.strokeWidth = 2;
			field.defaultTextFormat.align = "center";
			return field;
		}
	}

	void _cleanUp(TextField field)
	{
		field.removeFromParent();
		_pool.add(field);
	}
}