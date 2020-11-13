local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteCrossMatchView = class(unity.base)

function CompeteCrossMatchView:ctor()
    self.scrollEx = self.___ex.scrollEx
	self.btnLeft = self.___ex.btnLeft
	self.btnRight = self.___ex.btnRight
	self.btnBack = self.___ex.btnBack
	self.disPlayArea = self.___ex.disPlayArea
	self.message = self.___ex.message
	self.empty = self.___ex.empty
end

function CompeteCrossMatchView:start()
    self.btnLeft:regOnButtonClick(function()
        self:OnBtnLeft()
    end)

    self.btnRight:regOnButtonClick(function()
        self:OnBtnRight()
    end)

    self.btnBack:regOnButtonClick(function()
        self:OnBtnBack()
    end)
end

function CompeteCrossMatchView:InitView(competeCrossMatchModel, pageIndex)
	self.competeCrossMatchModel = competeCrossMatchModel
	self.scrollEx:InitView(competeCrossMatchModel, pageIndex)

	self:ArrowStateControl()
	self:JudgeMessage(self.competeCrossMatchModel)
end

function CompeteCrossMatchView:JudgeMessage(competeCrossMatchModel)
	local message = competeCrossMatchModel:HasMessage()
	self.message.text = message
	GameObjectHelper.FastSetActive(self.empty.gameObject, message)
	self:ShowDisplayArea(not message)
end

function CompeteCrossMatchView:CompeteCrossPageChange()
	self:ArrowStateControl()
	EventSystem.SendEvent("CompeteCrossKnockoutResetPos")
end

function CompeteCrossMatchView:OnEnterScene()
	EventSystem.AddEvent("CompeteCrossPageChange", self, self.CompeteCrossPageChange)
end

function CompeteCrossMatchView:OnExitScene()
	EventSystem.RemoveEvent("CompeteCrossPageChange", self, self.CompeteCrossPageChange)
end

function CompeteCrossMatchView:OnBtnLeft()
	local pageIndex = self.competeCrossMatchModel:GetPageIndex()
	if pageIndex <= 1 then return end
	self.scrollEx:scrollToPreviousGroup()
end

function CompeteCrossMatchView:OnBtnRight()
	local pageIndex = self.competeCrossMatchModel:GetPageIndex()
	local pageNum = table.nums(self.competeCrossMatchModel:GetMatchModel())
	if pageIndex >= pageNum then return end
	self.scrollEx:scrollToNextGroup()
end

function CompeteCrossMatchView:ArrowStateControl()
	local pageNum = table.nums(self.competeCrossMatchModel:GetMatchModel())
	local pageIndex = self.competeCrossMatchModel:GetPageIndex()
	local showLeft = tobool(pageIndex > 1)
	local showRight = tobool(pageIndex < pageNum)
	GameObjectHelper.FastSetActive(self.btnLeft.gameObject, showLeft)
	GameObjectHelper.FastSetActive(self.btnRight.gameObject, showRight)
end

function CompeteCrossMatchView:OnBtnBack()
	res.PopScene()
end

function CompeteCrossMatchView:ShowDisplayArea(isShow)
	GameObjectHelper.FastSetActive(self.disPlayArea, isShow)
end

return CompeteCrossMatchView