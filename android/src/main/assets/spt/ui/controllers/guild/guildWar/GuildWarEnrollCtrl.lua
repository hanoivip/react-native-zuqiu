local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildWarEnrollModel = require("ui.models.guild.guildWar.GuildWarEnrollModel")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildWarGuardCtrl = require("ui.controllers.guild.guildWar.GuildWarGuardCtrl")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")

local GuildWarEnrollCtrl = class(BaseCtrl)

GuildWarEnrollCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildWarEnroll.prefab"

function GuildWarEnrollCtrl:Init()
    self.guildWarGuardCtrl = GuildWarGuardCtrl.new()
    self.guildWarEnrollModel = GuildWarEnrollModel.new()

    self.view.AddLevel = function()
        self.guildWarEnrollModel:AddCurrLevel()
        self:SetLevel()
    end

    self.view.MinusLevel = function()
        self.guildWarEnrollModel:MinusCurrLevel()
        self:SetLevel()
    end

    self.view.OnBtnEnrollClick = function()
        local level = self.guildWarEnrollModel:GetCurrLevel()
        local content = { }
        content.title = lang.trans("guildwar_EnrollTitle")
        content.content = lang.trans("guildwar_EnrollContent", level)
        content.button1Text = lang.trans("cancel")
        content.button2Text = lang.trans("confirm")
        content.onButton2Clicked = function()
            clr.coroutine(function()
            local respone = req.guildWarSign(level)
            if api.success(respone) then
                local data = respone.val
                self.guildWarEnrollModel:SetState(GUILDWAR_STATE.SIGNED)
                self.guildWarEnrollModel:SetLeftTime(data.remainTime)
                self.guildWarEnrollModel:SetSignLevel(level)
                self.view:InitView(self.guildWarEnrollModel)
                self:SetLevel()
                luaevt.trig("SDK_Report", "guildWar_signup", level)
            end
        end)   
        end
        local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/GeneralBox.prefab',"camera", true, true)
        dialogcomp.contentcomp:initData(content)
    end

    --公会战说明
    self.view.OnBtnInstructionClick = function()
        res.PushDialog("ui.controllers.guild.guildWar.GuildWarDescCtrl", self.guildWarEnrollModel:GetState(), nil)
    end

    --往期数据
    self.view.OnBtnHistoryClick = function()
        local isFirst = self.guildWarEnrollModel:GetIsFirst()
        if isFirst == true then
            DialogManager.ShowToastByLang("guildwar_noData")
            return
        end
        clr.coroutine(function ()
            local response = req.scheduleInfo()
            if api.success(response) then
                data = response.val
                res.PushDialog("ui.controllers.guild.guildWar.GuildDataShowCtrl", self.guildWarEnrollModel, data)
            end
        end)
    end

    --公会战赛程
    self.view.OnBtnScheduleClick = function()
        local isFirst = self.guildWarEnrollModel:GetIsFirst()
        if isFirst == true then
            DialogManager.ShowToastByLang("guildwar_noData")
            return
        end
        clr.coroutine(function ()
            local response = req.scheduleInfo()
            if api.success(response) then
                data = response.val
                res.PushDialog("ui.controllers.guild.guildWar.GuildDataShowCtrl", self.guildWarEnrollModel, data)
            end
        end)
    end

    --我的数据
    self.view.OnBtnMyDataClick = function()
        local isFirst = self.guildWarEnrollModel:GetIsFirst()
        if isFirst == true then
            DialogManager.ShowToastByLang("guildwar_noData")
            return
        end
        res.PushDialog("ui.controllers.guild.guildWar.GuildWarMyDataCtrl")
    end
end

function GuildWarEnrollCtrl:Refresh(serverData, guildWarGuardCtrl, guildWarEnrollModel)
    GuildWarEnrollCtrl.super.Refresh(self)
    if guildWarGuardCtrl then
        self.guildWarGuardCtrl = guildWarGuardCtrl
    end
    self.serverData = serverData
    self.guildWarGuardCtrl:Init(self.view.guardPosition, self.GuardItemClickFunc, self)
    self.guildWarEnrollModel = guildWarEnrollModel or self.guildWarEnrollModel.new(self.guildWarGuardCtrl.guildWarGuardModel)
    self.guildWarEnrollModel:InitWithProtrol(serverData)
    self:InitView()
    self:ShowSettlementInfo()
end

function GuildWarEnrollCtrl:GetStatusData()
    return self.serverData, self.guildWarGuardCtrl, self.guildWarEnrollModel
end

function GuildWarEnrollCtrl:InitView()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.view:InitView(self.guildWarEnrollModel)
    self:SetLevel()
    self:SetGuardPosition()
end

function GuildWarEnrollCtrl:ShowSettlementInfo()
    local settlementInfo = self.guildWarEnrollModel:GetSettlementInfo()
    if settlementInfo.hasShow == false then
        clr.coroutine(function()
            coroutine.yield(clr.UnityEngine.WaitForSeconds(0.5))
            res.PushDialog("ui.controllers.guild.guildWar.GuildWarSettlementCtrl", settlementInfo)
        end)
        settlementInfo.hasShow = true
    end
end

function GuildWarEnrollCtrl:SetLevel()
    local level = self.guildWarEnrollModel:GetCurrLevel()
    local minLevel = self.guildWarEnrollModel:GetMinLevel()
    local maxLevel = self.guildWarEnrollModel:GetMaxLevel()
    local openMaxLevel = self.guildWarEnrollModel:GetOpenMaxLevel()

    if level == minLevel then
        self.view:SetLeftButtonIcon(true)
        self.view:SetRightButtonIcon(false)
    elseif level == maxLevel then
        self.view:SetLeftButtonIcon(false)
        self.view:SetRightButtonIcon(true)
    else
        self.view:SetLeftButtonIcon(false)
        self.view:SetRightButtonIcon(false)
    end
    self.view:SetLevelText(level, openMaxLevel)
    luaevt.trig("SDK_Report", "af_guildwar", maxLevel)
end

function GuildWarEnrollCtrl.GuardItemClickFunc(self, index)
    local guardData = self.guildWarEnrollModel:GetGuardPosition(index)
    res.PushDialog("ui.controllers.guild.guildWar.GuildWarGuardDetailCtrl", guardData, self.guildWarEnrollModel)
end

function GuildWarEnrollCtrl:SetGuardPosition()
    self.guildWarGuardCtrl:SetGuardPosition()
end

function GuildWarEnrollCtrl:OnEnterScene()
end

function GuildWarEnrollCtrl:OnExitScene()
    self.guildWarGuardCtrl:RemoveEventSystem()
end

return GuildWarEnrollCtrl
