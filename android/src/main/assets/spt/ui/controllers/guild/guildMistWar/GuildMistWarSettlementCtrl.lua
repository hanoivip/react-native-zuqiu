local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildMistWarSettlementModel = require("ui.models.guild.guildMistWar.GuildMistWarSettlementModel")

local GuildMistWarSettlementCtrl = class(BaseCtrl, "GuildMistWarSettlementCtrl")

GuildMistWarSettlementCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarSettlement.prefab"

GuildMistWarSettlementCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildMistWarSettlementCtrl:Init()
    self.model = GuildMistWarSettlementModel.new()
end

function GuildMistWarSettlementCtrl:Refresh(settlementInfo)
    GuildMistWarSettlementCtrl.super.Refresh(self)
    self.model:InitWithProtocol(settlementInfo)
    self:InitView()
end

function GuildMistWarSettlementCtrl:InitView()
    self.view:InitView(self.model)
end

function GuildMistWarSettlementCtrl:OnEnterScene()
end

function GuildMistWarSettlementCtrl:OnExitScene()
end

return GuildMistWarSettlementCtrl