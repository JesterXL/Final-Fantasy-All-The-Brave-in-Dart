part of components;

class BattleTimerBar extends DisplayObjectContainer
{
	Shape bar;
	Shape green;
	Shape back;
	num _percentage = 1;
	bool percentageDirty = false;
	StateMachine fsm;
	AnimationChain flash;
	bool flashDirty = false;
	Juggler juggler;

	static const num ROUND = 8;
	static const int WIDTH = 70;
	static const int HEIGHT = 20;

	num get percentage => _percentage;
	void set percentage(num value)
	{
		if(value == null)
		{
			value = 0;
		}

		if(_percentage == value)
		{
			return;
		}
		value.clamp(0, 1);
		_percentage = value;
		percentageDirty = true;
		if(value == 1)
		{
			fsm.changeState("ready");
		}
		else
		{
			fsm.changeState("loading");
		}
	}

	BattleTimerBar(this.juggler)
	{
		init();
	}

	void init()
	{
		back = new Shape();
		back.graphics.rectRound(0, 0, WIDTH, HEIGHT, ROUND, ROUND);
		back.graphics.fillColor(Color.Navy);
		back.graphics.strokeColor(Color.White, 3);
		addChild(back);

		green = new Shape();
		green.graphics.rectRound(ROUND/2, ROUND/2, WIDTH - ROUND, HEIGHT - ROUND, ROUND, ROUND);
		green.graphics.fillColor(Color.Gold);
		addChild(green);

//		bar = new Shape();
//		bar.graphics.rectRound(0, 0, WIDTH, HEIGHT, 6, 6);
//		bar.x = 1;
//		bar.y = 1;
//		bar.graphics.strokeColor(Color.Black, 2);
//		addChild(bar);

		fsm = new StateMachine();
		fsm.addState("loading");
		fsm.addState("ready",
		enter: ()
		{
			flash = new AnimationChain();
			const SPEED = 0.05;
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("readyWhite"));
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("readyGold"));
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("readyWhite"));
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("readyGold"));
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("readyWhite"));
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("readyGold"));
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("readyWhite"));
			flash.add(new Tween(green, SPEED, Transition.linear)
				..onStart = () => fsm.changeState("idle"));
			juggler.add(flash);
		});
		fsm.addState("readyWhite",
		enter: ()
		{
			flashDirty = true;
		});
		fsm.addState("readyGold",
		enter: ()
		{
			flashDirty = true;
		});
		fsm.addState("idle",
		enter: ()
		{
			this.visible = false;
		},
		exit: ()
		{
			this.visible = true;
		});
		fsm.initialState = "idle";

	}

	void render(RenderState renderState)
	{
		super.render(renderState);
		if(percentageDirty)
		{
			percentageDirty = false;
			green.graphics.clear();
			green.graphics.rectRound(ROUND/2, ROUND/2, ((WIDTH - ROUND) * _percentage), HEIGHT - ROUND, ROUND, ROUND);
			green.graphics.fillColor(Color.Gold);
		}

		if(flashDirty)
		{
//			print("state: ${fsm.currentState.name}");
			flashDirty = false;
			green.graphics.clear();
			green.graphics.rectRound(ROUND/2, ROUND/2, ((WIDTH - ROUND) * _percentage), HEIGHT - ROUND, ROUND, ROUND);
			if(fsm.currentState.name == "readyWhite")
			{
				green.graphics.fillColor(Color.White);
			}
			else if(fsm.currentState.name == "readyGold")
			{
				green.graphics.fillColor(Color.Gold);
			}
		}
	}
}