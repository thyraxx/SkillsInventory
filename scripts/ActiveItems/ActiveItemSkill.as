namespace ActiveItems
{
	class ActiveItemSkill
	{
		ActiveItemSkillDef@ m_def;

		int m_amount;

		ActiveItemSkill(SValue& params)
		{
		}
		
		ActiveItemSkill(SValue& params, string path)
		{
		}

		void OnCreated(ActiveItemSkillDef@ def)
		{
			@m_def = def;
		}

		void OnGiven(PlayerRecord@ player, int amount) {}

		void Save(SValueBuilder@ builder)
		{
			builder.PushString("id", m_def.m_id);
			builder.PushInteger("amount", m_amount);
		}

		void Load(SValue@ sv)
		{
			m_amount = GetParamInt(UnitPtr(), sv, "amount", false, 1);
		}

		bool CanUse(Player@ player) { return false; }
		bool Use(Player@ player) { return false; }
		void NetUse(PlayerHusk@ player) {}
	}
}
