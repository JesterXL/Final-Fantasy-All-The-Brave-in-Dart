part of components;

class BattleMenuEvent
{
	static const String ITEM_SELECTED = "itemSelected";

	String type;
	var item;

	BattleMenuEvent(String type, String item)
	{
		this.type = type;
		this.item = item;
	}
}