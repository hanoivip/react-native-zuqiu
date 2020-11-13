local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildSettingModel = require("ui.models.guild.GuildSettingModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local UnityEngine = clr.UnityEngine

local GuildSettingCtrl = class(BaseCtrl)

GuildSettingCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildSetting.prefab"

function GuildSettingCtrl:Init()
    self.guildSettingModel = GuildSettingModel.new()

    self.view.chooseIconFunc = function()
        self.view:InitScrollerView(self.guildSettingModel:GetIconInfo())
        self.view:PlayShowAnimation()
        EventSystem.SendEvent("Guild_LogoItemClick", self.guildSettingModel:GetCurrentIndex())
    end

    self.view.onBtnCancelClick = function()
        self.guildSettingModel:SetChooseIndex(self.guildSettingModel:GetCurrentIndex())
        self:InitIconView()
        self.view:PlayLeaveAnimation()
        self:UpdateSettingButton()
    end

    self.view.onBtnComfirmClick = function()
        self.guildSettingModel:SetCurrentIndex(self.guildSettingModel:GetChooseIndex())
        self:InitIconView()
        self.view:PlayLeaveAnimation()
        self:UpdateSettingButton()
    end

    self.view.AddRequestLevel = function()
        self.guildSettingModel:AddRequestLevel()
        self:SetReqLevel()
        self:UpdateSettingButton()
    end

    self.view.MinusRequestLevel = function()
        self.guildSettingModel:MinusRequestLevel()
        self:SetReqLevel()
        self:UpdateSettingButton()
    end

    self.view.onBtnChooseRightType = function()
        self.guildSettingModel:SetRequestTypeAuto()
        self:SetReqType()
        self:UpdateSettingButton()
    end

    self.view.onBtnChooseLeftType = function()
        self.guildSettingModel:SetRequestTypeNotAuto()
        self:SetReqType()
        self:UpdateSettingButton()
    end

    self.view.isInvitationNewPlayer = function(isLeft)
        self.guildSettingModel:SetInvitationNewPlayerType(isLeft)
        self:SetInvitationType()
        self:UpdateSettingButton()
    end

    self.view.onBtnChangeNameClick = function()
        local name = self.view:GetNameText()
        local oldName = self.guildSettingModel:GetGuildName()
        local costDiamond = self.guildSettingModel:GetPrice()

        if self.guildSettingModel:GetChangeNameCoolDown() then
            DialogManager.ShowToastByLang("guild_nameCoolDown")
        elseif oldName == name then
            DialogManager.ShowToastByLang("guild_nameNotChange")
        else
            DialogManager.ShowConfirmPop(lang.transstr("guild_changeNameTitle"), lang.transstr("guild_changeName"), function()
                CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
                    clr.coroutine(function()
                        local respone = req.GuildChangeName(name)
                        if api.success(respone) then
                            local data = respone.val
                            if type(data.cost) == "table" then
                                if data.cost["type"] == "d" then
                                    local playerInfoModel = PlayerInfoModel.new()
                                    playerInfoModel:AddDiamond(-1 * data.cost.num)
                                    local consumeType = 3
                                    local mInfo = {}
                                    mInfo.phylum = "guild"
                                    mInfo.classfield = "changeName"
                                    CustomEvent.ConsumeDiamond(consumeType, tonumber(data.cost.num), mInfo)
                                end
                            end
                            self.guildSettingModel:SetGuildName(data.base.name)
                            EventSystem.SendEvent("GuildSetting_Success", data.base)
                            DialogManager.ShowToastByLang("guild_settingSuccess")
                        end
                    end)
                end)
            end)
        end
    end

    self.view.onBtnSettingClick = function()
        local oldName = self.guildSettingModel:GetGuildName()
        local eid = self.guildSettingModel:GetCurrentIndex()
        local notice = self.view:GetNoticeText()
        local reqType = self.guildSettingModel:GetRequestType()
        local inviteType = self.guildSettingModel:GetInvitationNewPlayerType()
        local reqLevel = self.guildSettingModel:GetRequestLevel()
        local costDiamond = 0
        CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
            clr.coroutine(function()
                local respone = req.GuildSetting(oldName, eid, notice, reqType, reqLevel, inviteType)
                if api.success(respone) then
                    local data = respone.val
                    if type(data.cost) == "table" then
                        if data.cost["type"] == "d" then
                            local playerInfoModel = PlayerInfoModel.new()
                            playerInfoModel:AddDiamond(-1 * data.cost.num)
                            local consumeType = 3
                            local mInfo = {}
                            mInfo.phylum = "guild"
                            mInfo.classfield = "guildSetting"
                            CustomEvent.ConsumeDiamond(consumeType, tonumber(data.cost.num), mInfo)
                        end
                    end
                    EventSystem.SendEvent("GuildSetting_Success", data.base)
                    DialogManager.ShowToastByLang("guild_settingSuccess")
                    self.view:Close()
                end
            end)
        end)
    end

    self.view.onNoticeInputValueChanged = function(value)
        self:UpdateSettingButton()
    end
