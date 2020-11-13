local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local SortType = require("ui.controllers.playerList.SortType")
local CardDetailModel = require("ui.models.cardDetail.CardDetailModel")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local SupporterSelectModel = require("ui.models.cardDetail.supporter.SupporterSelectModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local SupporterSelectCtrl = class(BaseCtrl, "SupporterSelectCtrl")

SupporterSelectCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/SupporterSelectBoard.prefab"

function SupporterSelectCtrl:Init(scrollNormalizedPos, selectTypeIndex, selectPos, isInitial, selectQuality, selectNationality, selectName, selectSkill, playerCardModel, supporterModel)
    SupporterSelectCtrl.super.Init(self)
    self.playerCardModel = playerCardModel
    self.supporterModel = supporterModel
    self.playerListModel = SupporterSelectModel.new(self.playerCardModel)
    self.view.clickConfirm = function () self:OnConfirm() end
    self.view.clickSearch = function () self:OnSearch() end
    -- 排序
    self.view.sortCardListCallBack = function() self:SortCardListCallBack() end
    self.view.clickSort = function(index) self:OnSortClick(index) end
    self:RegScrollComp()
    self.isInitial = true
end

function SupporterSelectCtrl:OnConfirm(notConfirm)
    local oldSupporterModel = self.view.oldSupporterModel
    local selectCardModel
    if notConfirm then
        self.supporterModel:SetSupportCardModel(oldSupporterModel)
        selectCardModel = oldSupporterModel
    else
        selectCardModel = self.supporterModel:GetSupportCardModel()
    end
    
    if selectCardModel then
        local sPcid = tostring(selectCardModel:GetPcid())
        selectCardModel:RefreshCardData(sPcid)
        self.supporterModel:InitInfo(not oldSupporterModel or selectCardModel:GetPcid() ~= oldSupporterModel:GetPcid())
        clr.coroutine(function()
            local cardModel = self.supporterModel:GetCardModel()
            local mpcid = tostring(cardModel:GetPcid())
            local response = req.cardTrainingInfoList({sPcid, mpcid})
            if api.success(response) then
                local data = response.val
                self.supporterModel:SetTrainingData(data[sPcid].training, data[mpcid].training)
                self.view:CloseView()
            end
        end)
    else
        self.view:CloseView()
    end
end

function SupporterSelectCtrl:OnSearch()
    res.PushDialog("ui.controllers.playerList.PlayerSearchCtrl", self.playerListModel, self.cardIndexViewModel)
end

function SupporterSelectCtrl:Refresh(scrollNormalizedPos, selectTypeIndex, selectPos, isInitial, selectQuality, selectNationality, selectName, selectSkill, playerCardModel, supporterModel)
    SupporterSelectCtrl.super.Refresh(self)
    if not selectTypeIndex then
        selectTypeIndex = SortType.DEFAULT
    end
    if not self.cardIndexViewModel then
        self.cardIndexViewModel = CardIndexViewModel.new()
    end
    if not self.playerCardModel then
        self.playerCardModel = playerCardModel
    end
    if not self.supporterModel then
        self.supporterModel = supporterModel
    end
    self.cacheScrollPos = scrollNormalizedPos or 1
    self:InitView(self.playerListModel, self.supporterModel)
    self:InitialInfo(isInitial, selectTypeIndex)

    clr.coroutine(function()
        coroutine.yield(UnityEngine.WaitForEndOfFrame())
        self.playerListModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    end)
end

-- 初始化默认数据
function SupporterSelectCtrl:InitialInfo(isInitial, selectTypeIndex)
    self.isInitial = isInitial
    if self.isInitial then 
        self.view:InitialData()
        self.isInitial = false
    else
        self.view:OnSelectSort(selectTypeIndex)
    end
end

function SupporterSelectCtrl:GetStatusData()
    return self.cacheScrollPos, self.selectTypeIndex, self.selectPos, self.isInitial, self.selectQuality, self.selectNationality, self.selectName, self.selectSkill, self.playerCardModel, self.supporterModel
end

function SupporterSelectCtrl:InitView(playerListModel, supporterModel)
    self.view:InitView(playerListModel, supporterModel)
end

function SupporterSelectCtrl:GetPlayerRes()
    if not self.playerRes then
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/SupporterPlayer.prefab")
    end
    return self.playerRes
end

function SupporterSelectCtrl:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function SupporterSelectCtrl:RegScrollComp()
    self.view.listPanelSpt.onScrollCreateItem = function(index)
        local obj = Object.Instantiate(self:GetPlayerRes())
        local spt = res.GetLuaScript(obj)
        return obj, spt
    end
    self.view.listPanelSpt.onScrollResetItem = function(spt, index)
        local itemData = self.view.listPanelSpt.itemDatas[index]
        spt:InitView(itemData, self.playerListModel, self.supporterModel, self.cardResourceCache, self)
        spt.clickCard = function() self:OnCardClick(itemData:GetPcid()) end
        self.view.listPanelSpt:updateItemIndex(spt, index)
    end
end

function SupporterSelectCtrl:RefreshScrollView()
    -- 创建卡牌列表
    local sortCardList = self.playerListModel:GetSortCardList()
    self.selectTypeIndex = self.playerListModel:GetSelectTypeIndex()
    self.selectPos = self.playerListModel:GetSelectPos()
    self.selectQuality = self.playerListModel:GetSelectQuality()
    self.selectName = self.playerListModel:GetSeletName()
    self.selectNationality = self.playerListModel:GetSeletNationality()
    self.selectSkill = self.playerListModel:GetSeletSkill()
    local cardsArray = {}
    for i, pcid in ipairs(sortCardList) do
        local cardModel = self.playerListModel:GetCardModel(pcid)
        table.insert(cardsArray, cardModel)
    end
    for i, v in pairs(cardsArray) do
    end
    self.view.listPanelSpt:RefreshItemWithScrollPos(cardsArray, self.cacheScrollPos)
end

function SupporterSelectCtrl:SortCardListCallBack()
    self:RefreshScrollView()
end

function SupporterSelectCtrl:ResetOneCardCallBack(pcid)
    local index
    local cardModel = self.playerListModel:GetCardModel(pcid)
    for i, v in ipairs(self.view.listPanelSpt.itemDatas) do
        if tostring(v:GetPcid()) == tostring(pcid) then
            index = i
            break
        end
    end
    if index then
        self.view.listPanelSpt.itemDatas[index] = cardModel
        local cardView = self.view.listPanelSpt:getItem(index)
        if cardView then
            cardView:InitView(cardModel, self.playerListModel)
        end
    end
end

function SupporterSelectCtrl:OnCardClick(pcid)
    -- 点击卡牌，弹出卡牌详情页面
    local cardList = self.playerListModel:GetSortCardList()
    for i, v in ipairs(cardList) do
        if tostring(v) == tostring(pcid) then
            self.cacheScrollPos = self.view.listPanelSpt:GetScrollNormalizedPosition()
            local teamModel = self.playerListModel:GetTeamModel()
            local currentModel = CardBuilder.GetOwnCardModel(cardList[i], teamModel)
            local cardDetailModel = CardDetailModel.new(currentModel)
            cardDetailModel:SetSupporterCloseByConfig(true)
            clr.coroutine(function()
                unity.waitForEndOfFrame()
                res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, i, currentModel, cardDetailModel, true)
            end)
            break
        end
    end
end

function SupporterSelectCtrl:OnSortClick(selectTypeIndex)
    self.cacheScrollPos = 1
    local typeIndex = self.playerListModel:GetSelectTypeIndex()
    if typeIndex == selectTypeIndex then return end
    local selectPos = self.playerListModel:GetSelectPos()
    local selectQuality = self.playerListModel:GetSelectQuality()
    local selectNationality = self.playerListModel:GetSeletNationality()
    local selectName = self.playerListModel:GetSeletName()
    local selectSkill = self.playerListModel:GetSeletSkill()
    self.playerListModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
end

function SupporterSelectCtrl:OnEnterScene()
    self.view:EnterScene()
end

function SupporterSelectCtrl:OnExitScene()
    self.view:ExitScene()

end

return SupporterSelectCtrl
