local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Timer = require("ui.common.Timer")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local MistFightView = class(unity.base, "MistFightView")

function MistFightView:ctor()
--------Start_Auto_Generate--------
    self.fightSpt = self.___ex.fightSpt
    self.buttonTrans = self.___ex.buttonTrans
    self.myDataBtn = self.___ex.myDataBtn
    self.instructionBtn = self.___ex.instructionBtn
    self.scheduleBtn = self.___ex.scheduleBtn
    self.attackGo = self.___ex.attackGo
    self.mistAtkTitleTxt = self.___ex.mistAtkTitleTxt
    self.attackPeriodTxt = self.___ex.attackPeriodTxt
    self.attackGuildNameTxt = self.___ex.attackGuildNameTxt
    self.attackIconImg = self.___ex.attackIconImg
    self.attackBuffGo = self.___ex.attackBuffGo
    self.attackBuffTxt = self.___ex.attackBuffTxt
    self.attackRemainTimeTxt = self.___ex.attackRemainTimeTxt
    self.attackOccupyCountTxt = self.___ex.attackOccupyCountTxt
    self.attackScoreTxt = self.___ex.attackScoreTxt
    self.attackDetailBtn = self.___ex.attackDetailBtn
    self.toDefendBtn = self.___ex.toDefendBtn
    self.attackBuffStoreBtn = self.___ex.attackBuffStoreBtn
    self.attackRemainCountTxt = self.___ex.attackRemainCountTxt
    self.defenderGo = self.___ex.defenderGo
    self.mistDefTitleTxt = self.___ex.mistDefTitleTxt
    self.defenderPeriodTxt = self.___ex.defenderPeriodTxt
    self.defenderGuildNameTxt = self.___ex.defenderGuildNameTxt
    self.defenderIconImg = self.___ex.defenderIconImg
    self.defenderBuffGo = self.___ex.defenderBuffGo
    self.defenderBuffTxt = self.___ex.defenderBuffTxt
    self.defenderRemainTimeTxt = self.___ex.defenderRemainTimeTxt
    self.defenderOccupyCountTxt = self.___ex.defenderOccupyCountTxt
    self.defenderScoreTxt = self.___ex.defenderScoreTxt
    self.defenderDetailBtn = self.___ex.defenderDetailBtn
    self.toAttackBtn = self.___ex.toAttackBtn
    self.defendBuffStoreBtn = self.___ex.defendBuffStoreBtn
--------End_Auto_Generate----------

    self.attackBtnPos = Vector3(263, -335, 0)
    self.defendBtnPos = Vector3(-144, -335, 0)
end

function MistFightView:start()
    self:RegBtnEvent()
end

function MistFightView:RegBtnEvent()
    self.toDefendBtn:regOnButtonClick(function()
        self:OnBtnToDefendClick()
    end)
    self.toAttackBtn:regOnButtonClick(function()
        self:OnBtnToAttackClick()
    end)
    self.defenderDetailBtn:regOnButtonClick(function()
        self:OnBtnDefenderDetailClick()
    end)
    self.attackDetailBtn:regOnButtonClick(function()
        self:OnBtnAttackDetailClick()
    end)
    self.attackBuffStoreBtn:regOnButtonClick(function()
        self:OnBtnAttackBuffStoreClick()
    end)
    self.defendBuffStoreBtn:regOnButtonClick(function()
        self:OnBtnDefendBuffStoreClick()
    end)
    self.myDataBtn:regOnButtonClick(function()
        self:OnBtnMyDataClick()
    end)
    self.instructionBtn:regOnButtonClick(function()
        self:OnBtnInstructionClick()
    end)
    self.scheduleBtn:regOnButtonClick(function()
        self:OnBtnScheduleBtnClick()
    end)
end

function MistFightView:InitView(guildMistWarMainModel)
    self.model = guildMistWarMainModel
    local settlementInfo = self.model:GetSettlementInfo()
    if next(settlementInfo) and (not settlementInfo.hasShow) then
        res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarRoundSettlementCtrl", settlementInfo)
        settlementInfo.hasShow = true
    end
end

