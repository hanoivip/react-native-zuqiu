local Vector2 = clr.UnityEngine.Vector2
local GuildDataShowScheduleItemView = class(unity.base)

function GuildDataShowScheduleItemView:ctor()
    self.content = self.___ex.content
    self.vertial = self.___ex.vertial
    self.roundTxt = self.___ex.roundTxt
end

function GuildDataShowScheduleItemView:InitView(data, myGid)
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWarScheduleRoundItem.prefab"
    -- 待优化
    res.ClearChildren(self.content)
    for k, v in pairs(data.list) do
        local obj, spt = res.Instantiate(path)
        obj.transform:SetParent(self.content, false)
        spt:Init(v, myGid)
    end

    local height = #data.list * (53 + self.vertial.spacing) + self.vertial.padding.top + self.vertial.padding.bottom
    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, height + 85)
    self.content.sizeDelta = Vector2(self.transform.sizeDelta.x, height)
    self.roundTxt.text = lang.transstr("round_num", tostring(data.round))
end

return GuildDataShowScheduleItemView
