local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildWarAttackModel = require("ui.models.guild.guildWar.GuildWarAttackModel")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildWarGuardCtrl = require("ui.controllers.guild.guildWar.GuildWarGuardCtrl")
local SelfDetailBattleCtrl = require("ui.controllers.guild.guildWar.SelfDetailBattleCtrl")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")

local GuildWarAttackCtrl = class(BaseCtrl)

GuildWarAttackCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildWarAttack.prefab"

function GuildWarAttackCtrl:Init()
    self.guildWarGuardCtrl = GuildWarGuardCtrl.new() 
    self.guildWarAttackModel = GuildWarAttackModel.new()

    --公会战说明
    self.view.OnBtnInstructionClick = function()
        res.PushDialog("ui.controllers.guild.guildWar.GuildWarDescCtrl", self.guildWarAttackModel:GetState(), 
            self.guildWarAttackModel:GetRound())
    end

    --公会战赛程
    self.view.OnBtnScheduleClick = function()
        clr.coroutine(function ()
            local response = req.scheduleInfo()
            if api.success(response) then
                data = response.val
                res.PushDialog("ui.controllers.guild.guildWar.GuildDataShowCtrl", self.guildWarAttackModel, data)
            end
        end)
    end

    --我方详细战况
    self.view.OnBtnDetailClick = function()
        res.PushDialog("ui.controllers.guild.guildWar.SelfDetailBattleCtrl")
    end

    --Buff商店
    self.view.OnBtnShopClick = function()
        local isAttackBuff = true
        res.PushDialog("ui.controllers.guild.guildWar.GuildBuffStoreCtrl", self.guildWarAttackModel, isAttackBuff)
    end

    --我的数据
    self.view.OnBtnMyDataClick = function()
        res.PushDialog("ui.controllers.guild.guildWar.GuildWarMyDataCtrl")
    end

    self.view.OnBtnArrowClick = function()
        res.PushScene("ui.controllers.guild.guildWar.GuildWarDefenceCtrl", clone(self.guildData))
    end

    self.view.OnBtnLogoClick = function()
        clr.coroutine(function()
            local respone = req.GuildDetail(self.guildWarAttackModel:GetDefenseGuildGid())
            if api.success(respone) then
                local data = respone.val
                if data.base.isExsit == true then
                    res.PushDialog("ui.controllers.guild.GuildDetailCtrl", data.base)
                end
            end
        end)
    end

    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self:BackToGuildHome()
        end)
    end)
end

function GuildWarAttackCtrl:Refresh(guildData, guildWarGuardCtrl, guildWarAttackModel)
    GuildWarAttackCtrl.super.Refresh(self)
    self:InitView(guildData, guildWarGuardCtrl, guildWarAttackModel)
end

function GuildWarAttackCtrl:GetStatusData()
    return self.guildData, self.guildWarGuardCtrl, self.guildWarAttackModel
end

function GuildWarAttackCtrl:ShowSettlementInfo()
    local settlementInfo = self.guildWarAttackModel:GetSettlementInfo()
    if settlementInfo and settlementInfo.hasShow == false then
        res.PushDialog("ui.controllers.guild.guildWar.GuildWarRoundSettlementCtrl", settlementInfo)
        settlementInfo.hasShow = true
    end
end

function GuildWarAttackCtrl:InitView(guildData, guildWarGuardCtrl, guildWarAttackModel)
    self.view.guardPosition.gameObject:SetActive(false)
    self.view.guildLogo.gameObject:SetActive(false)
    
    clr.coroutine(function()
        local respone = req.getGuildWarAttackInfo()
        if api.success(respone) then
            local data = respone.val
            if guildWarGuardCtrl then
                self.guildWarGuardCtrl = guildWarGuardCtrl
            end
            self.guildData = guildData
            self.guildWarGuardCtrl:Init(self.view.guardPosition, self.GuardItemClickFunc, self)
            self.guildWarAttackModel = guildWarAttackModel or self.guildWarAttackModel.new(self.guildWarGuardCtrl.guildWarGuardModel)
            self.guildWarAttackModel:InitWithProtrol(guildData, data)
            self.guildWarGuardCtrl:HideGuardPosition()
            self:ShowSettlementInfo()
            self.view.guildLogo.gameObject:SetActive(true)
            self.view.guardPosition.gameObject:SetActive(true)
            self:SetGuardPosition()
            self.view:InitView(self.guildWarAttackModel)
        end
    end)

end

function GuildWarAttackCtrl.GuardItemClickFunc(self, index)
    local isAttackPage = true
    res.PushDialog("ui.controllers.guild.guildWar.OurPartSeatsDetailCtrl", index, self.guildWarAttackModel, isAttackPage)
end

function GuildWarAttackCtrl:SetGuardPosition()
    self.guildWarGuardCtrl:SetGuardPosition()
end

function GuildWarAttackCtrl:BackToGuildHome()
    clr.coroutine(function()
        local respone = req.guildIndex()
        if api.success(respone) then
            local data = respone.val
            if data.base.isExsit == true then
                res.PushScene("ui.controllers.guild.GuildHomeCtrl", data) 
            else
                res.PushScene("ui.controllers.guild.GuildJoinCtrl")
            end
        end
    end)
end

function GuildWarAttackCtrl:RefreshAttackView()
    self:InitView(self.guildData, self.guildWarGuardCtrl, self.guildWarAttackModel)
end

function GuildWarAttackCtrl:OnEnterScene()
    EventSystem.AddEvent("GuildWarAttackView_Refresh", self, self.RefreshAttackView)
end

function GuildWarAttackCtrl:OnExitScene()
    self.guildWarGuardCtrl:RemoveEventSystem()
    EventSystem.RemoveEvent("GuildWarAttackView_Refresh", self, self.RefreshAttackView)
end

return GuildWarAttackCtrl
