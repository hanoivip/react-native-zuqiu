local FancyTeamModel = require("ui.models.fancy.fancyEntry.FancyTeamModel")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local FancyTeamCtrl = class(BaseCtrl, "FancyTeamCtrl")

FancyTeamCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyEntry/FancyTeam.prefab"

function FancyTeamCtrl:ctor()
    FancyTeamCtrl.super.ctor(self)
end

function FancyTeamCtrl:Refresh(sortId)
    FancyTeamCtrl.super.Refresh(self)
    self.sortId = sortId
    self.model = FancyTeamModel.new(sortId)
    self.model.temporaryNew = {}
    self.view:InitView(self.model)
    GuideManager.Show(self)
end

function FancyTeamCtrl:GetStatusData()
    return self.sortId
end

function FancyTeamCtrl:ClearTemporaryNew()
	if self.model then
		local fancyCardsMapModel = FancyCardsMapModel.new()
		for k, v in pairs(self.model.temporaryNew) do
			fancyCardsMapModel:SetNewTip(k)
		end
		self.model.temporaryNew = {}
	end
end

function FancyTeamCtrl:OnEnterScene()
    self.view:EnterScene()
end

function FancyTeamCtrl:OnExitScene()
    self.view:ExitScene()
    self:ClearTemporaryNew()
end

return FancyTeamCtrl
