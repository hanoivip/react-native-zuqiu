local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildWarDefenceModel = require("ui.models.guild.guildWar.GuildWarDefenceModel")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildWarGuardCtrl = require("ui.controllers.guild.guildWar.GuildWarGuardCtrl")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")

local GuildWarDefenceCtrl = class(BaseCtrl)

GuildWarDefenceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildWarDefence.prefab"

function GuildWarDefenceCtrl:Init()
    self.guildWarDefenceModel = GuildWarDefenceModel.new()
    self.guildWarGuardCtrl = GuildWarGuardCtrl.new() 

    --公会战说明
    self.view.OnBtnInstructionClick = function()
        res.PushDialog("ui.controllers.guild.guildWar.GuildWarDescCtrl", self.guildWarDefenceModel:GetState(), 
            self.guildWarDefenceModel:GetRound())
    end

    --公会战赛程
    self.view.OnBtnScheduleClick = function()
        clr.coroutine(function ()
            local response = req.scheduleInfo()
            if api.success(response) then
                data = response.val
                res.PushDialog("ui.controllers.guild.guildWar.GuildDataShowCtrl", self.guildWarDefenceModel, data)
            end
        end)
    end

    --我方详细战况
    self.view.OnBtnDetailClick = function()
        res.PushDialog("ui.controllers.guild.guildWar.SelfDetailBattleCtrl")
    end

    --Buff商店
    self.view.OnBtnShopClick = function()
        local isAttackBuff = false
        res.PushDialog("ui.controllers.guild.guildWar.GuildBuffStoreCtrl", self.guildWarDefenceModel, isAttackBuff)
    end

    --我的数据
    self.view.OnBtnMyDataClick = function()
        res.PushDialog("ui.controllers.guild.guildWar.GuildWarMyDataCtrl")
    end

    self.view.OnBtnArrowClick = function()
        res.PushScene("ui.controllers.guild.guildWar.GuildWarAttackCtrl", clone(self.guildData))
    end

    self.view.OnBtnLogoClick = function()
        clr.coroutine(function()
            local respone = req.GuildDetail(self.guildWarDefenceModel:GetAttackGuildGid())
            if api.success(respone) then
                local data = respone.val
                if data.base.isExsit == true then
                    res.PushDialog("ui.controllers.guild.GuildDetailCtrl", data.base)
                end
            end
        end)
    end
end

function GuildWarDefenceCtrl:Refresh(guildData, guildWarGuardCtrl, guildWarDefenceModel)
    GuildWarDefenceCtrl.super.Refresh(self)
    self.view.guardPosition.gameObject:SetActive(false)
    self.view.guildLogo.gameObject:SetActive(false)

    clr.coroutine(function()
        local respone = req.getGuildWarDefenceInfo()
        if api.success(respone) then
            local data = respone.val
            if guildWarGuardCtrl then
                self.guildWarGuardCtrl = guildWarGuardCtrl
            end
            self.guildData = guildData
            self.guildWarGuardCtrl:Init(self.view.guardPosition, self.GuardItemClickFunc, self)    
            self.guildWarDefenceModel = guildWarDefenceModel or self.guildWarDefenceModel.new(self.guildWarGuardCtrl.guildWarGuardModel)
            self.guildWarDefenceModel:InitWithProtrol(guildData, data)
            self.guildWarGuardCtrl:HideGuardPosition()
            self:InitView()
        end
    end)
end

function GuildWarDefenceCtrl:GetStatusData()
    return self.guildData, self.guildWarGuardCtrl, self.guildWarDefenceModel
end

function GuildWarDefenceCtrl:InitView()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self:BackToGuildHome()
        end)
    end)
    self.view.guardPosition.gameObject:SetActive(true)
    self.view.guildLogo.gameObject:SetActive(true)
    self:SetGuardPosition()
    self.view:InitView(self.guildWarDefenceModel)
end

function GuildWarDefenceCtrl.GuardItemClickFunc(self, index)
    local isAttackPage = false
    res.PushDialog("ui.controllers.guild.guildWar.OurPartSeatsDetailCtrl", index, self.guildWarDefenceModel, isAttackPage)
end

function GuildWarDefenceCtrl:SetGuardPosition()
    self.guildWarGuardCtrl:SetGuardPosition()
end

function GuildWarDefenceCtrl:BackToGuildHome()
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

function GuildWarDefenceCtrl:OnEnterScene()
end

function GuildWarDefenceCtrl:OnExitScene()
    self.guildWarGuardCtrl:RemoveEventSystem()
end

return GuildWarDefenceCtrl
