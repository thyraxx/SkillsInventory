class InventoryButton : SpriteButtonWidget
{
	PlayerInventoryTab@ m_tab;

	BitmapFont@ m_font;
	BitmapString@ m_text;

	ActiveItems::ActiveItemSkill@ m_item;
	int m_amount = -1;

	InventoryButton()
	{
		super();
	}

	Widget@ Clone() override
	{
		InventoryButton@ w = InventoryButton();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		SpriteButtonWidget::Load(ctx);

		@m_font = Resources::GetBitmapFont(ctx.GetString("font", false, "gui/fonts/font_hw8.fnt"));
	}

	void SetItem(ActiveItems::ActiveItemSkill@ item)
	{
		@m_item = item;
		m_amount = m_item.m_amount;

		auto itemDef = m_item.m_def;

		m_tooltipTitle = "\\c" + GetItemQualityColorString(itemDef.m_quality) + Resources::GetString(itemDef.m_name);
		m_tooltipText = Resources::GetString(itemDef.m_description);

		if (m_amount == 0)
			@m_text = null;
		else
			@m_text = m_font.BuildText(formatThousands(m_amount));

		m_enabled = m_item.CanUse(GetLocalPlayer());
	}

	void Update(int dt) override
	{
		SpriteButtonWidget::Update(dt);

		if (m_item is null)
			return;

		if (m_amount != m_item.m_amount)
			SetItem(m_item);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		SpriteButtonWidget::DoDraw(sb, pos);

		if (m_item !is null)
		{
			if (!m_enabled)
				sb.EnableColorize(vec4(0, 0, 0, 1), vec4(0.125, 0.125, 0.125, 1), vec4(0.25, 0.25, 0.25, 1));

			m_item.m_def.m_sprite.Draw(sb, pos + vec2(4, 4), g_menuTime);

			if (!m_enabled)
				sb.DisableColorize();
		}

		if (m_text !is null)
		{
			sb.DrawString(pos + vec2(
				m_width - 5 - m_text.GetWidth(),
				m_height - 4 - m_text.GetHeight()
			), m_text);
		}
	}

	void OnMouseLeave(vec2 mousePos) override
	{
		if (m_buttonDown)
			@m_tab.m_dragDropItem = m_item;

		SpriteButtonWidget::OnMouseLeave(mousePos);
	}
}

ref@ LoadInventoryButtonWidget(WidgetLoadingContext &ctx)
{
	InventoryButton@ w = InventoryButton();
	w.Load(ctx);
	return w;
}
