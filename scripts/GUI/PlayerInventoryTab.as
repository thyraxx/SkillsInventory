class PlayerInventoryTab : PlayerMenuTab
{
	ScrollableWidget@ m_wItemList;
	Widget@ m_wItemTemplate;

	Widget@ m_wHotbarList;
	Widget@ m_wHotbarTemplate;

	ActiveItems::ActiveItemSkill@ m_dragDropItem;

	PlayerInventoryTab()
	{
		m_id = "inventory";
	}

	void OnCreated() override
	{
		@m_wItemList = cast<ScrollableWidget>(m_widget.GetWidgetById("list-items"));
		@m_wItemTemplate = m_widget.GetWidgetById("template-item");

		@m_wHotbarList = m_widget.GetWidgetById("list-hotbar");
		@m_wHotbarTemplate = m_widget.GetWidgetById("template-hotbar");
	}

	void OnShow() override
	{
		ReloadList();
	}

	void OnHidden() override
	{
		@m_dragDropItem = null;
	}

	void ReloadList()
	{
		auto saveData = ActiveItems::GetLocalSaveData();

		// Item list
		m_wItemList.PauseScrolling();
		m_wItemList.ClearChildren();

		for (uint i = 0; i < saveData.m_items.length(); i++)
		{
			auto item = saveData.m_items[i];
			auto itemDef = item.m_def;

			auto wNewItem = cast<InventoryButton>(m_wItemTemplate.Clone());
			wNewItem.SetID("");
			wNewItem.m_visible = true;
			@wNewItem.m_tab = this;

			wNewItem.SetItem(item);
			wNewItem.m_func = "use-item " + itemDef.m_id;

			m_wItemList.AddChild(wNewItem);
		}

		m_wItemList.ResumeScrolling();

		// Hotbar list
		m_wHotbarList.ClearChildren();
		for (uint i = 0; i < saveData.m_hotbar.length(); i++)
		{
			auto itemDef = saveData.m_hotbar[i];

			auto wNewHotbarItem = cast<HotbarItemWidget>(m_wHotbarTemplate.Clone());
			wNewHotbarItem.SetID("");
			wNewHotbarItem.m_visible = true;

			wNewHotbarItem.SetHotbarIndex(i);

			if (itemDef !is null)
			{
				wNewHotbarItem.m_tooltipTitle = "\\c" + GetItemQualityColorString(itemDef.m_quality) + Resources::GetString(itemDef.m_name);
				wNewHotbarItem.m_tooltipText = Resources::GetString(itemDef.m_description);
			}

			auto wNum = cast<TextWidget>(wNewHotbarItem.GetWidgetById("number"));
			if (wNum !is null)
				wNum.SetText("" + (i + 1));

			if (itemDef !is null)
			{
				auto wIcon = cast<SpriteWidget>(wNewHotbarItem.GetWidgetById("icon"));
				if (wIcon !is null)
					wIcon.SetSprite(itemDef.m_sprite);
			}

			m_wHotbarList.AddChild(wNewHotbarItem);
		}

		m_widget.m_host.m_forceFocus = true;
	}

	void Update(int dt) override
	{
		auto mi = GetMenuInput();

		if (mi.Forward.Released && m_dragDropItem !is null)
		{
			auto gm = cast<BaseGameMode>(g_gameMode);
			auto wHotbarItem = cast<HotbarItemWidget>(gm.m_widgetUnderCursor);
			if (wHotbarItem !is null)
			{
				auto saveData = ActiveItems::GetLocalSaveData();
				saveData.SetHotbar(wHotbarItem.m_hotbarIndex, m_dragDropItem.m_def);
				ReloadList();
				ActiveItemsHooks::g_hotbarHUD.ReloadList();
			}
		}

		if (!mi.Forward.Down)
			@m_dragDropItem = null;
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (m_dragDropItem !is null)
		{
			auto itemDef = m_dragDropItem.m_def;
			auto itemSprite = itemDef.m_sprite;

			auto gm = cast<BaseGameMode>(g_gameMode);
			vec2 dragMousePos = gm.m_mice[0].GetPos(idt);
			dragMousePos /= gm.m_wndScale;
			dragMousePos.x -= itemSprite.GetWidth() / 2;
			dragMousePos.y -= itemSprite.GetHeight() / 2;

			itemSprite.Draw(sb, dragMousePos, g_menuTime);
		}
	}

	bool OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "use-item")
		{
			string itemId = parse[1];

			auto saveData = ActiveItems::GetLocalSaveData();
			saveData.ConsumeItem(itemId);

			ReloadList();
			return true;
		}
		return false;
	}
}
