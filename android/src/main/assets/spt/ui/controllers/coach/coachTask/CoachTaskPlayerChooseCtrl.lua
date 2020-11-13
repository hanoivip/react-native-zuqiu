local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local TargetPlayerChooseModel = require("ui.models.store.TargetPlayerChooseModel")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CoachTaskPlayerChooseCtrl = class(BaseCtrl)

CoachTaskPlayerChooseCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/CoachTaskPlayerChoose.prefab"

function CoachTaskPlayerChooseCtrl:GetCoachTaskCardRes()
    if not self.coachTaskCardRes then
        self.coachTaskCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Coach/CoachTask/CoachTaskCardFrame.prefab")
    end
    return self.coachTaskCardRes
end

function CoachTaskPlayerChooseCtrl:Init(coachTaskPlayerChooseModel)
    self.cardResourceCache = CardResourceCache.new()
    self.coachTaskPlayerChooseModel = coachTaskPlayerChooseModel
    
    self.view.onConfirmClick = function()
        if self.choosePcid then
            local clickIndex = self.coachTaskPlayerChooseModel:GetTaskChooseIndex()
            EventSystem.SendEvent("CoachTaskPlayerChooseCtrl_OnConfirmClick", self.choosePcid, clickIndex)
            self:Close()
        else
            DialogManager.ShowToast(lang.trans("paster_choose_content"))
        end
    end

    self.view.onScrollCreateItem = function(scrollSelf, index)
        local obj = Object.Instantiate(self:GetCoachTaskCardRes())
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj
    end
    self.view.onScrollResetItem = function(scrollSelf, spt, index)
        local itemData = scrollSelf.itemDatas[index]  -- PlayerCardModel
        spt:SetCardResourceCache(self.cardResourceCache)
        spt:InitView(itemData)

        if index ~= self.selectIndex then
            spt:OnCancel()
        else
            spt:OnChoose()
        end
        spt.clickCard = function()
            if self.selectIndex then
                local selectSpt = scrollSelf:getItem(self.selectIndex)
                if selectSpt then
                    selectSpt:OnCancel()
                end
            end
            self.selectIndex = index
            spt:OnChoose()
            self:OnCardClick(itemData:GetPcid()) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end
    self.view.sortMenuView.clickSort = function(index) self:OnSortClick(index) end
end

function CoachTaskPlayerChooseCtrl:Refresh(coachTaskPlayerChooseModel)
    CoachTaskPlayerChooseCtrl.super.Refresh(self)
    self.coachTaskPlayerChooseModel = coachTaskPlayerChooseModel
    local cardModelList = coachTaskPlayerChooseModel:FilterPlayerCardModel()
    self.targetPlayerChooseModel = TargetPlayerChooseModel.new(cardModelList)
    if not self.cardIndexViewModel then
        self.cardIndexViewModel = CardIndexViewModel.new()
    end
    self:RefreshScrollView(cardModelList)
    self.view:InitView(coachTaskPlayerChooseModel)
end

function CoachTaskPlayerChooseCtrl:Close()
    self.cardResourceCache:Clear()
    self.view:Close()
end

function CoachTaskPlayerChooseCtrl:RefreshScrollView(cardModelList)
    self.view.scroll:clearData()
    self.selectIndex = self.coachTaskPlayerChooseModel:GetSelectIndex(cardModelList)
    local pcid = self.coachTaskPlayerChooseModel:GetNowChoosePcid()
    self.choosePcid = pcid
    self.view.scroll.itemDatas = cardModelList
    self.view.scroll:refresh()
end

function CoachTaskPlayerChooseCtrl:OnCardClick(pcid)
    local cardModel = PlayerCardModel.new(pcid)
    self.choosePcid = pcid
    self.view:SetTrainPlayer(cardModel, pcid)
end

function CoachTaskPlayerChooseCtrl:GetStatus()
    return self.coachTaskPlayerChooseModel
end


function CoachTaskPlayerChooseCtrl:OnEnterScene()
    EventSystem.AddEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

function CoachTaskPlayerChooseCtrl:OnExitScene()
    EventSystem.RemoveEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

function CoachTaskPlayerChooseCtrl:OnSortClick(selectTypeIndex)
    self.cacheScrollPos = 1
    local typeIndex = self.targetPlayerChooseModel:GetSelectTypeIndex()
    if typeIndex == selectTypeIndex then return end
    local selectPos = self.targetPlayerChooseModel:GetSelectPos()
    local selectQuality = self.targetPlayerChooseModel:GetSelectQuality()
    local selectNationality = self.targetPlayerChooseModel:GetSeletNationality()
    local selectName = self.targetPlayerChooseModel:GetSeletName()
    local selectSkill = self.targetPlayerChooseModel:GetSeletSkill()
    self.targetPlayerChooseModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
end

function CoachTaskPlayerChooseCtrl:EventSortCardList()
    self:SetSelectDetail(self.targetPlayerChooseModel)
    self:SortCardListCallBack()
end

function CoachTaskPlayerChooseCtrl:SortCardListCallBack()
    -- 创建卡牌列表
    local sortCardList = self.targetPlayerChooseModel:GetSortCardList()
    self.selectTypeIndex = self.targetPlayerChooseModel:GetSelectTypeIndex()
    self.selectPos = self.targetPlayerChooseModel:GetSelectPos()
    self.selectQuality = self.targetPlayerChooseModel:GetSelectQuality()
    self.selectName = self.targetPlayerChooseModel:GetSeletName()
    self.selectNationality = self.targetPlayerChooseModel:GetSeletNationality()
    self.selectSkill = self.targetPlayerChooseModel:GetSeletSkill()
    local cardsArray = {}
    for i, pcid in ipairs(sortCardList) do
        local cardModel = self.targetPlayerChooseModel:GetCardModel(pcid)
        table.insert(cardsArray, cardModel)
    end
    self.view:ClearChoosePlayer()
    self.choosePcid = nil
    self.selectIndex = nil
    self:RefreshScrollView(cardsArray)
end

function CoachTaskPlayerChooseCtrl:SetSelectDetail(targetPlayerChooseModel)
    local isSelected = false
    if targetPlayerChooseModel then
        local selectPos = targetPlayerChooseModel:GetSelectPos()
        local selectQuality = targetPlayerChooseModel:GetSelectQuality()
        local selectName = targetPlayerChooseModel:GetSeletName()
        local selectNationality = targetPlayerChooseModel:GetSeletNationality()
        local selectSkill = targetPlayerChooseModel:GetSeletSkill()

        if selectPos and next(selectPos) then
            isSelected = true
        end
        if selectQuality and next(selectQuality) then
            isSelected = true
        end
        if selectSkill and next(selectSkill) then
            isSelected = true
        end
        if selectName ~= "" or selectNationality ~= "" then
            isSelected = true
        end
    end
end

return CoachTaskPlayerChooseCtrl
