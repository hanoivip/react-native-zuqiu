local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildMistWarRoundSettlementModel = require("ui.models.guild.guildMistWar.GuildMistWarRoundSettlementModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildMistWarRoundSettlementCtrl = class(BaseCtrl, "GuildMistWarRoundSettlementCtrl")

GuildMistWarRoundSettlementCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarRoundSettlement.prefab"

GuildMistWarRoundSettlementCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildMistWarRoundSettlementCtrl:Init()
    self.model = GuildMistWarRoundSettlementModel.new()

    self.view.OnBtnNextClick = function()
        self:InitDefenceView()
    end
end

function GuildMistWarRoundSettlementCtrl:Refresh(settlementInfo)
    GuildMistWarRoundSettlementCtrl.super.Refresh(self)
    self.model:InitWithProtocol(settlementInfo)
    self:InitAttackView()
end

function GuildMistWarRoundSettlementCtrl:InitAttackView()
    self.view:InitAttackView(self.model)
end

function GuildMistWarRoundSettlementCtrl:InitDefenceView()
    self.view:InitDefenceView(self.model)
end

function GuildMistWarRoundSettlementCtrl:OnEnterScene()
end

function GuildMistWarRoundSettlementCtrl:OnExitScene()
end

return GuildMistWarRoundSettlementCtrl
