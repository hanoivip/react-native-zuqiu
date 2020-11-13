local CompeteCrossMatchModel = require("ui.models.compete.cross.CompeteCrossMatchModel")
local CrossContentOrder = require("ui.scene.compete.cross.CrossContentOrder")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteCrossMatchCtrl = class(BaseCtrl, "CompeteCrossMatchCtrl")

CompeteCrossMatchCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteCrossMatch.prefab"

function CompeteCrossMatchCtrl:AheadRequest(pageIndex)
	if self.view then 
		self.view:ShowDisplayArea(false)
	end
	self.pageIndex = pageIndex or 1
	self.competeCrossMatchModel = CompeteCrossMatchModel.new()
	self.competeCrossMatchModel:InitPageIndex(pageIndex)
	local crossType = CrossContentOrder.Type.UniverseType
    local response = req.competeCrossMatch(crossType)
    if api.success(response) then
        local data = response.val
		local playerInfoModel = PlayerInfoModel.new()
		local playerId = playerInfoModel:GetID()
		self.competeCrossMatchModel:SetPlayerRoleId(playerId)
        self.competeCrossMatchModel:InitWithProtocol(data, crossType)
		self.view:ShowDisplayArea(true)
    end	
end

function CompeteCrossMatchCtrl:Init()
    self.view.clickLeft = function() self:OnBtnLeft() end
    self.view.clickRight = function() self:OnBtnRight() end
end

function CompeteCrossMatchCtrl:Refresh(pageIndex)
	CompeteCrossMatchCtrl.super.Refresh(self)
	self.view:InitView(self.competeCrossMatchModel, pageIndex)
end

function CompeteCrossMatchCtrl:GetStatusData()
	local pageIndex = self.competeCrossMatchModel:GetPageIndex()
    return pageIndex
end

function CompeteCrossMatchCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteCrossMatchCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CompeteCrossMatchCtrl:OnBtnLeft()

end

function CompeteCrossMatchCtrl:OnBtnRight()

end

return CompeteCrossMatchCtrl
