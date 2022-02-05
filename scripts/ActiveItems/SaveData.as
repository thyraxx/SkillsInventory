namespace ActiveItems
{
	class SaveData
	{
		PlayerRecord@ m_record;

		array<ActiveItemSkill@> m_items;
		array<ActiveItemSkillDef@> m_hotbar;

		SaveData(PlayerRecord@ record)
		{
			@m_record = record;

			for (uint i = 0; i < 6; i++)
				m_hotbar.insertLast(null);
		}

		ActiveItemSkill@ GetItem(const string &in id)
		{
			return GetItem(HashString(id));
		}

		ActiveItemSkill@ GetItem(uint idHash)
		{
			for (uint i = 0; i < m_items.length(); i++)
			{
				auto item = m_items[i];
				if (item.m_def.m_idHash == idHash)
					return item;
			}
			return null;
		}

		ActiveItemSkill@ GiveItem(const string &in id, int amount = 1)
		{
			print(id);
			print(HashString(id));
			return GiveItem(HashString(id), amount);
		}

		ActiveItemSkill@ GiveItem(uint idHash, int amount = 1)
		{
			auto itemDef = GetActiveItem(idHash);
			if (itemDef is null)
			{
				PrintError("Unable to give item with hash " + idHash + ", it was not found!");
				return null;
			}
			return GiveItem(itemDef, amount);
		}

		ActiveItemSkill@ GiveItem(ActiveItemSkillDef@ def, int amount = 1)
		{
			if (amount <= 0)
				return null;

			auto item = GetItem(def.m_idHash);
			if (item is null)
			{
				@item = def.Instantiate();
				m_items.insertLast(item);
				item.OnCreated(def);
			}

			item.m_amount += amount;
			item.OnGiven(m_record, amount);

			return item;
		}

		void TakeItem(ActiveItemSkill@ item, int amount = 1)
		{
			if (amount <= 0)
				return;

			item.m_amount -= amount;
			if (item.m_amount <= 0)
			{
				int index = m_items.findByRef(item);
				if (index != -1)
					m_items.removeAt(index);
			}
		}

		bool ConsumeItem(const string &in id)
		{
			auto item = GetItem(id);
			if (item is null)
			{
				PrintError("Item with ID \"" + id + "\" is not in inventory!");
				return true;
			}
			return ConsumeItem(item);
		}

		bool ConsumeItem(ActiveItemSkill@ item)
		{
			auto player = cast<Player>(m_record.actor);
			if (player is null)
			{
				//TODO: It would be cool to have a revive item.. maybe?
				PrintError("Item with ID \"" + item.m_def.m_id + "\" can not be used because player is dead!");
				return false;
			}

			if (item.m_amount <= 0)
			{
				PrintError("Item with ID \"" + item.m_def.m_id + "\" can not be used because there are none left in inventory!");
				return false;
			}

			if (!item.CanUse(player))
			{
				PrintError("Item with ID \"" + item.m_def.m_id + "\" can not be used right now!");
				return false;
			}

			if (!item.Use(player))
			{
				PrintError("Using item with ID \"" + item.m_def.m_id + "\" didn't work!");
				return false;
			}

			TakeItem(item);
			return true;
		}

		void SetHotbar(int index, ActiveItemSkillDef@ itemDef)
		{
			for (uint i = 0; i < m_hotbar.length(); i++)
			{
				if (m_hotbar[i] is itemDef)
					@m_hotbar[i] = null;
			}
			@m_hotbar[index] = itemDef;
		}

		void Save(SValueBuilder@ builder)
		{
			builder.PushArray("items");
			for (uint i = 0; i < m_items.length(); i++)
			{
				builder.PushDictionary();
				m_items[i].Save(builder);
				builder.PopDictionary();
			}
			builder.PopArray();

			builder.PushArray("hotbar");
			for (uint i = 0; i < m_hotbar.length(); i++)
			{
				auto itemDef = m_hotbar[i];
				if (itemDef is null)
					builder.PushInteger(0);
				else
					builder.PushInteger(int(itemDef.m_idHash));
			}
			builder.PopArray();
		}

		void Load(SValue@ sv)
		{
			auto arrItems = GetParamArray(UnitPtr(), sv, "items", false);
			if (arrItems !is null)
			{
				for (uint i = 0; i < arrItems.length(); i++)
				{
					auto svItem = arrItems[i];

					string id = GetParamString(UnitPtr(), svItem, "id");
					auto itemDef = GetActiveItem(id);
					if (itemDef is null)
					{
						PrintError("Unable to find active item definition for ID \"" + id + "\"!");
						continue;
					}

					auto newItem = GiveItem(itemDef);
					if (newItem !is null)
						newItem.Load(svItem);
				}
			}

			auto arrHotbar = GetParamArray(UnitPtr(), sv, "hotbar", false);
			if (arrHotbar !is null)
			{
				for (int i = 0; i < min(6, arrHotbar.length()); i++)
				{
					uint idHash = uint(arrHotbar[i].GetInteger());
					if (idHash == 0)
						continue;

					auto itemDef = GetActiveItem(idHash);
					if (itemDef is null)
					{
						PrintError("Unable to find active item definition for ID " + idHash + " for hotbar!");
						continue;
					}

					@m_hotbar[i] = itemDef;
				}
			}
		}
	}
}
