part of components;

class TextDropper
{
	List<TextField> _pool = new List<TextField>();
	Stage _stage;
	RenderLoop _renderLoop;

	TextDropper(Stage this._stage, RenderLoop this._renderLoop)
	{
	}

	void addTextDrop(DisplayObject target, int value, {int color: Color.White})
	{
		TextField field = _getField();
		_stage.addChild(field);
		Point point = new Point(target.x, target.y);
//		point = target.localToGlobal(point);
		field.x = point.x + 2;
		field.y = point.y;
		field.text = value.toString();
//		print("color: $color");
		field.defaultTextFormat.color = color;

		// TODO: object pool these
		Tween tweenUp = new Tween(field, 0.1, TransitionFunction.easeOutExponential);
		tweenUp.animate.y.to(field.y - 10);

		Tween tweenDown = new Tween(field, 0.5, TransitionFunction.easeOutBounce);
		tweenDown.animate.y.to(field.y + 10);

		Tween tweenRemove = new Tween(field, 0.5);
		tweenRemove.onComplete = () => _cleanUp(field);

		_renderLoop.juggler.addChain([tweenUp, tweenDown, tweenRemove]);
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
			field.defaultTextFormat = new TextFormat('Final Fantasy VI SNESa', 26, Color.Black);
			field.text = "???";
			field.width = 220;
			field.height = 30;
			field.wordWrap = false;
			field.multiline = false;
			field.defaultTextFormat.strokeColor = Color.Black;
			field.defaultTextFormat.strokeWidth = 2;
			return field;
		}
	}

	void _cleanUp(TextField field)
	{
		field.removeFromParent();
		_pool.add(field);
	}
}