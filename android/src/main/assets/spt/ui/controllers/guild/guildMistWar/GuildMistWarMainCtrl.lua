local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildAuthority = require("data.GuildAuthority")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildWarFightType = require("ui.models.guild.guildMistWar.GuildWarFightType")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")

local GuildMistWarMainModel = require("ui.models.guild.guildMistWar.GuildMistWarMainModel")

local GuildMistWarMainCtrl = class(BaseCtrl, "GuildMistWarMainCtrl")

GuildMistWarMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarMain.prefab"

function GuildMistWarMainCtrl:ctor()
    GuildMistWarMainCtrl.super.ctor(self)
end

function GuildMistWarMainCtrl:AheadRequest()
    local response = req.guildWarMistInfo()
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = GuildMistWarMainModel.new()
        end
        self.model:InitWithProtocol(data)
    end
end

function GuildMistWarMainCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.view.registerSpt.onBtnRegisterClick = function() self:OnBtnRegisterClick() end
    self.view.fightSpt.onBtnToAttackClick = function() self:OnBtnToAttackClick() end
    self.view.fightSpt.onBtnToDefendClick = function() self:OnBtnToDefendClick() end
    self.view.fightSpt.onBtnAttackDetailClick = function() self:OnBtnAttackDetailClick() end
    self.view.refreshFight = function(isDefender) self:RefreshFight(isDefender) end
end

function GuildMistWarMainCtrl:Refresh()
    GuildMistWarMainCtrl.super.Refresh(self)
    self.view:InitView(self.model)
end

-- 点击报名
function GuildMistWarMainCtrl:OnBtnRegisterClick()
    local authority = self.model:GetAuthority()
    authority = tostring(authority)
    local authorityState = GuildAuthority[authority].signWarRight == 1
    if not authorityState then
        DialogManager.ShowToastByLang("mist_authority_none")
        return
    end

    local warState = self.model:GetWarState()
    -- 在报名阶段 并且 有剩余时间
    if warState == GUILDWAR_STATE.NOTSIGN or warState == GUILDWAR_STATE.PREFINISH then -- 未报名 或 上一期已结束
        local remainTime = self.model:GetRemainTime()
        if remainTime > 1 then
            local level = self.model:GetLevel()
            self.view:coroutine(function()
                local response = req.guildWarSignMist(level)
                if api.success(response) then
                    local data = response.val
                    self.model:InitWithProtocol(data)
                    self.view:RefreshView()
                end
            end)
        end
    end
end

function GuildMistWarMainCtrl:OnBtnToAttackClick()
    self:RefreshFight(GuildWarFightType.Attack)
end

function GuildMistWarMainCtrl:OnBtnToDefendClick()
    self:RefreshFight(GuildWarFightType.Defend)
end

function GuildMistWarMainCtrl:OnBtnAttackDetailClick()
    res.PushDialog("ui.controllers.guild.guildMistWar.MistSelfDetailBattleCtrl", self.model)
end

function GuildMistWarMainCtrl:RefreshPage()
    self.view:coroutine(function()
        local response = req.guildWarMistInfo()
        if api.success(response) then
            local data = response.val
            self.model:InitWithProtocol(data)
            self.view:RefreshView()
        end
    end)
end

function GuildMistWarMainCtrl:RefreshFight(guildWarFightType)
    if guildWarFightType == GuildWarFightType.Defend then
        self:RefreshDefender()
    else
        self:RefreshAttack()
    end
end

function GuildMistWarMainCtrl:RefreshAttack()
    self.view:coroutine(function()
        local response = req.guildWarWarInfoMist()
        if api.success(response) then
            local data = response.val
            self.model:InitAttackWithProtocol(data)
            self.view:RefreshAttack()
        end
    end)
end

function GuildMistWarMainCtrl:RefreshDefender()
    self.view:coroutine(function()
        local response = req.guildWarGuardsInfoMist()
        if api.success(response) then
            local data = response.val
            self.model:InitDefenderWithProtocol(data)
            local mistMapModel = self.model:GetMistMapModel()
            -- 开始战斗后 防守方的显示要和进攻方的显示一样  但是在编辑界面要全部显示
            mistMapModel:SetIsDefender(false)
            self.view:RefreshDefender()
        end
    end)
end

function GuildMistWarMainCtrl:ShowSchedule()
    self.view:coroutine(function ()
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

function GuildMistWarMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("GuildMistWarMainCtrl_RefreshPage", self, self.RefreshPage)
    EventSystem.AddEvent("MistWar_ShowSchedule", self, self.ShowSchedule)
end

function GuildMistWarMainCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("GuildMistWarMainCtrl_RefreshPage", self, self.RefreshPage)
    EventSystem.RemoveEvent("MistWar_ShowSchedule", self, self.ShowSchedule)
end

return GuildMistWarMainCtrl
