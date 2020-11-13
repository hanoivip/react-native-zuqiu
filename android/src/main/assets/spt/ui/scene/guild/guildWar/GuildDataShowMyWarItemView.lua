local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildDataShowMyWarItemView = class(unity.base)

function GuildDataShowMyWarItemView:ctor()
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
end

function GuildDataShowMyWarItemView:Init(data, maxFinishedRound)
    -- 名字
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
    else
        self.gamingTxt1.text = lang.trans("guild_war_begin")
        self.gamingTxt2.text = lang.trans("guild_war_begin")
    end

    self.capture1Txt.text = lang.trans("guild_war_capture", tostring(data.atk.seizeCnt))
    self.capture2Txt.text = lang.trans("guild_war_capture", tostring(data.def.seizeCnt))
    self.seize1Txt.text = lang.trans("guild_war_seize", tostring(data.atk.captureCnt))
    self.seize2Txt.text = lang.trans("guild_war_seize", tostring(data.def.captureCnt))

    GameObjectHelper.FastSetActive(self.attackWin, tonumber(data.atk.ret) == 1)
    GameObjectHelper.FastSetActive(self.attackLose, tonumber(data.atk.ret) ~= 1)
    GameObjectHelper.FastSetActive(self.defenseWin, tonumber(data.def.ret) ~= 1)
    GameObjectHelper.FastSetActive(self.defenseLose, tonumber(data.def.ret) == 1)
    GameObjectHelper.FastSetActive(self.attack.hide, tonumber(data.round) < tonumber(maxFinishedRound) + 1)
    GameObjectHelper.FastSetActive(self.defense.hide, tonumber(data.round) < tonumber(maxFinishedRound) + 1)
    GameObjectHelper.FastSetActive(self.attack.gaming, tonumber(data.round) >= tonumber(maxFinishedRound) + 1)
    GameObjectHelper.FastSetActive(self.defense.gaming, tonumber(data.round) >= tonumber(maxFinishedRound) + 1)

    self:RegOnBtnClick()
end

function GuildDataShowMyWarItemView:RegOnBtnClick()
    self.atkBuyBuffBtn:regOnButtonClick(function ()
        if type(self.onBuyAtkBuffBtnClick) == "function" then
            self.onBuyAtkBuffBtnClick()
        end
    end)
    self.defBuyBuffBtn:regOnButtonClick(function ()
        if type(self.onBuyDefBuffBtnClick) == "function" then
            self.onBuyDefBuffBtnClick()
        end
    end)
end

function GuildDataShowMyWarItemView:IsShowBuffStore(isShow)
    GameObjectHelper.FastSetActive(self.atkBuyBuffBtn.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.defBuyBuffBtn.gameObject, isShow)
end



return GuildDataShowMyWarItemView