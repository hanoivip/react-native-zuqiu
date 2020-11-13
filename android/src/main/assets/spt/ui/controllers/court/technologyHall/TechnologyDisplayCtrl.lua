local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtTechnologyDetailModel = require("ui.models.court.CourtTechnologyDetailModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local TechnologyDisplayCtrl = class(BaseCtrl, "TechnologyDisplayCtrl")

TechnologyDisplayCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/Detail/TechnologyDisplay.prefab"
function TechnologyDisplayCtrl:Init()
	self.view.clickEvent = function() self:ClickEvent() end
end

function TechnologyDisplayCtrl:Refresh(technologyMap)
    TechnologyDisplayCtrl.super.Refresh(self)
	local data = { }
	data.list = {}
	for i, v in ipairs(technologyMap) do
		data.list[v.TypeName] = {}
		data.list[v.TypeName].lvl = tonumber(v.TechnologyLvl)
	end
    self.courtBuildModel = CourtBuildModel.new()
	self.courtBuildModel:InitWithProtocol(data)
	self.courtTechnologyDetailModel = CourtTechnologyDetailModel.new()

	local titleStr = "weatherAndGrass_title"
	self.courtTechnologyDetailModel:SetTechnologyTitle(titleStr)
	self.courtTechnologyDetailModel:SetBarResPath("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/Detail/TechnologyBar.prefab")
    self.view:InitView(self.courtBuildModel, self.courtTechnologyDetailModel, technologyMap)
end

function TechnologyDisplayCtrl:ClickEvent()
    EventSystem.SendEvent("ShowUpperHierarchy")
end

return TechnologyDisplayCtrl
