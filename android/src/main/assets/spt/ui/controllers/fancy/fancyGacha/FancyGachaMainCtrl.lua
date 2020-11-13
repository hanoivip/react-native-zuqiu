local FancyGachaModel = require("ui.models.fancy.fancyGacha.FancyGachaModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local FancyGachaInfoBarCtrl = require("ui.controllers.common.FancyGachaInfoBarCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyCardResourceCache = require('ui.common.fancycard.FancyCardResourceCache')
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FancyGachaMainCtrl = class(BaseCtrl, "FancyGachaMainCtrl")

FancyGachaMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyGacha/FancyGachaMain.prefab"

function FancyGachaMainCtrl:ctor()
    FancyGachaMainCtrl.super.ctor(self)
    self.sptMap = {}
    self.fancyCardResourceCache = FancyCardResourceCache.new()
end

function FancyGachaMainCtrl:AheadRequest()
    local response = req.fancyCardGachaInfo()
    if api.success(response) then
        local data = response.val
        local fancyGachaModel = FancyGachaModel:new()
        fancyGachaModel:Init(data)
        self.model = fancyGachaModel
        if not self.data then return end
        -- 服务器数据改变后刷新界面
        for i, v in pairs(data) do
            if not self.data.i then
                self.view:InitView(self.model)
                self.data = data
                return
            end
        end
        for i, v in pairs(self.data) do
            if not data.i then
                self.view:InitView(self.model)
                self.data = data
                return
            end
        end
    else
        self.view:InitView(self.model)
    end
end

function FancyGachaMainCtrl:Init()
    self.FancyCardModel = FancyCardModel.new()
    self:RegInfoBar()
    self:RegBtnEvent()
    self:SetRollingContents()
    self.view:InitView(self.model)
    self.view.clickOnlyOneTab = function() self:OnOnlyOneTab() end
    self.view.RequestRead = function(index, callBack) self:RequestRead(index, callBack) end
    GuideManager.Show(self)
end

function FancyGachaMainCtrl:RegBtnEvent()
    self.view.onClickBtnAllCards = function() self:OnClickBtnAllCards() end
    self.view.onClickBtnStore = function() self:OnClickBtnStore() end
    self.view.onClickBtnGachaOnce = function() self:OnClickBtnGacha(1) end
    self.view.onClickBtnGachaTenTimes = function() self:OnClickBtnGacha(10) end
    self.view.initCards = function(cardList) self:InitCards(cardList) end
end

function FancyGachaMainCtrl:RegInfoBar()
    self.view:RegOnDynamicLoad(function (child)
        local param = {}
        param.isHideSoul = true
        param.isHideMoney = true
        self.infoBarCtrl = FancyGachaInfoBarCtrl.new(child, param)
    end)
end

-- 初始化滑动显示的卡池
function FancyGachaMainCtrl:SetRollingContents()
    local rollManager = self.view.rollManagerSpt
    local RollData = 
    {
        {positionX = -50 * 3, positionY = -41 * 1.2, scale = 0.60 / 0.7, alpha = 1, order = 7, outAlpha = 0, groupAlpha = 1 },
        {positionX = 51 * 3, positionY = -40 * 1.2, scale = 0.60 / 0.7, alpha = 1, order = 8, outAlpha = 0, groupAlpha = 1 },
        {positionX = 111 * 3, positionY = -5 * 1.2, scale = 0.55 / 0.7, alpha = 1, order = 6, outAlpha = 0.1, groupAlpha = 0.95 },
        {positionX = 81 * 3, positionY = 25 * 1.2, scale = 0.50 / 0.7, alpha = 1, order = 4, outAlpha = 0.3, groupAlpha = 0.9 },
        {positionX = 21 * 3, positionY = 40 * 1.2, scale = 0.45 / 0.7, alpha = 1, order = 2, outAlpha = 0.5, groupAlpha = 0.85 },
        {positionX = -20 * 3, positionY = 41 * 1.2, scale = 0.45 / 0.7, alpha = 1, order = 1, outAlpha = 0.5, groupAlpha = 0.85 },
        {positionX = -80 * 3, positionY = 26 * 1.2, scale = 0.50 / 0.7, alpha = 1, order = 3, outAlpha = 0.3, groupAlpha = 0.9 },
        {positionX = -110 * 3, positionY = -6 * 1.2, scale = 0.55 / 0.7, alpha = 1, order = 5, outAlpha = 0.1, groupAlpha = 0.95 }    
    }
    self.animOverCount = 0
    for i = 1, 8 do
        local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
        itemObj.transform:SetParent(self.view.contentsTrans, false)
        local rollItem = RollData[i]
        rollItem.object = itemObj
        rollManager:AddRollRingData(rollItem)
        table.insert(self.sptMap, itemSpt)
    end
    local function IntegerDataFunc(v, nextIndex, originData)
        v.outAlpha = originData[nextIndex].outAlpha
        v.groupAlpha = originData[nextIndex].groupAlpha
    end
    local function DecimalDataFunc(i, nextIndex, t, v, cachedData)
        v.outAlpha = math.lerp(cachedData[i].outAlpha, cachedData[nextIndex].outAlpha, t)
        v.groupAlpha = math.lerp(cachedData[i].groupAlpha, cachedData[nextIndex].groupAlpha, t)
    end
    local function DrawFunc()
        self.view.flageImg.transform.SetSiblingIndex(6)
    end
    rollManager:AddIntegerDataFunc(IntegerDataFunc)
    rollManager:AddDecimalDataFunc(DecimalDataFunc)
    rollManager:AddDrawFunc(DrawFunc)
    rollManager:SetDistRat(0.1)
    rollManager:SetMoveMode("arc", {x = 0, y = 0})
    rollManager:Init()
end

-- 设置卡池中的卡牌显示
function FancyGachaMainCtrl:InitCards(cardList)
    self.view.rollManagerSpt:Init()
    self.cardList = cardList
    local showCard = #cardList ~= 0
    GameObjectHelper.FastSetActive(self.view.contentsTrans.gameObject, showCard)
    if not showCard then return end
    local firstIndex = 1
    for i, v in ipairs(self.sptMap) do
        if v.transform.localPosition.x == -150 then
            firstIndex = i
            break
        end
    end
    for i = 1, 8 do
        local index = (firstIndex + i - 1 ) % 8
        if index == 0 then
            index = 8
        end
        self.sptMap[index]:SetResourceCache(self.fancyCardResourceCache)
        self.sptMap[index]:InitView(cardList[i])
    end
end

-- 打开卡库一览
function FancyGachaMainCtrl:OnClickBtnAllCards()
    local groupId = self.view.curGachaGroup:GetId()
    res.PushDialog("ui.controllers.fancy.fancyGacha.FancyGachaPoolBoardCtrl", groupId, self.fancyCardResourceCache)
end

-- 打开商店
function FancyGachaMainCtrl:OnClickBtnStore()
    local ctrlPath = "ui.controllers.fancy.fancyStore.FancyStoreBoardCtrl"
    res.PushDialog(ctrlPath)
end

-- 招募
function FancyGachaMainCtrl:OnClickBtnGacha(times)
    local gachaID = self.view.curGachaGroup:GetId()
    local itemsMapModel = ItemsMapModel:new()
    local costItem = self.view.curGachaGroup:GetGachaItemId(times)
    local free = self.view.curGachaGroup:GetFirst()
    if self.view.curGachaGroup:IsNew() then
        self:RequestRead(self.model:GetCurGroup())
    end
    -- 招募一次
    if times == 1 then
        if itemsMapModel:GetItemNum(costItem) < 1 and not free then
            self.infoBarCtrl:OnBtnFancyOneTicket()
            return
        end
        clr.coroutine(function()
            local response = req.fancyCardGachaOne(gachaID)
            if api.success(response) then
                local data = response.val
                GuideManager.Show(self)
                if data.contents then
                    CongratulationsPageCtrl.new(data.contents[1])
                end
                if data.cost and not free then
                    itemsMapModel:ResetItemNum(data.cost.id, data.cost.num)
                end
                if free then
                    self.view.curGachaGroup:SetNotFirst()
                end
                EventSystem.SendEvent("FancyGachaStart")
            end
        end)
    -- 招募十次
    else
        if itemsMapModel:GetItemNum(costItem) < 1 then
            self.infoBarCtrl:OnBtnFancyTenTicket()
            return
        end
        clr.coroutine(function()
            local response = req.fancyCardGachaTen(gachaID)
            if api.success(response) then
                local data = response.val
                if data.contents then
                    local path  = "ui.controllers.fancy.fancyGacha.FancyMultipleRewardCtrl"
                    res.PushDialog(path, data.contents, self)
                end
                if data.cost then
                    itemsMapModel:ResetItemNum(data.cost.id, data.cost.num)
                end
                EventSystem.SendEvent("FancyGachaStart")
            end
        end)
    end
end

function FancyGachaMainCtrl:RequestRead(index, callBack)
    clr.coroutine(function()
        local response = req.fancyCardView(self.view.curGachaGroup:GetId())
        if api.success(response) then
            if callBack then
                callBack()
            end
            self.view.labelGroupSpt.menu[index]:FreshRedPoint()
        end
    end)
end

function FancyGachaMainCtrl:OnOnlyOneTab()
    self.view.curGachaGroup:GetId()
    local hideOnlyOneTabBtnFunc = function() self.view:ShowOrHideOnlyOneTabBtn(false) end
    self:RequestRead(1 ,hideOnlyOneTabBtnFunc)
end

function FancyGachaMainCtrl:OnEnterScene()
end

function FancyGachaMainCtrl:OnExitScene()
    self.view:OnExitScene()
    self.fancyCardResourceCache:Clear()
end

return FancyGachaMainCtrl