function MistFightView:RefreshAttack(guildMistWarMainModel)
    self:InitView(guildMistWarMainModel)
    local attackGuildInfo =  self.model:GetAttackGuildInfo()
    local attackPeriod =  self.model:GetAttackPeriod()
    local attackRound =  self.model:GetAttackRound()
    local attackOccupyCount =  self.model:GetAttackOccupyCount()
    local defendAmount =  self.model:GetDefendAmount()
    local attackWarCnt =  self.model:GetAttackWarCnt()
    local attackCountLimit =  self.model:GetAttackCountLimit()
    local totalScore =  self.model:GetAttackTotalScore()
    local mistLevel = self.model:GetFightMinLevel()

    local remainCount = attackCountLimit - attackWarCnt
    local logoName = "GuildLogo" .. attackGuildInfo.eid
    local periodStr = lang.transstr("guildwar_period2", attackPeriod)
    local levelStr = lang.transstr("number_".. mistLevel)

    periodStr = periodStr .. lang.transstr("round_num", attackRound)
    levelStr = lang.transstr("floor_order", levelStr)

    self.attackPeriodTxt.text =  periodStr
    self.attackScoreTxt.text =  tostring(totalScore)
    self.attackGuildNameTxt.text = attackGuildInfo.name
    self.attackOccupyCountTxt.text = attackOccupyCount .. "/" .. defendAmount
    self.attackRemainCountTxt.text = lang.transstr("untranslated_2559") .. ":" .. remainCount
    self.mistAtkTitleTxt.text = lang.transstr("guild_mist_attack") .. levelStr
    self.attackIconImg.overrideSprite = AssetFinder.GetGuildIcon(logoName)

    self:RefreshAttackBuff()
    self:RefreshAttackTimer()

    GameObjectHelper.FastSetActive(self.attackGo, true)
    GameObjectHelper.FastSetActive(self.defenderGo, false)
    self.buttonTrans.localPosition = self.attackBtnPos
    EventSystem.SendEvent("GuildWarMist_SetMapPos", false)
end

-- 刷新防守进攻图标
function MistFightView:RefreshAttackBuff()
    local attackBuffStr =  self.model:GetAttackBuffStr()
    GameObjectHelper.FastSetActive(self.attackBuffGo, tobool(attackBuffStr))
    if attackBuffStr then
        self.attackBuffTxt.text = attackBuffStr
    end
end

function MistFightView:RefreshDefender(guildMistWarMainModel)
    self:InitView(guildMistWarMainModel)

    local defenderGuildInfo =  self.model:GetDefenderGuildInfo()
    local defenderPeriod =  self.model:GetDefenderPeriod()
    local defenderRound =  self.model:GetDefenderRound()
    local defenderOccupyCount =  self.model:GetDefenderOccupyCount()
    local defendAmount =  self.model:GetDefendAmount()
    local logoName = "GuildLogo" .. defenderGuildInfo.eid
    local periodStr = lang.transstr("guildwar_period2", defenderPeriod)
    local totalScore =  self.model:GetDefTotalScore()
    local mistLevel = self.model:GetFightMinLevel()
    local levelStr = lang.transstr("number_" .. mistLevel)

    periodStr = periodStr .. lang.transstr("round_num", defenderRound)
    levelStr = lang.transstr("floor_order", levelStr)

    self.defenderPeriodTxt.text =  periodStr
    self.defenderScoreTxt.text =  tostring(totalScore)
    self.defenderGuildNameTxt.text = defenderGuildInfo.name
    self.defenderOccupyCountTxt.text = defenderOccupyCount .. "/" .. defendAmount
    self.mistDefTitleTxt.text = lang.transstr("guild_mist_defender") .. levelStr

    self.defenderIconImg.overrideSprite = AssetFinder.GetGuildIcon(logoName)

    self:RefreshDefenderBuff()
    self:RefreshDefenderTimer()

    GameObjectHelper.FastSetActive(self.attackGo, false)
    GameObjectHelper.FastSetActive(self.defenderGo, true)
    self.buttonTrans.localPosition = self.defendBtnPos
    EventSystem.SendEvent("GuildWarMist_SetMapPos", true)
end

-- 刷新防守buff图标
function MistFightView:RefreshDefenderBuff()
    local defenderBuffStr =  self.model:GetDefenderBuffStr()

    GameObjectHelper.FastSetActive(self.defenderBuffGo, tobool(defenderBuffStr))
    if defenderBuffStr then
        self.defenderBuffTxt.text = defenderBuffStr
    end
end

