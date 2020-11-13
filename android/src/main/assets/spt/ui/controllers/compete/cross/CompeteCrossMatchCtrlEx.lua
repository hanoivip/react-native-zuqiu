local CompeteCrossMatchModel = require("ui.models.compete.cross.CompeteCrossMatchModel")
local CrossContentOrder = require("ui.scene.compete.cross.CrossContentOrder")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteCrossMatchCtrlEx = class(BaseCtrl, "CompeteCrossMatchCtrlEx")

CompeteCrossMatchCtrlEx.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteCrossMatch.prefab"

function CompeteCrossMatchCtrlEx:AheadRequest(pageIndex)
	if self.view then 
		self.view:ShowDisplayArea(false)
	end
	self.pageIndex = pageIndex or 1
	self.competeCrossMatchModel = CompeteCrossMatchModel.new()
	self.competeCrossMatchModel:InitPageIndex(pageIndex)
	local crossType = CrossContentOrder.Type.GalaxyType
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

function CompeteCrossMatchCtrlEx:Init()
    self.view.clickLeft = function() self:OnBtnLeft() end
    self.view.clickRight = function() self:OnBtnRight() end
end

function CompeteCrossMatchCtrlEx:Refresh(pageIndex)
	CompeteCrossMatchCtrlEx.super.Refresh(self)
	self.view:InitView(self.competeCrossMatchModel, pageIndex)
end

function CompeteCrossMatchCtrlEx:GetStatusData()
	local pageIndex = self.competeCrossMatchModel:GetPageIndex()
    return pageIndex
end

function CompeteCrossMatchCtrlEx:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteCrossMatchCtrlEx:OnExitScene()
    self.view:OnExitScene()
end

function CompeteCrossMatchCtrlEx:OnBtnLeft()

end

function CompeteCrossMatchCtrlEx:OnBtnRight()

end

return CompeteCrossMatchCtrlEx
