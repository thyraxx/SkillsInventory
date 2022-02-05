namespace ActiveItemsHooks
{
	HotbarHUD@ g_hotbarHUD;

	void GiveActiveItemCFunc(cvar_t@ arg0)
	{
		auto player = GetLocalPlayer();
		if (player is null)
			return;

		string id = arg0.GetString();

		auto saveData = ActiveItems::GetLocalSaveData();
		saveData.GiveItem(id);
	}

	[Hook]
	void GameModeConstructor(Campaign@ campaign)
	{
		campaign.m_playerMenu.m_tabSystem.AddTab(PlayerInventoryTab(), campaign.m_guiBuilder);

		@g_hotbarHUD = HotbarHUD(campaign.m_guiBuilder);
		g_hotbarHUD.Initialize();

		AddFunction("give_active_item", { cvar_type::String }, GiveActiveItemCFunc, cvar_flags::Cheat);
	}

	[Hook]
	void GameModeUpdate(Campaign@ campaign, int dt, GameInput& gameInput, MenuInput& menuInput)
	{
		auto saveData = ActiveItems::GetLocalSaveData();
		for (uint i = 0; i < saveData.m_hotbar.length(); i++)
		{
			auto bs = Platform::GetKeyState(DefinedKey(int(DefinedKey::D1) + i));
			if (!bs.Pressed)
				continue;

			auto itemDef = saveData.m_hotbar[i];
			if (itemDef is null)
				continue;

			auto item = saveData.GetItem(itemDef.m_idHash);
			if (item is null)
			{
				//TODO: Some notification that there's no more items of this type in inventory?
				continue;
			}

			saveData.ConsumeItem(item);
		}
	}

	[Hook]
	void GameModeUpdateWidgets(Campaign@ campaign, int dt, GameInput& gameInput, MenuInput& menuInput)
	{
		g_hotbarHUD.Update(dt);
	}

	[Hook]
	void GameModeRenderFrame(Campaign@ campaign, int idt, SpriteBatch& sb)
	{
		g_hotbarHUD.Draw(sb, idt);
	}

	[Hook]
	void WidgetHosterLoad(IWidgetHoster@ host, GUIBuilder@ b, GUIDef@ def)
	{
		if (def.GetPath() != "gui/playermenu.gui")
			return;

		// Add the container for our own tab contents
		auto wStats = host.m_widget.GetWidgetById("tab-stats");
		if (wStats is null)
		{
			PrintError("Unable to find \"tab-stats\"!");
			return;
		}
		auto wNewContainer = wStats.Clone();
		wNewContainer.SetID("tab-inventory");
		wStats.m_parent.AddChild(wNewContainer);

		// Add the button to the button list
		auto wTabsClip = host.m_widget.GetWidgetById("tabs-clip");
		auto wNewButton = cast<ScalableSpriteButtonWidget>(wTabsClip.m_children[0].Clone());
		wNewButton.m_value = "inventory";
		wNewButton.m_func = "set-tab inventory";
		wNewButton.SetText("INVENTORY");
		wTabsClip.AddChild(wNewButton);

		// Also let the checkbox group know the button exists so that it will get checked properly
		auto wTabsContainer = cast<CheckBoxGroupWidget>(host.m_widget.GetWidgetById("tabs-container"));
		wTabsContainer.m_checkboxes.insertLast(wNewButton);
	}

	[Hook]
	void LoadWidgetProducers(GUIBuilder@ builder)
	{
		builder.AddWidgetProducer("inventory-button", LoadInventoryButtonWidget);
		builder.AddWidgetProducer("hotbar-item", LoadHotbarItemWidget);
	}

	[Hook]
	void PlayerRecordSave(PlayerRecord@ record, SValueBuilder &builder)
	{
		auto saveData = ActiveItems::GetLocalSaveData();
		if (saveData !is null)
		{
			builder.PushDictionary("activeitems");
			saveData.Save(builder);
			builder.PopDictionary();
		}
	}

	[Hook]
	void PlayerRecordLoad(PlayerRecord@ record, SValue@ sval)
	{
		ActiveItems::SaveData@ saveData;
		if (!record.userdata.get("activeitems", @saveData))
		{
			@saveData = ActiveItems::SaveData(record);
			record.userdata.set("activeitems", @saveData);
		}

		auto svActiveItems = sval.GetDictionaryEntry("activeitems");
		if (svActiveItems !is null)
			saveData.Load(svActiveItems);

		if (record.local)
			g_hotbarHUD.ReloadList();
	}
}