function MistFightView:RefreshTime(duringTip, endTip)
    local remainTime = self.model:GetRemainTime()
    if remainTime < 1 then
        self.remainTimeTxt.text = lang.trans(endTip)
        return
    end
    if self.endTimer then
        self.endTimer:Destroy()
        self.endTimer = nil
    end
    self.endTimer = Timer.new(remainTime, function(time)
        self.remainTimeTxt.text = lang.trans(duringTip, string.convertSecondToTime(time))
    end, function()
        if self.remainTimeTxt then
            self.remainTimeTxt.text = lang.trans(endTip)
            EventSystem.SendEvent("GuildMistWarMainCtrl_Refresh")
        end
    end)
end

function MistFightView:OnBtnDefenderDetailClick()
    if self.onBtnRegisterClick ~= nil and type(self.onBtnRegisterClick) == "function" then
        self.onBtnRegisterClick()
    end
end

function MistFightView:OnBtnAttackDetailClick()
    if self.onBtnAttackDetailClick ~= nil and type(self.onBtnAttackDetailClick) == "function" then
        self.onBtnAttackDetailClick()
    end
end

function MistFightView:OnBtnToDefendClick()
    if self.onBtnToDefendClick ~= nil and type(self.onBtnToDefendClick) == "function" then
        self.onBtnToDefendClick()
    end
end

function MistFightView:OnBtnToAttackClick()
    if self.onBtnToAttackClick ~= nil and type(self.onBtnToAttackClick) == "function" then
        self.onBtnToAttackClick()
    end
end

function MistFightView:OnBtnAttackBuffStoreClick()
    res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarBuffStoreCtrl", self.model)
end

function MistFightView:OnBtnDefendBuffStoreClick()
    res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarBuffStoreCtrl", self.model)
end

function MistFightView:OnBtnMyDataClick()
    local isFirst = self.model:IsFirst()
    if isFirst then
        DialogManager.ShowToastByLang("mist_history_close")
    else
        res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarMyDataCtrl")
    end
end

function MistFightView:OnBtnInstructionClick()
    local state = self.model:GetWarState()
    local round = self.model:GetRound()
    res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarDescCtrl", state, round)
end

function MistFightView:OnBtnScheduleBtnClick()
    self:coroutine(function ()
        local response = req.guildWarScheduleInfoMist()
        if api.success(response) then
            local data = response.val
            res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistDataShowCtrl", self.model, data)
        end
    end)
end

function MistFightView:RefreshAttackTimer()
    local attackRemainTime =  self.model:GetAttackRemainTime()
    if self.endTimer then
        self.endTimer:Destroy()
        self.endTimer = nil
    end
    if attackRemainTime < 1 then
        self.remainTimeTxt.text = lang.trans("belatedGift_item_nil_time")
        return
    end

    self.endTimer = Timer.new(attackRemainTime, function(time)
        if time < 1 then
            self.attackRemainTimeTxt.text = lang.trans("belatedGift_item_nil_time")
            return
        end
        self.attackRemainTimeTxt.text = string.convertSecondToTime(time)
    end)
end

function MistFightView:RefreshDefenderTimer()
    local defenderRemainTime =  self.model:GetDefenderRemainTime()
    if self.endTimer then
        self.endTimer:Destroy()
        self.endTimer = nil
    end
    if defenderRemainTime < 1 then
        self.defenderRemainTimeTxt.text = lang.trans("belatedGift_item_nil_time")
        return
    end

    self.endTimer = Timer.new(defenderRemainTime, function(time)
        if time < 1 then
            self.defenderRemainTimeTxt.text = lang.trans("belatedGift_item_nil_time")
            return
        end
        self.defenderRemainTimeTxt.text = string.convertSecondToTime(time)
    end)
end

function MistFightView:UpdateBuff(buff)
    if self.model then
        self.model:SetBuff(buff)
        self:RefreshAttackBuff()
        self:RefreshDefenderBuff()
    end
end

function MistFightView:OnEnterScene()
    EventSystem.AddEvent("GuildMistWarMainModel_UpdateGuardData", self, self.RefreshAttack)
    EventSystem.AddEvent("GuildMistWarMainModel_UpdateBuff", self, self.UpdateBuff)
end

function MistFightView:OnExitScene()
    EventSystem.RemoveEvent("GuildMistWarMainModel_UpdateGuardData", self, self.RefreshAttack)
    EventSystem.RemoveEvent("GuildMistWarMainModel_UpdateBuff", self, self.UpdateBuff)
    if self.endTimer then
        self.endTimer:Destroy()
        self.endTimer = nil
    end
end

return MistFightView
