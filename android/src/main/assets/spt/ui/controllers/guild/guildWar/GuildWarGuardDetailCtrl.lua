local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildWarGuardDetailModel = require("ui.models.guild.guildWar.GuildWarGuardDetailModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildWarGuardDetailCtrl = class(BaseCtrl)

GuildWarGuardDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildWarGuardDetail.prefab"

function GuildWarGuardDetailCtrl:AheadRequest(guardData, guildWarModel)
    self.guildWarModel = guildWarModel
    self.guardData = guardData
    local response = req.getGuildMemberInfo()
    if api.success(response) then
        local data = response.val
        self.guildWarGuardDetailModel = GuildWarGuardDetailModel.new()
        self.guildWarGuardDetailModel:InitWithProtrol(guardData, data)
    end
end

function GuildWarGuardDetailCtrl:Init()
    self.view.onItemBtnPlaceClick = function(pid)
        self:OnItemBtnPlaceClick(pid)
    end

    self.view.onItemBtnChangeClick = function(pid)
        self:OnItemBtnChangeClick(pid)
    end
end

function GuildWarGuardDetailCtrl:Refresh(guardData, guildWarModel)
    dump(guardData, "guardData")
    GuildWarGuardDetailCtrl.super.Refresh(self)
    self.guildWarModel = guildWarModel
    self.guardData = guardData
    self:InitView()
end

function GuildWarGuardDetailCtrl:GetStatusData()
    return self.guardData, self.guildWarModel
end

function GuildWarGuardDetailCtrl:InitView()
    self.view:InitView(self.guildWarGuardDetailModel)
end

function GuildWarGuardDetailCtrl:OnItemBtnPlaceClick(pid)
    clr.coroutine(function()
        local index = self.guildWarGuardDetailModel:GetGuardData().index
        local response = req.deployGuard(index, pid)
        if api.success(response) then
            local data = response.val
            self.guildWarModel:SetGuardList(data.guards)
            local name = data.guards[tostring(index)].name
            self.guildWarGuardDetailModel:SetCurrentMember(name, data.guards)
            self:InitView()
        end
    end)
end

function GuildWarGuardDetailCtrl:OnItemBtnChangeClick(pid)
    clr.coroutine(function()
        local index = self.guildWarGuardDetailModel:GetGuardData().index
        local response = req.deployGuard(index, pid)
        if api.success(response) then
            local data = response.val
            self.guildWarModel:SetGuardList(data.guards)
            local name = data.guards[tostring(index)].name
            self.guildWarGuardDetailModel:SetCurrentMember(name, data.guards)
            self:InitView()
        end
    end)
end

function GuildWarGuardDetailCtrl:OnEnterScene()

end

function GuildWarGuardDetailCtrl:OnExitScene()

end

return GuildWarGuardDetailCtrl