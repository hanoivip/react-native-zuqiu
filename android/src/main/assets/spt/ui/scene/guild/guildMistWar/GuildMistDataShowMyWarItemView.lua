local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistDataShowMyWarItemView = class(unity.base)

function GuildMistDataShowMyWarItemView:ctor()
    self.nameTxt = self.___ex.name
    self.buff = self.___ex.buff
    self.roundTxt = self.___ex.roundTxt
    self.capture1Txt = self.___ex.capture1Txt
    self.capture2Txt = self.___ex.capture2Txt
    self.seize1Txt = self.___ex.seize1Txt
    self.seize2Txt = self.___ex.seize2Txt
    self.attackWin = self.___ex.attackWin
    self.defenseWin = self.___ex.defenseWin
    self.attackLose = self.___ex.attackLose
    self.defenseLose = self.___ex.defenseLose
    self.atkBuyBuffBtn = self.___ex.atkBuyBuffBtn
    self.defBuyBuffBtn = self.___ex.defBuyBuffBtn
    self.attack = self.___ex.attack
    self.defense = self.___ex.defense
    self.gamingTxt1 = self.___ex.gamingTxt1
    self.gamingTxt2 = self.___ex.gamingTxt2
    self.changeMapBtn = self.___ex.changeMapBtn
end

function GuildMistDataShowMyWarItemView:Init(data, maxFinishedRound)
    self.nameTxt.attack1.text = data.atk.attackName
    self.nameTxt.defense1.text = data.atk.defenseName
    self.nameTxt.attack2.text = data.def.attackName
    self.nameTxt.defense2.text = data.def.defenseName
    self.roundTxt.text = lang.transstr("round_num", tostring(data.round))

    GameObjectHelper.FastSetActive(self.buff.attack1.transform.parent.gameObject, data.atk.buff.atkBuff ~= nil)
    if data.atk.buff.atkBuff ~= nil then
        self.buff.attack1.text = lang.trans("guild_war_attack", string.sub(data.atk.buff.atkBuff, -2))
    end
    GameObjectHelper.FastSetActive(self.buff.defense1.transform.parent.gameObject, data.atk.buff.defBuff ~= nil)
    if data.atk.buff.defBuff ~= nil then
        self.buff.defense1.text = lang.trans("guild_war_defense", string.sub(data.atk.buff.defBuff, -2))
    end
    GameObjectHelper.FastSetActive(self.buff.attack2.transform.parent.gameObject, data.def.buff.atkBuff ~= nil)
    if data.def.buff.atkBuff ~= nil then
        self.buff.attack2.text = lang.trans("guild_war_attack", string.sub(data.def.buff.atkBuff, -2))
    end
    GameObjectHelper.FastSetActive(self.buff.defense2.transform.parent.gameObject, data.def.buff.defBuff ~= nil)
    if data.def.buff.defBuff ~= nil then
        self.buff.defense2.text = lang.trans("guild_war_defense", string.sub(data.def.buff.defBuff, -2))
    end
    if tonumber(data.round) >= tonumber(maxFinishedRound) + 2 then
        self.gamingTxt1.text = lang.trans("guild_war_no_begin")
        self.gamingTxt2.text = lang.trans("guild_war_no_begin")
        self:IsShowBuffStore(true)
    else
        self.gamingTxt1.text = lang.trans("guild_war_begin")
        self.gamingTxt2.text = lang.trans("guild_war_begin")
        GameObjectHelper.FastSetActive(self.atkBuyBuffBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.defBuyBuffBtn.gameObject, true)
        GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, false)
    end
    local ackScoreStr = lang.transstr("mist_attack_score")
    local defScoreStr = lang.transstr("mist_defender_score")
    self.capture1Txt.text = ackScoreStr .. ":" ..tostring(data.atk.atkScore or 0)
    self.capture2Txt.text = ackScoreStr .. ":" ..tostring(data.def.atkScore or 0)
    self.seize1Txt.text = defScoreStr .. ":" ..tostring(data.atk.defScore or 0)
    self.seize2Txt.text = defScoreStr .. ":" ..tostring(data.atk.defScore or 0)

    GameObjectHelper.FastSetActive(self.attackWin, false)
    GameObjectHelper.FastSetActive(self.attackLose, false)
    GameObjectHelper.FastSetActive(self.defenseWin, false)
    GameObjectHelper.FastSetActive(self.defenseLose, false)
    GameObjectHelper.FastSetActive(self.attack.hide, tonumber(data.round) < tonumber(maxFinishedRound) + 1)
    GameObjectHelper.FastSetActive(self.defense.hide, tonumber(data.round) < tonumber(maxFinishedRound) + 1)
    GameObjectHelper.FastSetActive(self.attack.gaming, tonumber(data.round) >= tonumber(maxFinishedRound) + 1)
    GameObjectHelper.FastSetActive(self.defense.gaming, tonumber(data.round) >= tonumber(maxFinishedRound) + 1)

    self:RegOnBtnClick()
end

function GuildMistDataShowMyWarItemView:RegOnBtnClick()
    self.atkBuyBuffBtn:regOnButtonClick(function()
        if type(self.onBuyAtkBuffBtnClick) == "function" then
            self.onBuyAtkBuffBtnClick()
        end
    end)
    self.defBuyBuffBtn:regOnButtonClick(function()
        if type(self.onBuyDefBuffBtnClick) == "function" then
            self.onBuyDefBuffBtnClick()
        end
    end)
    self.changeMapBtn:regOnButtonClick(function()
        if type(self.onChangeMapBtnClick) == "function" then
            self.onChangeMapBtnClick()
        end
    end)
end

function GuildMistDataShowMyWarItemView:IsShowBuffStore(isShow)
    GameObjectHelper.FastSetActive(self.atkBuyBuffBtn.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.defBuyBuffBtn.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.changeMapBtn.gameObject, isShow)
end

return GuildMistDataShowMyWarItemView
