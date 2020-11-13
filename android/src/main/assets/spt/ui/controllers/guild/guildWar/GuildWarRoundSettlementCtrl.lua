local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildWarRoundSettlementModel = require("ui.models.guild.guildWar.GuildWarRoundSettlementModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildWarRoundSettlementCtrl = class(BaseCtrl)

GuildWarRoundSettlementCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildWarRoundSettlement.prefab"

GuildWarRoundSettlementCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildWarRoundSettlementCtrl:Init()
    self.guildWarRoundSettlementModel = GuildWarRoundSettlementModel.new()

    self.view.OnBtnNextClick = function()
        self:InitDefenceView()
    end
end

function GuildWarRoundSettlementCtrl:Refresh(settlementInfo)
    GuildWarRoundSettlementCtrl.super.Refresh(self)
    self.guildWarRoundSettlementModel:InitWithProtrol(settlementInfo)
    self:InitAttackView()
end

function GuildWarRoundSettlementCtrl:InitAttackView()
    self.view:InitAttackView(self.guildWarRoundSettlementModel)
end

function GuildWarRoundSettlementCtrl:InitDefenceView()
    self.view:InitDefenceView(self.guildWarRoundSettlementModel)
end

function GuildWarRoundSettlementCtrl:OnEnterScene()
end

function GuildWarRoundSettlementCtrl:OnExitScene()
end

return GuildWarRoundSettlementCtrl