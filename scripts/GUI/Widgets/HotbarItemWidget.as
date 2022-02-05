class HotbarItemWidget : RectWidget
{
	int m_hotbarIndex = -1;

	TextWidget@ m_wAmount;

	HotbarItemWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		HotbarItemWidget@ w = HotbarItemWidget();
		CloneInto(w);
		return w;
	}

	void RefreshItemData()
	{
		if (m_hotbarIndex == -1)
			return;

		auto saveData = ActiveItems::GetLocalSaveData();
		auto itemDef = saveData.m_hotbar[m_hotbarIndex];
		ActiveItems::ActiveItemSkill@ item = (itemDef is null ? null : saveData.GetItem(itemDef.m_idHash));

		if (m_wAmount !is null)
		{
			m_wAmount.m_visible = (item !is null);
			if (item !is null)
			{
				m_wAmount.SetText(formatThousands(item.m_amount));
				m_wAmount.SetColor(vec4(1, 1, 1, 1));
			}
			else
			{
				m_wAmount.SetText("0");
				m_wAmount.SetColor(vec4(1, 0, 0, 1));
			}
		}
	}

	void Update(int dt) override
	{
		RefreshItemData();

		RectWidget::Update(dt);
	}

	void SetHotbarIndex(int index)
	{
		m_hotbarIndex = index;

		@m_wAmount = cast<TextWidget>(GetWidgetById("amount"));
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		RectWidget::Load(ctx);

		m_canFocus = true;
	}
}

ref@ LoadHotbarItemWidget(WidgetLoadingContext &ctx)
{
	HotbarItemWidget@ w = HotbarItemWidget();
	w.Load(ctx);
	return w;
}
