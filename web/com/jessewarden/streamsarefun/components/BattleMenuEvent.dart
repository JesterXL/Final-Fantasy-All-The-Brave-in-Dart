part of components;

class BattleMenuEvent
{
	static const String ITEM_SELECTED = "itemSelected";

	String type;
	String item;

	BattleMenuEvent(String type, String item)
	{
		this.type = type;
		this.item = item;
	}
}