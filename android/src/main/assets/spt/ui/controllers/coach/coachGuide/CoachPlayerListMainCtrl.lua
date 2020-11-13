local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachPlayerListMainModel = require("ui.models.coach.coachGuide.CoachPlayerListMainModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local SortType = require("ui.controllers.playerList.SortType")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local CoachPlayerListMainCtrl = class(BaseCtrl, "CoachPlayerListMainCtrl")

CoachPlayerListMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachGuide/CoachPlayerList.prefab"

function CoachPlayerListMainCtrl:Init()
    self.view.clickSort = function(index) self:OnSortClick(index) end
    self.view.clickBack = function() self:Close() end
    self.view.clickSearch = function() self:OnSearchClick() end
    self.view.clickConfirm = function() self:OnBtnConfirm() end
    self.view.clickCancel = function() self:OnBtnCancel() end

    -- 选中卡牌之后的事件回调（球员出售）
    self.view.selectCardCallBack = function(pcid, isSelected)
        self:SelectCardCallBack(pcid, isSelected)
    end

    self.view.clearSelectedCardsCallBack = function()
        self:ClearSelectedCardsCallBack()
    end

    -- 排序
    self.view.sortCardListCallBack = function()
        self:SortCardListCallBack()
    end
    -- 球员上限变化
    self.view.playerCapacityCallBack = function(playerCapacity)
        self:PlayerCapacityCallBack(playerCapacity)
    end
    -- 添加球员
    self.view.addCardCallBack = function(pcid)
        self:AddCardCallBack(pcid)
    end

    self.cardResourceCache = CardResourceCache.new()
    self:RegScrollComp()
    self.isInitial = false
end

function CoachPlayerListMainCtrl:Refresh(slotData, scrollNormalizedPos, selectTypeIndex, selectPos, isInitial, selectQuality, selectNationality, selectName, selectSkill)
    CoachPlayerListMainCtrl.super.Refresh(self)
    self.slotData = slotData
    if not selectTypeIndex then
        selectTypeIndex = SortType.DEFAULT
    end
    self.coachPlayerListMainModel = CoachPlayerListMainModel.new(slotData)
    if not self.cardIndexViewModel then
        self.cardIndexViewModel = CardIndexViewModel.new()
    end

    self.cacheScrollPos = scrollNormalizedPos or 1
    self:InitView(self.coachPlayerListMainModel)
    self:InitialInfo()

    self.view:coroutine(function()
        coroutine.yield(UnityEngine.WaitForEndOfFrame())
        self.coachPlayerListMainModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    end)
    GuideManager.Show(self)
end

-- 初始化默认数据
function CoachPlayerListMainCtrl:InitialInfo()
    self.view:InitialData()
end

function CoachPlayerListMainCtrl:GetStatusData()
    return self.currentMenu, self.cacheScrollPos, self.selectTypeIndex, self.selectPos, self.isInitial, self.selectQuality, self.selectNationality, self.selectName, self.selectSkill
end

function CoachPlayerListMainCtrl:OnEnterScene()
    self.view:EnterScene()
end

function CoachPlayerListMainCtrl:OnExitScene()
    self.view:ExitScene()
end

function CoachPlayerListMainCtrl:InitView(coachPlayerListMainModel)
    self.view:InitView(coachPlayerListMainModel, self.currentMenu)
    self:RefreshScrollView()
end

function CoachPlayerListMainCtrl:GetPlayerRes()
    if not self.playerRes then
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Player.prefab")
    end
    return self.playerRes
end

function CoachPlayerListMainCtrl:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function CoachPlayerListMainCtrl:RegScrollComp()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj = Object.Instantiate(self:GetPlayerRes())
        local spt = res.GetLuaScript(obj)
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local itemData = self.view.scrollView.itemDatas[index]
        spt:InitView(itemData, self.currentMenu, self.coachPlayerListMainModel, self.cardResourceCache, self)
        spt:SetSellState(self.coachPlayerListMainModel:IsCardSelected(itemData:GetPcid()))
        spt.clickCard = function() self:OnCardClick(itemData:GetPcid()) end
        spt:SetMessageState(false)
        self.view.scrollView:updateItemIndex(spt, index)
    end
end

function CoachPlayerListMainCtrl:RefreshScrollView()
    -- 创建卡牌列表
    local sortCardList = self.coachPlayerListMainModel:GetSortCardList(slotData)
    self.selectTypeIndex = self.coachPlayerListMainModel:GetSelectTypeIndex()
    self.selectPos = self.coachPlayerListMainModel:GetSelectPos()
    self.selectQuality = self.coachPlayerListMainModel:GetSelectQuality()
    self.selectName = self.coachPlayerListMainModel:GetSeletName()
    self.selectNationality = self.coachPlayerListMainModel:GetSeletNationality()
    self.selectSkill = self.coachPlayerListMainModel:GetSeletSkill()
    local cardsArray = {}
    for i, pcid in ipairs(sortCardList) do
        local cardModel = self.coachPlayerListMainModel:GetCardModel(pcid)
        table.insert(cardsArray, cardModel)
    end
    self.view.scrollView:RefreshItemWithScrollPos(cardsArray, self.cacheScrollPos)
end

function CoachPlayerListMainCtrl:SortCardListCallBack()
    self:RefreshScrollView()
end

function CoachPlayerListMainCtrl:ClearSelectedCardsCallBack()
    for index, v in pairs(self.view.scrollView.itemDatas) do
        local cardView = self.view.scrollView:getItem(index)
        if cardView then
            cardView:SetSellState(false)
        end
    end
end

function CoachPlayerListMainCtrl:ResetOneCardCallBack(pcid)
    local index
    local cardModel = self.coachPlayerListMainModel:GetCardModel(pcid)
    for i, v in ipairs(self.view.scrollView.itemDatas) do
        if tostring(v:GetPcid()) == tostring(pcid) then
            index = i
            break
        end
    end
    if index then
        self.view.scrollView.itemDatas[index] = cardModel
        local cardView = self.view.scrollView:getItem(index)
        if cardView then
            cardView:InitView(cardModel, self.currentMenu, self.coachPlayerListMainModel)
        end
    end
end

function CoachPlayerListMainCtrl:SelectCardCallBack(pcid, isSelected)
    local index
    for i, v in ipairs(self.view.scrollView.itemDatas) do
        if tostring(v:GetPcid()) == tostring(pcid) then
            index = i
            break
        end
    end
    if index then
        local cardView = self.view.scrollView:getItem(index)
        if cardView then
            cardView:SetSellState(isSelected)
        end
    end
end

function CoachPlayerListMainCtrl:OnCardClick(pcid)
    self:OnBtnCancel()
    self.coachPlayerListMainModel:ToggleSelectCard(pcid)
end

function CoachPlayerListMainCtrl:OnBtnConfirm()
    local selectCard = self.coachPlayerListMainModel:GetSelectedCardList()
    local selectPcid = selectCard[1]
    local slot = self.slotData.id
    if selectPcid then
        self.view:coroutine(function()
            local response = req.coachGuideCard(selectPcid, slot)
            if api.success(response) then
                local data = response.val
                for i,v in ipairs(data.card) do
                    local pcid = v.pcid
                    self.coachPlayerListMainModel:ResetCardData(pcid, v)
                end
                EventSystem.SendEvent("CoachGuideCtrl_SlotPlayerChange", data)
                self:Close()
                EventSystem.SendEvent("CoachGuideCtrl_EnterPlayerGuide")
            end
        end)
    else
        DialogManager.ShowToastByLang("coach_guide_select_card")
    end
end

function CoachPlayerListMainCtrl:OnSortClick(selectTypeIndex)
    self.cacheScrollPos = 1
    local typeIndex = self.coachPlayerListMainModel:GetSelectTypeIndex()
    if typeIndex == selectTypeIndex then return end
    local selectPos = self.coachPlayerListMainModel:GetSelectPos()
    local selectQuality = self.coachPlayerListMainModel:GetSelectQuality()
    local selectNationality = self.coachPlayerListMainModel:GetSeletNationality()
    local selectName = self.coachPlayerListMainModel:GetSeletName()
    local selectSkill = self.coachPlayerListMainModel:GetSeletSkill()
    self.coachPlayerListMainModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
end

function CoachPlayerListMainCtrl:OnBtnCancel()
    self.coachPlayerListMainModel:ClearSelectedCardList()
end

function CoachPlayerListMainCtrl:OnSearchClick()
    res.PushDialog("ui.controllers.playerList.PlayerSearchCtrl", self.coachPlayerListMainModel, self.cardIndexViewModel)
end

function CoachPlayerListMainCtrl:AddCardCallBack(pcid)
    self.coachPlayerListMainModel:AddCard(pcid)
    self:RefreshScrollView()
end

function CoachPlayerListMainCtrl:Close()
    self.cardResourceCache:Clear()
    self.playerRes = nil
    self.cardRes = nil
    self.view:Close()
end

return CoachPlayerListMainCtrl
