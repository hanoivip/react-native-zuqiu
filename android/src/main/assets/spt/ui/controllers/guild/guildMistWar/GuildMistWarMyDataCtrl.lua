local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildMistWarMyDataModel = require("ui.models.guild.guildMistWar.GuildMistWarMyDataModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildMistWarMyDataCtrl = class(BaseCtrl)

GuildMistWarMyDataCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarMyData.prefab"

function GuildMistWarMyDataCtrl:Init()
    self.guildWarMyDataModel = GuildMistWarMyDataModel.new()

    self.view.onMenuItemClick = function(index)
        if index == self.guildWarMyDataModel:GetCurrentDate() then return end
        self.guildWarMyDataModel:SetCurrentDate(index)
        self:InitView()
    end
end

function GuildMistWarMyDataCtrl:Refresh()
    GuildMistWarMyDataCtrl.super.Refresh(self)
    clr.coroutine(function()
        local response = req.guildWarRecentGuildWarMist()
        if api.success(response) then
            local data = response.val
            self.guildWarMyDataModel:InitWithProtocol(data)
            self:InitView()
        end
    end)   
end

function GuildMistWarMyDataCtrl:InitView()
    self.view:InitView(self.guildWarMyDataModel)
end

function GuildMistWarMyDataCtrl:OnEnterScene()
end

function GuildMistWarMyDataCtrl:OnExitScene()
end

return GuildMistWarMyDataCtrl