local EventSystem = require("EventSystem")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterFilterCtrl = class(BaseCtrl)

PasterFilterCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PasterSplit/PasterFilter.prefab"

function PasterFilterCtrl:Init(pasterSplitableModelList, cardIndexViewModel)
	self.cardIndexViewModel = cardIndexViewModel
	self.pasterSplitableModelList = pasterSplitableModelList
	self.tempModelList = pasterSplitableModelList

	self.view.clickReset = function() self:OnBtnReset() end
	self.view.clickConfirm = function(nationality, name) self:OnBtnConfirm(nationality, name) end
	self.view.clickMonth = function() self:OnBtnMonth() end
	self.view.clickWeek = function() self:OnBtnWeek() end
end

function PasterFilterCtrl:Refresh(pasterSplitableModelList, cardIndexViewModel)
	self.view:InitView(pasterSplitableModelList, cardIndexViewModel)
end

function PasterFilterCtrl:OnBtnConfirm(nationality, name)
	local playerName = self.view.nameInput.text and self.view.nameInput.text or ""
	self.cardIndexViewModel:SetViewPlayerName(playerName)

	local newPasterModelList = self:FilterModelList(nationality, name)
	EventSystem.SendEvent("PasterSplit_RefreshPanelList", newPasterModelList)
end

function PasterFilterCtrl:FilterModelList(nationality, name)
	local pasterModelList1 = {}
	local pasterModelList2 = {}
	local listAfterFilter = self.tempModelList
	if self.tempModelList and type(self.tempModelList) == "table" then
		if nationality ~= "" then
			for k, cardPasterModel in pairs(self.tempModelList) do
				if nationality == cardPasterModel:GetNationByEnglish() or nationality == cardPasterModel:GetNationByChinese() then
					table.insert(pasterModelList1, cardPasterModel)
				end
			end
			listAfterFilter = pasterModelList1
		else
			pasterModelList1 = self.tempModelList
		end
		if name ~= "" then
			for k, cardPasterModel in pairs(pasterModelList1) do
				local englishName = cardPasterModel:GetNameByEnglish()
				local chineseName = cardPasterModel:GetNameByChinese()
				if string.find(englishName, name) or string.find(chineseName, name) then
					table.insert(pasterModelList2, cardPasterModel)
				end
			end
			listAfterFilter = pasterModelList2
		end
	end
	return listAfterFilter
end

function PasterFilterCtrl:PasterFilterByWOrM(isMonth)
	local containerList = {}
	self.tempModelList = self.pasterSplitableModelList
	for k, cardPasterModel in pairs(self.tempModelList) do
		if tostring(cardPasterModel:IsMonthPaster()) == tostring(isMonth) then
			table.insert(containerList, cardPasterModel)
		end
	end
	self.tempModelList = containerList
end

function PasterFilterCtrl:OnBtnReset()
    self.view:OnReset()
end

function PasterFilterCtrl:OnBtnMonth( )
	self:PasterFilterByWOrM(true)
end

function PasterFilterCtrl:OnBtnWeek( )
	self:PasterFilterByWOrM(false)
end

return PasterFilterCtrl
