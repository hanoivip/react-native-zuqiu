local Timer = require("ui.common.Timer")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local MistRegisterView = class(unity.base, "MistRegisterView")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")

function MistRegisterView:ctor()
--------Start_Auto_Generate--------
    self.registerSpt = self.___ex.registerSpt
    self.periodTxt = self.___ex.periodTxt
    self.rewardContentTxt = self.___ex.rewardContentTxt
    self.levelTxt = self.___ex.levelTxt
    self.scoreTxt = self.___ex.scoreTxt
    self.downTipTxt = self.___ex.downTipTxt
    self.buffStoreBtn = self.___ex.buffStoreBtn
    self.remainTimeTxt = self.___ex.remainTimeTxt
    self.registerBtn = self.___ex.registerBtn
    self.registerStateTxt = self.___ex.registerStateTxt
    self.previewMapBtn = self.___ex.previewMapBtn
    self.buttonsGo = self.___ex.buttonsGo
    self.myDataBtn = self.___ex.myDataBtn
    self.instructionBtn = self.___ex.instructionBtn
    self.scheduleBtn = self.___ex.scheduleBtn
    self.scheduleTxt = self.___ex.scheduleTxt
--------End_Auto_Generate----------
end

function MistRegisterView:start()
    self:RegBtnEvent()
end

function MistRegisterView:RegBtnEvent()
    self.registerBtn:regOnButtonClick(function()
        self:OnBtnRegisterClick()
    end)
    self.buffStoreBtn:regOnButtonClick(function()
        self:OnBtnBuffStoreClick()
    end)
    self.myDataBtn:regOnButtonClick(function()
        self:OnBtnMyDataClick()
    end)
    self.instructionBtn:regOnButtonClick(function()
        self:OnBtnInstructionClick()
    end)
    self.scheduleBtn:regOnButtonClick(function()
        self:OnBtnScheduleClick()
    end)
    self.previewMapBtn:regOnButtonClick(function()
        self:OnBtnPreviewMapClick()
    end)
end

function MistRegisterView:InitView(guildMistWarMainModel)
    self.model = guildMistWarMainModel
    local period = self.model:GetPeriod()
    local mistLevel = self.model:GetFightMinLevel()
    local score = self.model:GetTotalScore()
    local warState = self.model:GetWarState()
    local openMaxLevel = self.model:GetOpenMaxLevel()
    local periodStr = lang.transstr("guildwar_period2", period)
    self.periodTxt.text = periodStr .. lang.transstr("round_num", 1)
    self.levelTxt.text = tostring(mistLevel)
    self.scoreTxt.text = tostring(score)
    GameObjectHelper.FastSetActive(self.previewMapBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.buffStoreBtn.gameObject, warState == GUILDWAR_STATE.PREPARE)
    if warState == GUILDWAR_STATE.NOTSIGN or warState == GUILDWAR_STATE.PREFINISH then -- 未报名 或 上一期已结束
        self.registerStateTxt.text = lang.trans("regist")
        self:RefreshTime("guild_mist_tip1", "guild_mist_regist_end")
    elseif warState == GUILDWAR_STATE.SIGNED then -- 已报名
        self.registerStateTxt.text = lang.trans("guildwar_enrollBtn2")
        self:RefreshTime("guild_mist_tip3", "guild_mist_regist_end")
    elseif warState == GUILDWAR_STATE.GROUPING then -- 分组
        self.registerStateTxt.text = lang.trans("arena_be_allocation")
        self:StopTimer()
        self.remainTimeTxt.text = lang.trans("guild_mist_tip4")
    elseif warState == GUILDWAR_STATE.PREPARE then -- 准备战斗
        self.registerStateTxt.text = lang.trans("guild_mist_prepare")
        self:RefreshTime("guild_mist_tip5", "guild_mist_tip6")
        GameObjectHelper.FastSetActive(self.previewMapBtn.gameObject, false)
    end
    self.downTipTxt.text = lang.trans("guild_mist_down_tip", openMaxLevel)
    EventSystem.SendEvent("GuildWarMist_SetMapPos", true)

    local settlementInfo = self.model:GetSettlementInfo()
    if next(settlementInfo) and (not settlementInfo.hasShow) then
        clr.coroutine(function()
            coroutine.yield(clr.UnityEngine.WaitForSeconds(0.5))
            res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarSettlementCtrl", settlementInfo)
        end)
        settlementInfo.hasShow = true
    end
    self:SetHistoryOrScheduleTxt()
