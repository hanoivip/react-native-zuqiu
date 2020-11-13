local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildWarSettlementModel = require("ui.models.guild.guildWar.GuildWarSettlementModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildWarSettlementCtrl = class(BaseCtrl)

GuildWarSettlementCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildWarSettlement.prefab"

GuildWarSettlementCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildWarSettlementCtrl:Init()
    self.guildWarSettlementModel = GuildWarSettlementModel.new()
end

function GuildWarSettlementCtrl:Refresh(settlementInfo)
    GuildWarSettlementCtrl.super.Refresh(self)
    self.guildWarSettlementModel:InitWithProtrol(settlementInfo)
    self:InitView()
end

function GuildWarSettlementCtrl:InitView()
    self.view:InitView(self.guildWarSettlementModel)
end

function GuildWarSettlementCtrl:OnEnterScene()
end

function GuildWarSettlementCtrl:OnExitScene()
end

return GuildWarSettlementCtrl