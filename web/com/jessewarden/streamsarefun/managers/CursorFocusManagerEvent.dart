part of managers;

class CursorFocusManagerEvent
{
	static const String SELECTED = "selected";
	static const String INDEX_CHANGED = "indexChanged";
	static const String MOVE_RIGHT = "moveRight";
	static const String MOVE_LEFT = "moveLeft";

	String type;
	String selectedItem;

	CursorFocusManagerEvent(this.type, {String this.selectedItem})
	{
	}

}