end

function MistRegisterView:SetHistoryOrScheduleTxt()
    local isFirst = self.model:IsFirst()
    if isFirst then
        self.scheduleTxt.text = lang.trans("guildwar_schedule")
        return
    end
    local warState = self.model:GetWarState()
    if warState == GUILDWAR_STATE.NOTSIGN or warState == GUILDWAR_STATE.PREFINISH then
        self.scheduleTxt.text = lang.trans("guildwar_history")
    elseif warState == GUILDWAR_STATE.SIGNED then -- 已报名
        self.scheduleTxt.text = lang.trans("guildwar_history")
    elseif warState == GUILDWAR_STATE.GROUPING then -- 分组
        self.scheduleTxt.text = lang.trans("guildwar_history")
    elseif warState == GUILDWAR_STATE.PREPARE then -- 准备战斗
        self.scheduleTxt.text = lang.trans("guildwar_schedule")
    end
end

function MistRegisterView:RefreshTime(duringTip, endTip)
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
        if time > 1 then
            self.remainTimeTxt.text = lang.trans(duringTip, string.convertSecondToTime(time))
        else
            self.remainTimeTxt.text = lang.trans(endTip)
            EventSystem.SendEvent("GuildMistWarMainCtrl_Refresh")
        end
    end)
end

-- 报名
function MistRegisterView:OnBtnRegisterClick()
    if self.onBtnRegisterClick ~= nil and type(self.onBtnRegisterClick) == "function" then
        self.onBtnRegisterClick()
    end
end

-- buff商店
function MistRegisterView:OnBtnBuffStoreClick()
    local round = self.model:GetRound()
    local storePath = "ui.controllers.guild.guildMistWar.GuildMistWarBuffStoreCtrl"
    res.PushDialog(storePath, self.model, round)
end

-- 历史赛季
function MistRegisterView:OnBtnMyDataClick()
    local isFirst = self.model:IsFirst()
    if isFirst then
        DialogManager.ShowToastByLang("guildwar_noData")
    else
        res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarMyDataCtrl")
    end
end

-- 说明
function MistRegisterView:OnBtnInstructionClick()
    local state = self.model:GetWarState()
    local round = self.model:GetRound()
    res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistWarDescCtrl", state, round)
end

-- 赛程
function MistRegisterView:OnBtnScheduleClick()
    local isFirst = self.model:IsFirst()
    if isFirst then
        DialogManager.ShowToastByLang("guildwar_noData")
        return
    end
    self:coroutine(function ()
        local response = req.guildWarScheduleInfoMist()
        if api.success(response) then
            local data = response.val
            if next(data.list) then
                res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistDataShowCtrl", self.model, data)
            else
                DialogManager.ShowToastByLang("mist_schedule_close")
            end
        end
    end)
end

-- 地图预览
function MistRegisterView:OnBtnPreviewMapClick()
    res.PushDialog("ui.controllers.guild.guildMistWar.GuildMistPreviewMapCtrl")
end

function MistRegisterView:OnEnterScene()
    self:RegEvent()
end

function MistRegisterView:OnExitScene()
    self:UnRegEvent()
    self:StopTimer()
end

function MistRegisterView:RegEvent()
end

function MistRegisterView:UnRegEvent()
end

function MistRegisterView:StopTimer()
    if self.endTimer then
        self.endTimer:Destroy()
        self.endTimer = nil
    end
end

return MistRegisterView
