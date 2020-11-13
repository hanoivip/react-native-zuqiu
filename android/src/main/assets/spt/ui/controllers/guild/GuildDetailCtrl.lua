local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildDetailModel = require("ui.models.guild.GuildDetailModel")
local UnityEngine = clr.UnityEngine

local GuildDetailCtrl = class(BaseCtrl)

GuildDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildDetail.prefab"

function GuildDetailCtrl:Init()
    self.guildDetailtModel = GuildDetailModel.new()

end

function GuildDetailCtrl:Refresh(data)
    GuildDetailCtrl.super.Refresh(self)
    self.guildDetailtModel:InitWithProtrol(data)
    self:InitView()            
end

function GuildDetailCtrl:InitView()
    self.view:InitView(self.guildDetailtModel)
end

function GuildDetailCtrl:OnEnterScene()
end

function GuildDetailCtrl:OnExitScene()
end

return GuildDetailCtrl