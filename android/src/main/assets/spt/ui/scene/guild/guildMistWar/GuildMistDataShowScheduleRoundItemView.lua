local Color = clr.UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistDataShowScheduleRoundItemView = class(unity.base)

function GuildMistDataShowScheduleRoundItemView:ctor()
    self.attack = self.___ex.attack
    self.defense = self.___ex.defense
    self.capture = self.___ex.capture
    self.resize = self.___ex.resize
end

function GuildMistDataShowScheduleRoundItemView:Init(data, myGid)
    self.attack.name.text = data.atkName
    if data.atkGid == myGid then
        self.attack.name.color = Color(1, 1, 0.57, 1)  -- FFFE91FF
    else
        self.attack.name.color = Color(1, 1, 1, 0.8)
    end
    if data.defGid == myGid then
        self.defense.name.color = Color(1, 1, 0.57, 1)  -- FFFE91FF
    else
        self.defense.name.color = Color(1, 1, 1, 0.8)
    end
    self.defense.name.text = data.defName
    self.capture.text = tostring(data.atkScore or 0)
    self.resize.text = tostring(data.defScore or 0)
    GameObjectHelper.FastSetActive(self.attack.buff.transform.parent.gameObject, data.atkBuff)
    GameObjectHelper.FastSetActive(self.defense.buff.transform.parent.gameObject, data.defBuff)
    GameObjectHelper.FastSetActive(self.attack.win, tonumber(data.ret) == 1)
    GameObjectHelper.FastSetActive(self.defense.win, tonumber(data.ret) == 0)
    if data.atkBuff then
        self.attack.buff.text = lang.trans("guild_war_attack", string.sub(data.atkBuff, -2))
    end
    if data.defBuff then
        self.defense.buff.text = lang.trans("guild_war_defense", string.sub(data.defBuff, -2))
    end
end

return GuildMistDataShowScheduleRoundItemView
