class HotbarHUD : IWidgetHoster
{
	Widget@ m_wList;
	Widget@ m_wTemplate;

	array<HotbarItemWidget@> m_arrItems;

	HotbarHUD(GUIBuilder@ b)
	{
		LoadWidget(b, "gui/hotbar.gui");
	}

	void Initialize()
	{
		@m_wList = m_widget.GetWidgetById("list");
		@m_wTemplate = m_widget.GetWidgetById("template");

		ReloadList();
	}

	void ReloadList()
	{
		m_wList.ClearChildren();
		m_arrItems.removeRange(0, m_arrItems.length());

		auto saveData = ActiveItems::GetLocalSaveData();
		if (saveData is null)
			return;

		for (uint i = 0; i < saveData.m_hotbar.length(); i++)
		{
			auto itemDef = saveData.m_hotbar[i];
			/*
			if (itemDef is null)
				continue;
			*/

			auto wNewItem = cast<HotbarItemWidget>(m_wTemplate.Clone());
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			wNewItem.SetHotbarIndex(i);

			auto wNum = cast<TextWidget>(wNewItem.GetWidgetById("number"));
			if (wNum !is null)
				wNum.SetText("" + (i + 1));

			if (itemDef !is null)
			{
				auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
				if (wIcon !is null)
					wIcon.SetSprite(itemDef.m_sprite);
			}

			wNewItem.RefreshItemData();

			m_arrItems.insertLast(wNewItem);
			m_wList.AddChild(wNewItem);
		}
	}
}