end

function GuildSettingCtrl:Refresh(data)
    GuildSettingCtrl.super.Refresh(self)
    self.baseData = data
    self.guildSettingModel:InitWithProtocal(data)
    self:InitGuildName()
    self:InitGuildNotice()
    self:InitIconView()
    self:SetReqLevel()
    self:SetReqType()
    self:SetInvitationType()
    self:UpdateSettingButton()
end

function GuildSettingCtrl:InitGuildName()
    local name = self.guildSettingModel:GetGuildName()
    self.view:InitGuildName(name)
end

function GuildSettingCtrl:InitGuildNotice()
    local notice = self.guildSettingModel:GetGuildNotice()
    self.view:InitGuildNotice(notice)
end

function GuildSettingCtrl:SetReqLevel()
    local level = self.guildSettingModel:GetRequestLevel()
    if level == self.guildSettingModel:GetMaxRequestLevel() then
        self.view:SetReqBtnIcon(self.view.reqLevelRightBtnIcon, true)
    elseif level == self.guildSettingModel:GetMinRequestLevel() then
        self.view:SetReqBtnIcon(self.view.reqLevelLeftBtnIcon, true)
    else
        self.view:SetReqBtnIcon(self.view.reqLevelRightBtnIcon, false)
        self.view:SetReqBtnIcon(self.view.reqLevelLeftBtnIcon, false)
    end
    self.view:SetReqLevelText(tostring(level))
end

function GuildSettingCtrl:SetReqType()
    local type = self.guildSettingModel:GetRequestType()
    if type == self.guildSettingModel:GetAutoRequestType() then
        self.view:SetReqBtnIcon(self.view.reqTypeLeftBtnIcon, false)
        self.view:SetReqBtnIcon(self.view.reqTypeRightBtnIcon, true)
    else
        self.view:SetReqBtnIcon(self.view.reqTypeLeftBtnIcon, true)
        self.view:SetReqBtnIcon(self.view.reqTypeRightBtnIcon, false)
    end
    self.view:SetReqTypeText(self.guildSettingModel:GetRequestTypeStr())
end

function GuildSettingCtrl:SetInvitationType()
    local type = self.guildSettingModel:GetIsInvitationLeftType()
    self.view:SetReqBtnIcon(self.view.inviteTypeLeftBtnIcon, type)
    self.view:SetReqBtnIcon(self.view.inviteTypeRightBtnIcon, not type)
    self.view:SetInviteTypeText(type and lang.transstr("pd_guild_invite_new_player2") or lang.transstr("pd_guild_invite_new_player1"))
end

function GuildSettingCtrl:InitIconView()
    self.view:InitIconImg(self.guildSettingModel:GetChooseIndex())
end

function GuildSettingCtrl:EventLogoItemClick(index)
    self.guildSettingModel:SetChooseIndex(index)
end

function GuildSettingCtrl:OnEnterScene()
    EventSystem.AddEvent("Guild_LogoItemClick", self, self.EventLogoItemClick)
end

function GuildSettingCtrl:OnExitScene()
    EventSystem.RemoveEvent("Guild_LogoItemClick", self, self.EventLogoItemClick)
end

function GuildSettingCtrl:UpdateSettingButton()
    local eid = self.guildSettingModel:GetCurrentIndex()
    local notice = self.view:GetNoticeText()
    local reqType = self.guildSettingModel:GetRequestType()
    local inviteType = self.guildSettingModel:GetInvitationNewPlayerType()
    local reqLevel = self.guildSettingModel:GetRequestLevel()
    
    if self.baseData.eid ~= eid or self.baseData.msg ~= notice or self.baseData.requestAcceptType ~= reqType or self.baseData.minPlayerLvl ~= reqLevel or self.baseData.autoInviteNewPlayer ~= inviteType then
        self.view:SetSettingButtonState(true)
    else
        self.view:SetSettingButtonState(false)
    end
end

return GuildSettingCtrl