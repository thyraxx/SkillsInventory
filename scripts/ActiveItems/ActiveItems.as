namespace ActiveItems
{
	array<ActiveItemSkillDef@> g_items;

	ActiveItemSkillDef@ GetActiveItem(const string &in id)
	{
		return GetActiveItem(HashString(id));
	}

	ActiveItemSkillDef@ GetActiveItem(uint idHash)
	{
		for (uint i = 0; i < g_items.length(); i++)
		{
			auto item = g_items[i];
			//if (item.m_idHash == idHash)
				return item;
		}
		return null;
	}

	void LoadActiveItems(SValue@ sv, string path)
	{
		if (sv.GetType() != SValueType::Array)
		{
			PrintError("Active items sval must be an array!");
			return;
		}

		auto arr = sv.GetArray();
		for (uint i = 0; i < arr.length(); i++)
		{
			auto svItem = arr[i];
			if (svItem.GetType() != SValueType::Dictionary)
			{
				PrintError("Active item sval entry must be a dictionary!");
				continue;
			}

			auto newItemDef = ActiveItemSkillDef(svItem, path);
			g_items.insertLast(newItemDef);
		}

		print(g_items.length());
		print(g_items[0].m_idHash);

	}

	ActiveItems::SaveData@ GetLocalSaveData()
	{
		auto record = GetLocalPlayerRecord();
		if (record !is null)
		{
			ActiveItems::SaveData@ saveData;
			if (record.userdata.get("activeitems", @saveData))
				return saveData;
		}
		return null;
	}
}
