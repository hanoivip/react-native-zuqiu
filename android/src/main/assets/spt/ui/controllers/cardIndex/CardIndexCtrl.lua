local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CardIndexModel = require("ui.models.cardIndex.CardIndexModel")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local MenuType = require("ui.controllers.playerList.MenuType")
local CardBuilder = require("ui.common.card.CardBuilder")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")
local CustomTagModel = require("ui.models.cardDetail.CustomTagModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardIndexCtrl = class(BaseCtrl)

CardIndexCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardIndex/CardIndexPage.prefab"

function CardIndexCtrl:AheadRequest()
    local response = req.cardIndex()
    if api.success(response) then
        local data = response.val
        if not self.cardIndexModel then
            self.cardIndexModel = CardIndexModel.new()
        end
        if not self.cardIndexViewModel then
            self.cardIndexViewModel = CardIndexViewModel.new()
        end
        self.cardIndexModel:InitWithProtocol(data)
    end
end

function CardIndexCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.cardResourceCache:Clear()
            self.view:PlayLeaveAnimation()
            res.PopScene()
        end)
    end)

    self.view.clickSearch = function() self:OnSearchClick() end
    self.view.sortCardListCallBack = function()
        self:SortCardListCallBack()
    end

    self.cardResourceCache = CardResourceCache.new()
    self:RegScrollComp()
end

function CardIndexCtrl:Refresh(scrollNormalizedPos, selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    CardIndexCtrl.super.Refresh(self)
    self.cacheScrollPos = scrollNormalizedPos or 1
    self:InitView(self.cardIndexModel)
    self.cardIndexModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
end

function CardIndexCtrl:GetStatusData()
    return self.cacheScrollPos, self.selectTypeIndex, self.selectPos, self.selectQuality, self.selectNationality, self.selectName, self.selectSkill
end

function CardIndexCtrl:InitView(cardIndexModel)
    self.view:InitView(cardIndexModel)
end

function CardIndexCtrl:GetPlayerRes()
    if not self.playerRes then 
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Player.prefab")
    end
    return self.playerRes
end

function CardIndexCtrl:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function CardIndexCtrl:RegScrollComp()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj = Object.Instantiate(self:GetPlayerRes())
        local spt = res.GetLuaScript(obj)
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local itemData = self.view.scrollView.itemDatas[index]
        local customTagModel = CustomTagModel.new()
        spt:InitView(itemData, MenuType.LIST, self.cardIndexModel, self.cardResourceCache, self, true, customTagModel)
        itemData:InitEquipsAndSkills()
        local hasSign = false
        if not GuideManager.GuideIsOnGoing("main") then
            hasSign = itemData:HasSign()
        end
        spt:SetCardTip(hasSign)

        spt.clickCard = function() self:OnCardClick(itemData:GetCid()) end
        self.view.scrollView:updateItemIndex(spt, index)
    end
end

function CardIndexCtrl:OnEnterScene()
    self.view:EnterScene()
end

function CardIndexCtrl:OnExitScene()
    self.view:ExitScene()
end

function CardIndexCtrl:OnCardClick(cid)
    -- 点击卡牌，弹出卡牌详情页面
    local cardList = self.cardIndexModel:GetSortCardList()
    for i, v in ipairs(cardList) do
        if tostring(v) == tostring(cid) then
            self.cacheScrollPos = self.view.scrollView:GetScrollNormalizedPosition()
            local currentModel = CardBuilder.GetBaseCardModel(cid)
            --开启贴纸图鉴模式
            currentModel:SetIsPasterPokedex(true)
            currentModel:SetOpenFromPageType(CardOpenFromType.HANDBOOK)
            clr.coroutine(function()
                unity.waitForEndOfFrame()
                local CardDetailMainCtrl = res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, i, currentModel)
            end)
            break
        end
    end
end

function CardIndexCtrl:OnSearchClick()
    res.PushDialog("ui.controllers.playerList.PlayerSearchCtrl", self.cardIndexModel, self.cardIndexViewModel)
end

function CardIndexCtrl:RefreshScrollView()
    -- 创建卡牌列表
    local sortCardList = self.cardIndexModel:GetSortCardList()
    self.selectTypeIndex = self.cardIndexModel:GetSelectTypeIndex()
    self.selectPos = self.cardIndexModel:GetSelectPos()
    self.selectQuality = self.cardIndexModel:GetSelectQuality()
    self.selectName = self.cardIndexModel:GetSeletName()
    self.selectNationality = self.cardIndexModel:GetSeletNationality()
    self.selectSkill = self.cardIndexModel:GetSeletSkill()
    
    local cardsArray = {}
    for i, cid in ipairs(sortCardList) do
        local cardModel = self.cardIndexModel:GetCardModel(cid)
        table.insert(cardsArray, cardModel)
    end
    self.view.scrollView:RefreshItemWithScrollPos(cardsArray, self.cacheScrollPos)
end

function CardIndexCtrl:SortCardListCallBack()
    self:RefreshScrollView()
end

return CardIndexCtrl