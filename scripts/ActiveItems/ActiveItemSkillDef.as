namespace ActiveItems
{
	class ActiveItemSkillDef
	{
		string m_id;
		uint m_idHash;

		string m_name;
		string m_description;
		ActorItemQuality m_quality;

		ScriptSprite@ m_sprite;

		string m_class;
		SValue@ m_sval;

		//HardcoreSkill@ m_hardcoreSkill;

		SValue@ m_testdata;

		string m_path;

		ActiveItemSkillDef(SValue@ svItem, string path)
		{
			m_id = GetParamString(UnitPtr(), svItem, "id");
			m_idHash = HashString(m_id);

			m_name = GetParamString(UnitPtr(), svItem, "name");
			m_description = GetParamString(UnitPtr(), svItem, "description");
			m_quality = ParseActorItemQuality(GetParamString(UnitPtr(), svItem, "quality"));


			@m_testdata = svItem.GetDictionaryEntry("skills");

			//@m_hardcoreSkill = HardcoreSkill(m_testdata, path);
			@m_sprite = ScriptSprite(GetParamArray(UnitPtr(), svItem, "icon"));


			m_class = GetParamString(UnitPtr(), svItem, "class");
			@m_sval = svItem;
			m_path = path;
			
		}

		ActiveItemSkill@ Instantiate()
		{
			auto newActiveItem = cast<ActiveItemSkill>(InstantiateClass(m_class, m_sval));
			if (newActiveItem is null)
			{
				PrintError("Unable to instantiate an active item of class \"" + m_class + "\"!");
				return null;
			}
			return newActiveItem;
		}

		//Skills::Skill@ LoadSingleSkill(string skillName, ScriptSprite@ icon, SValue@ skillData, int skillId)
		//{
		//	Skills::Skill@ skill;
//
		//	auto player = cast<PlayerBase>(g_players[0].actor);
//
		//	if (skillData is null || skillData.GetType() == SValueType::Null || skillData.GetType() == SValueType::Integer)
		//		@skill = Skills::NullSkill(player.m_unit);
		//	else
		//	{
		//		string c = GetParamString(player.m_unit, skillData, "class");
		//		@skill = cast<Skills::Skill>(InstantiateClass(c, player.m_unit, skillData));
		//		if (skill is null)
		//		{
		//			PrintError("Unable to instantiate class \"" + c + "\" for player skill!");
		//			return null;
		//		}
		//	}
//
		//	skill.Initialize(this, icon, skillId);
		//	skill.m_name = skillName;
//
		//	return skill;
		//}
	}
}
