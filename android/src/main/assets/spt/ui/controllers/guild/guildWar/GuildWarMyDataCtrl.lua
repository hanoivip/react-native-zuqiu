local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildWarMyDataModel = require("ui.models.guild.guildWar.GuildWarMyDataModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildWarMyDataCtrl = class(BaseCtrl)

GuildWarMyDataCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildWarMyData.prefab"

function GuildWarMyDataCtrl:Init()
    self.guildWarMyDataModel = GuildWarMyDataModel.new()

    self.view.onMenuItemClick = function(index)
        if index == self.guildWarMyDataModel:GetCurrentDate() then return end
        self.guildWarMyDataModel:SetCurrentDate(index)
        self:InitView()
    end
end

function GuildWarMyDataCtrl:Refresh()
    GuildWarMyDataCtrl.super.Refresh(self)
    clr.coroutine(function()
        local respone = req.recentGuildWar()
        if api.success(respone) then
            local data = respone.val
            self.guildWarMyDataModel:InitWithProtrol(data)
            self:InitView()
        end
    end)   
end

function GuildWarMyDataCtrl:InitView()
    self.view:InitView(self.guildWarMyDataModel)
end

function GuildWarMyDataCtrl:OnEnterScene()
end

function GuildWarMyDataCtrl:OnExitScene()
end

return GuildWarMyDataCtrl