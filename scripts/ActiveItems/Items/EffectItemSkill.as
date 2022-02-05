namespace ActiveItems
{
	class EffectItemSkill : ActiveItemSkill
	{
		Skills::Skill@ m_skill;

		string m_path;

		EffectItemSkill(SValue& params)
		{
			super(params);
		}

		EffectItemSkill(SValue& params, string path)
		{
			super(params, path);
			m_path = path;
		}

		bool CanUse(Player@ player) override
		{
			//return CanApplyEffects(m_effects, player, player.m_unit, vec2(), vec2(), 1.0f);
			
			return true;
		}

		bool Use(Player@ player) override
		{
			//@m_skill = @player.LoadSkill("players/ranger/flurry_of_arrows.sval", 1);
			auto skill = player.LoadSkill("players/ranger/flurry_of_arrows.sval", 1);
			auto test = cast<Skills::ShootProjectileFan>(skill);
			test.Activate(vec2(0,0));	
			//test.Initialize(player, skill.m_icon, 1);
			//return ApplyEffects(m_effects, player, player.m_unit, vec2(), vec2(), 1.0f, false);
			//auto skill = LoadSingleSkill(m_name, null, m_testdata, 1);
			//skill.Activate(vec2(0, 0));

			//auto player = cast<PlayerBase>(g_players[0].actor);
			//print(player.LoadSkill(m_def.m_path, 2).Activate(vec2(0,0)));
			//print(m_hardcoreSkill.m_id);

			//m_hardcoreSkill.m_passive = false;
			//print(m_skill.m_name);
			print("Use");
			//m_skill.Activate(vec2(1,0));

			//g_allModifiers.TriggerEffects(player, null, Modifiers::EffectTrigger::CastSpell);
			//print(m_hardcoreSkill.m_name);
			//m_hardcoreSkill.m_data.Dump();
			//auto skill = player.LoadSingleSkill(
			//		m_hardcoreSkill.m_name,
			//		m_hardcoreSkill.m_icon,
			//		m_hardcoreSkill.m_data,
			//		3
			//	);

			//skill.m_description = m_hardcoreSkill.m_description;

			//auto testsk = cast<Skills::Skill>(skill);
			//testsk.m_isActive = false;

			//skill.m_isActive = true;

			//m_skill.Initialize(player.m_record.actor, m_skill.m_icon, 5);
			//testsk.Activate(vec2(0,0));
			//testsk.m_isActive = true;
			//testsk.Activate(vec2(0,0));
			return true;
		}

		void NetUse(PlayerHusk@ player) override
		{
			return;
			//ApplyEffects(m_effects, player, player.m_unit, vec2(), vec2(), 1.0f, true);
		}
	}
}
