local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildAuthority = require("data.GuildAuthority")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildMistWarGuardDetailModel = require("ui.models.guild.guildMistWar.GuildMistWarGuardDetailModel")

local GuildMistWarGuardDetailCtrl = class(BaseCtrl)

GuildMistWarGuardDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarGuardDetail.prefab"

function GuildMistWarGuardDetailCtrl:AheadRequest(guardData, mistMapModel)
    self.mistMapModel = mistMapModel
    self.guardData = guardData
    local round = mistMapModel:GetRound()
    local response = req.guildWarMemberInfoMist(round)
    if api.success(response) then
        local data = response.val
        self.model = GuildMistWarGuardDetailModel.new()
        self.model:InitWithProtocol(guardData, data)
    end
end

function GuildMistWarGuardDetailCtrl:Init()
    GuildMistWarGuardDetailCtrl.super.Init(self)
    self.view.onItemBtnPlaceClick = function(pid)
        self:OnItemBtnPlaceClick(pid)
    end

    self.view.onItemBtnChangeClick = function(pid)
        self:OnItemBtnChangeClick(pid)
    end
end

function GuildMistWarGuardDetailCtrl:Refresh(guardData, mistMapModel)
    GuildMistWarGuardDetailCtrl.super.Refresh(self)
    self.mistMapModel = mistMapModel
    self.guardData = guardData
    self:InitView()
end

function GuildMistWarGuardDetailCtrl:GetStatusData()
    return self.guardData, self.mistMapModel
end

function GuildMistWarGuardDetailCtrl:InitView()
    self.view:InitView(self.model)
end

function GuildMistWarGuardDetailCtrl:OnItemBtnPlaceClick(pid)
    local authority = self.mistMapModel:GetAuthority()
    authority = tostring(authority)
    local authorityState = GuildAuthority[authority].guardRight == 1
    if not authorityState then
        DialogManager.ShowToastByLang("mist_authority_none")
        return
    end
    local round = self.mistMapModel:GetRound()
    local round = self.mistMapModel:GetRound()
    self.view:coroutine(function()
        local index = self.model:GetGuardData().index
        local response = req.guildWarDeployMist(index, pid, round)
        if api.success(response) then
            local data = response.val
            self.mistMapModel:SetGuardList(data.guards)
            local name = data.guards[tostring(index)].name
            self.model:SetCurrentMember(name, data.guards)
            self:InitView()
        end
    end)
end

function GuildMistWarGuardDetailCtrl:OnItemBtnChangeClick(pid)
    local authority = self.mistMapModel:GetAuthority()
    authority = tostring(authority)
    local authorityState = GuildAuthority[authority].guardRight == 1
    if not authorityState then
        DialogManager.ShowToastByLang("mist_authority_none")
        return
    end
    local round = self.mistMapModel:GetRound()
    self.view:coroutine(function()
        local index = self.model:GetGuardData().index
        local response = req.guildWarDeployMist(index, pid, round)
        if api.success(response) then
            local data = response.val
            self.mistMapModel:SetGuardList(data.guards)
            local name = data.guards[tostring(index)].name
            self.model:SetCurrentMember(name, data.guards)
            self:InitView()
        end
    end)
end

return GuildMistWarGuardDetailCtrl