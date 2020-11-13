local EventSystem = require("EventSystem")
local PasterListDataCtrl = require("ui.controllers.activity.content.pasterSplit.PasterListDataCtrl")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local DialogManager = require("ui.control.manager.DialogManager")

local PasterListCtrl = class()

function PasterListCtrl:ctor()
    local mailDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/PasterSplit/PasterList.prefab", "camera", true, true)
    self.pasterListView = dialogcomp.contentcomp

    self.pasterListDataCtrl = nil
	self.pasterSplitableModelList = {}
	self.cardResourceCache = CardResourceCache.new()
    self.pasterListView.clickFilterBtn = function() self:OnBtnFilterBtn() end
    self.pasterListView.leaveCurrentScene = function() self:OnLeaveCurrentScene() end
    self.pasterListView.clickConfirmBtn = function() self:OnBtnConfirmBtn() end

    EventSystem.AddEvent("PasterSplit_RefreshPanelList", self, self.EventRefreshPanelList)

    self.selectedPasterModel = nil

    self:InitView()
end

function PasterListCtrl:EventRefreshPanelList(newPasterModelList)
    if self.pasterListDataCtrl then
    	self.pasterListDataCtrl.scrollView:InitView(self.pasterListView, newPasterModelList, self.cardResourceCache)
	end
end

function PasterListCtrl:OnLeaveCurrentScene()
	if self.cardResourceCache then self.cardResourceCache:Clear() end
	EventSystem.RemoveEvent("PasterSplit_RefreshPanelList", self, self.EventRefreshPanelList)
end

function PasterListCtrl:OnBtnFilterBtn()
	if not self.cardIndexViewModel then
		self.cardIndexViewModel = CardIndexViewModel.new() 
	end
	res.PushDialog("ui.controllers.activity.content.pasterSplit.PasterFilterCtrl", self.pasterSplitableModelList, self.cardIndexViewModel)
end

function PasterListCtrl:InitView()
	EventSystem.SendEvent("PasterSplit_RefreshPanelList", {})
	self.pasterListDataCtrl = PasterListDataCtrl.new(self.pasterListView, self.cardResourceCache)

	self.pasterListDataCtrl:RefreshView()	--refresh paster scroller
	self.pasterSplitableModelList = self.pasterListDataCtrl.pasterSplitableModelList
end

return PasterListCtrl
