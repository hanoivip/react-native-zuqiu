local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local StoreModel = require("ui.models.store.StoreModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")
local Timer = require("ui.common.Timer")
local EventSystems = UnityEngine.EventSystems
local StoreView = class(unity.base)

function StoreView:ctor()
    self.infoBarDynParent = self.___ex.infoBar
    self.gachaBtn = self.___ex.gachaBtn
    self.itemBtn = self.___ex.itemBtn
    self.menuGroup = self.___ex.menuGroup
    self.scroll = self.___ex.scroll
    self.scrollBar = self.___ex.scrollBar
    self.storeContentArea = self.___ex.storeContentArea
    self.gachaContentArea = self.___ex.gachaContentArea
    self.giftBoxContentArea = self.___ex.giftBoxContentArea
    self.agentContentArea = self.___ex.agentContentArea
    self.storeItemList = self.___ex.storeItemList
    self.giftBoxItemList = self.___ex.giftBoxItemList
    self.buyOne = self.___ex.buyOne
    self.buyTen = self.___ex.buyTen
    self.onePrice = self.___ex.onePrice
    self.tenPrice = self.___ex.tenPrice
    self.iconImg = self.___ex.iconImg
    self.banner0 = self.___ex.banner0
    self.banner1 = self.___ex.banner1
    self.banner2 = self.___ex.banner2
    self.banner3 = self.___ex.banner3
    self.board1 = self.___ex.board1
    self.board2 = self.___ex.board2
    self.board3 = self.___ex.board3
    self.alarm = self.___ex.alarm
    self.alarmTxt = self.___ex.alarmTxt
    self.cardLibraryBtn = self.___ex.cardLibraryBtn
    self.friendPointArea = self.___ex.friendPointArea
    self.friendPointValue = self.___ex.friendPointValue
    self.gachaMenuGroup = self.___ex.gachaMenuGroup
    self.gachaMenuLimit4 = self.___ex.gachaMenuLimit4
    self.gachaMenuOver4 = self.___ex.gachaMenuOver4
    self.gachaMenuScroll = self.___ex.gachaMenuScroll
    self.scrollToPrev = self.___ex.scrollToPrev
    self.scrollToNext = self.___ex.scrollToNext
    self.scrollLeftArrowNormal = self.___ex.scrollLeftArrowNormal
    self.scrollLeftArrowHighlight = self.___ex.scrollLeftArrowHighlight
    self.scrollRightArrowNormal = self.___ex.scrollRightArrowNormal
    self.scrollRightArrowHighlight = self.___ex.scrollRightArrowHighlight
    self.sceneAnim = self.___ex.sceneAnim
    self.finishedBtn = self.___ex.finishedBtn
    self.oneTicketCount = self.___ex.oneTicketCount
    self.tenTicketCount = self.___ex.tenTicketCount
    self.ticketArea = self.___ex.ticketArea
    self.freeTxtGO = self.___ex.freeTxtGO
    self.consumeTicket = self.___ex.consumeTicket
    self.oneBtnImage = self.___ex.oneBtnImage
    self.tenBtnImage = self.___ex.tenBtnImage
    self.cardName = self.___ex.cardName
    self.gachaAnimator = self.___ex.gachaAnimator
    self.gachaRedPoint = self.___ex.gachaRedPoint
    self.agentView = self.___ex.agentView
    self.agentMenuObj = self.___ex.agentMenuObj
    self.agentTimelimit = self.___ex.agentTimelimit
    self.btnRecruitReward = self.___ex.btnRecruitReward
    self.recruitRewardObj = self.___ex.recruitRewardObj
    self.gachaRedPointTable = {}
    self.timerTable = {}
    self.freeGachaTimer = nil

    self:InitGachalabel()
    self:RegOnGachaBtn()
    self:RegOnRecruitRewardBtn(false)
end

function StoreView:InitGachalabel()
    self.gachaMenuScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Store/GachaLabel.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.gachaMenuScroll:regOnItemIndexChanged(function(index)
        if index > 1 then
            GameObjectHelper.FastSetActive(self.scrollLeftArrowNormal, false)
            GameObjectHelper.FastSetActive(self.scrollLeftArrowHighlight, true)
        else
            GameObjectHelper.FastSetActive(self.scrollLeftArrowNormal, true)
            GameObjectHelper.FastSetActive(self.scrollLeftArrowHighlight, false)
        end
        if index <= #self.gachaMenuScroll.itemDatas - 4 then
            GameObjectHelper.FastSetActive(self.scrollRightArrowNormal, false)
            GameObjectHelper.FastSetActive(self.scrollRightArrowHighlight, true)
        else
            GameObjectHelper.FastSetActive(self.scrollRightArrowNormal, true)
            GameObjectHelper.FastSetActive(self.scrollRightArrowHighlight, false)
        end
    end)
    self.scrollToPrev:regOnButtonClick(function()
        self.gachaMenuScroll:scrollToPreviousGroup();
    end)
    self.scrollToNext:regOnButtonClick(function()
        self.gachaMenuScroll:scrollToNextGroup();
    end)
end

function StoreView:RegOnGachaBtn()
    self.btnBuyForbidden = false
    self.buyOne:regOnButtonClick(function()
        if not self.btnBuyForbidden then
            self:coroutine(function()
                self.btnBuyForbidden = true
                coroutine.yield(UnityEngine.WaitForSeconds(1))
                self.btnBuyForbidden = false
            end)
            if type(self.clickBtnBuyOne) == "function" then
                self.clickBtnBuyOne()
            end
        end
    end)
    self.buyTen:regOnButtonClick(function()
        EventSystem.SendEvent("CardLibraryStatus", false)
        if not self.btnBuyForbidden then
            self:coroutine(function()
                self.btnBuyForbidden = true
                coroutine.yield(UnityEngine.WaitForSeconds(1))
                self.btnBuyForbidden = false
            end)
            if type(self.clickBtnBuyTen) == "function" then
                self.clickBtnBuyTen()
            end
        end
    end)
end

function StoreView:RegOnRecruitRewardBtn(isShow)
    self:SetRecruitRewardActivityActive(isShow)
    if isShow then
        self.btnRecruitReward:regOnButtonClick(function()
            if self.clickRecruitReward then
                self.clickRecruitReward()
            end
        end)
    end
end

function StoreView:SetRecruitRewardActivityActive(isShow)
    GameObjectHelper.FastSetActive(self.recruitRewardObj, isShow)
end

function StoreView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function StoreView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function StoreView:RegOnLeaveComplete(func)
    self.onLeaveCompleteCallback = func
end

function StoreView:OnLeaveComplete()
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem.enabled = true
    end
    if type(self.onLeaveCompleteCallback) == "function" then
        self.onLeaveCompleteCallback()
    end
end

function StoreView:PlayEnterAnimation()
    self.sceneAnim:Play("EffectStoreCN")
end

function StoreView:PlayLeaveAnimation()
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem = EventSystems.EventSystem.current
        self.currentEventSystem.enabled = false
    end
    self.sceneAnim:Play("EffectStoreLeaveCN")
end

function StoreView:UpdateResidualTime()
    -- 防止抽卡类型变化，将旧的全部destroy
    for k, v in pairs(self.timerTable) do
        v:Destroy()
    end
    local lables = self.gachaModel:GetLabels()
    for i, v in ipairs(lables) do
        local leftTime = self.gachaModel:GetLeftTime(v)
        if leftTime then
            self:UpdateResidualTimeByTag(v, leftTime)
        end
    end
end

function StoreView:UpdateResidualTimeByTag(tag, time)
    if self.timerTable[tag] ~= nil then
        self.timerTable[tag]:Destroy()
    end

    self.timerTable[tag] = Timer.new(time, function (time)
        self.gachaModel:SetLeftTime(tag, time)
    end)
end

function StoreView:IsOpenMystery(isOpen,isActive)
    GameObjectHelper.FastSetActive(self.agentMenuObj, isOpen)
    GameObjectHelper.FastSetActive(self.agentTimelimit, isOpen and isActive)
end

function StoreView:HideAll()
    GameObjectHelper.FastSetActive(self.gachaContentArea, false)
    GameObjectHelper.FastSetActive(self.storeContentArea, false)
    GameObjectHelper.FastSetActive(self.giftBoxContentArea, false)
    GameObjectHelper.FastSetActive(self.agentContentArea, false)
end

function StoreView:InitStoreItemView(items)
    self.menuGroup:selectMenuItem(StoreModel.MenuTags.ITEM)
    GameObjectHelper.FastSetActive(self.storeContentArea, true)
    GameObjectHelper.FastSetActive(self.gachaContentArea, false)
    GameObjectHelper.FastSetActive(self.giftBoxContentArea, false)
    GameObjectHelper.FastSetActive(self.agentContentArea, false)
end
--]]道具部分END

function StoreView:InitGiftBoxView(items)
    self.menuGroup:selectMenuItem(StoreModel.MenuTags.GACHA)
    GameObjectHelper.FastSetActive(self.storeContentArea, false)
    GameObjectHelper.FastSetActive(self.gachaContentArea, false)
    GameObjectHelper.FastSetActive(self.giftBoxContentArea, true)
    GameObjectHelper.FastSetActive(self.agentContentArea, false)

    res.ClearChildren(self.giftBoxItemList)
    for i, v in ipairs(items) do
        v.transform:SetParent(self.giftBoxItemList, false)
    end
end

---[[抽卡部分START
function StoreView:InitGachaView(model)
    self.menuGroup:selectMenuItem(StoreModel.MenuTags.GiftBox)
    GameObjectHelper.FastSetActive(self.storeContentArea, false)
    GameObjectHelper.FastSetActive(self.gachaContentArea, true)
    GameObjectHelper.FastSetActive(self.giftBoxContentArea, false)
    GameObjectHelper.FastSetActive(self.agentContentArea, false)
    self.gachaModel = model
    self:UpdateResidualTime()
end

-- 神秘经纪人
function StoreView:InitAgentView(model)
    self.menuGroup:selectMenuItem(StoreModel.MenuTags.Agent)
    GameObjectHelper.FastSetActive(self.storeContentArea, false)
    GameObjectHelper.FastSetActive(self.gachaContentArea, false)
    GameObjectHelper.FastSetActive(self.giftBoxContentArea, false)
    GameObjectHelper.FastSetActive(self.agentContentArea, true)

    self:InitAgent(model, self.agentContentArea)
end

function StoreView:InitAgent(model, content)
    if self.initAgent then 
        self.initAgent(model, content)
    end
end

function StoreView:InitLabelTab(labelTab, clickFunc)
    if type(labelTab) == "table" then
        if #labelTab <= 4 then
            GameObjectHelper.FastSetActive(self.gachaMenuLimit4.gameObject, true)
            GameObjectHelper.FastSetActive(self.gachaMenuOver4, false)
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/Store/GachaLabel.prefab"
            for i, v in ipairs(labelTab) do
                local tag = v
                local obj, spt = res.Instantiate(prefab)
                local title = self.gachaModel:GetLabelTitle(v)
                spt:Init(title, self.gachaModel:NeedShowRedPoint(tag), tag, self.gachaModel:GetLayout(tag))
                obj.transform:SetParent(self.gachaMenuLimit4, false)
                self.gachaMenuGroup.menu[tag] = spt
                self.gachaMenuGroup:BindMenuItem(tag, function()
                    clickFunc(tag)
                end)
                self.gachaRedPointTable[tag] = self.gachaModel:NeedShowRedPoint(tag)
            end
        else
            GameObjectHelper.FastSetActive(self.gachaMenuLimit4.gameObject, false)
            GameObjectHelper.FastSetActive(self.gachaMenuOver4, true)
            self.gachaMenuScroll:regOnResetItem(function (scrollSelf, spt, index)
                local tag = scrollSelf.itemDatas[index]
                local title = self.gachaModel:GetLabelTitle(tag)
                spt:Init(title, self.gachaModel:NeedShowRedPoint(tag), tag, self.gachaModel:GetLayout(tag))
                self.gachaRedPointTable[tag] = self.gachaModel:NeedShowRedPoint(tag)
                self.gachaMenuGroup.menu[tag] = spt
                self.gachaMenuGroup:BindMenuItem(tag, function()
                    clickFunc(tag)
                end)
                scrollSelf:updateItemIndex(spt, index)
            end)
            self.gachaMenuScroll:refresh(labelTab)
        end
        self:SetGachaRedPoint()
    end
end

function StoreView:SetGachaRedPoint(isShowGachaRedPoint)
    if isShowGachaRedPoint == nil then 
        local needShowGachaRedPoint = false
        for k, v in pairs(self.gachaRedPointTable) do
            if v then
                needShowGachaRedPoint = true
            end
        end
        GameObjectHelper.FastSetActive(self.gachaRedPoint, needShowGachaRedPoint)
    else
        GameObjectHelper.FastSetActive(self.gachaRedPoint, isShowGachaRedPoint)
    end
end

function StoreView:ClearAllLabels()
    res.ClearChildren(self.gachaMenuLimit4)
    self.gachaMenuScroll:clearData()

    self.gachaMenuGroup:UnbindAll()
    self.gachaMenuGroup.menu = {}
    self.gachaMenuGroup.currentMenuTag = nil
end

function StoreView:OnClickLabel(tag)
    self.gachaModel:SetLabelTag(tag)
    self.curTag = tag
    if self.cardName then
        self.cardName.text = lang.trans("store_card_package", self.gachaModel:GetLabelTitle(tag))
    end
    self.gachaAnimator:Play()
    EventSystem.SendEvent("Change_Gacha_Label", tag)

    local isNormal = self.gachaModel:IsTagNormalGacha(tag)
    if isNormal then
        local isHaveFreeTime = self.gachaModel:IsHaveFreeTime(tag)
        -- 有免费次数，点击不取消红点
        if isHaveFreeTime then
            self.gachaMenuGroup.menu[tag]:SetRedPoint(true)
            self.gachaRedPointTable[tag] = true
            return
        end
    end

    self.gachaMenuGroup.menu[tag]:SetRedPoint(false)
    self.gachaRedPointTable[tag] = false
    self:SetGachaRedPoint()
    
    
end

local BoardTypeDict = {
    Board1 = "board1",
    Board2 = "board2",
    StepUp = "board3",
}

-- 设置下方的文字提示部分
function StoreView:SetBoard(boardType, text1, text2, text3, curStep)
    for k, v in pairs(BoardTypeDict) do
        GameObjectHelper.FastSetActive(self[v].gameObject, false)
        if boardType == k then
            GameObjectHelper.FastSetActive(self[v].gameObject, true)
            self[v]:Init(text1, text2, text3, curStep)
        end
    end
end

local LayoutDict = {
    [0] = "banner0",
    [1] = "banner1",
    [2] = "banner2",
    [3] = "banner3",
}

-- 设置整个海报部分
function StoreView:SetBanner(layout, bannerPic, artWordsPic, leftTime, cardDisplay)
    for k, v in pairs(LayoutDict) do
        GameObjectHelper.FastSetActive(self[v].gameObject, false)
        if tonumber(layout) == k then
            GameObjectHelper.FastSetActive(self[v].gameObject, true)
            self[v]:Init(bannerPic, artWordsPic, leftTime, cardDisplay)
        end
    end
end

function StoreView:SetBuyOnePrice(price)
    if tonumber(price) > 0 then
        GameObjectHelper.FastSetActive(self.buyOne.gameObject, true)
        self.onePrice.text = "x " .. price
        if self.priceType == "item" and ItemsMapModel.new():GetItemNum(CommonConstants.OneTicket) > 0 then
            self.onePrice.text = "x " .. "1"
        end
    else
        GameObjectHelper.FastSetActive(self.buyOne.gameObject, false)
    end
end

function StoreView:SetBuyTenPrice(price)
    if tonumber(price) > 0 then
        GameObjectHelper.FastSetActive(self.buyTen.gameObject, true)
        self.tenPrice.text = "x " .. price
        if (self.priceType == "item" or self.priceType == "free") and ItemsMapModel.new():GetItemNum(CommonConstants.TenTicket) > 0 then
            self.tenPrice.text = "x " .. "1"
        end
    else
        GameObjectHelper.FastSetActive(self.buyTen.gameObject, false)
    end
end

function StoreView:SetFinished(isFinished)
    if isFinished then
        GameObjectHelper.FastSetActive(self.finishedBtn, true)
    else
        GameObjectHelper.FastSetActive(self.finishedBtn, false)
    end
end

function StoreView:SetTicketCount(oneCount, tenCount)
    self.oneTicketCount.text = tostring(oneCount)
    self.tenTicketCount.text = tostring(tenCount)

    for k, v in pairs(self.iconImg) do
        for k1, v1 in pairs(v) do
            GameObjectHelper.FastSetActive(v1, false)
        end
    end

    if oneCount > 0 then
        GameObjectHelper.FastSetActive(self.iconImg.item.img1, true)
    else
        GameObjectHelper.FastSetActive(self.iconImg.d.img1, true)
    end
    if tenCount > 0 then
        GameObjectHelper.FastSetActive(self.iconImg.item.img2, true)
    else
        GameObjectHelper.FastSetActive(self.iconImg.d.img2, true)
    end
    GameObjectHelper.FastSetActive(self.iconImg.item.img1, true)
    GameObjectHelper.FastSetActive(self.iconImg.item.img2, true)
end

-- d item fp
function StoreView:RefreshIconWithTicket(priceType, isNormalGacha, countDown)
    self.priceType = priceType
    -- 有免费次数
    if priceType == "free" then
        GameObjectHelper.FastSetActive(self.onePrice.gameObject, false)
        GameObjectHelper.FastSetActive(self.iconImg.d.img1, false)
        GameObjectHelper.FastSetActive(self.iconImg.item.img1, false)
        GameObjectHelper.FastSetActive(self.freeTxtGO, true)
        return
    end

    GameObjectHelper.FastSetActive(self.freeTxtGO, false)
    GameObjectHelper.FastSetActive(self.onePrice.gameObject, true)

    if isNormalGacha then
        GameObjectHelper.FastSetActive(self.alarm, true)

        if self.freeGachaTimer ~= nil then
            self.freeGachaTimer:Destroy()
        end

        local tag = self.curTag
        self.freeGachaTimer = Timer.new(countDown, function(time)
            self.alarmTxt.text = string.convertSecondToTime(time)
            self.gachaModel:SetNormalGachaTime(tag, time)
        end, function(isTimeNotEnd)
            -- 恰好可以免费抽
            if not isTimeNotEnd then
                GameObjectHelper.FastSetActive(self.alarm, false)
                GameObjectHelper.FastSetActive(self.freeTxtGO, true)
                GameObjectHelper.FastSetActive(self.iconImg.d.img1, false)
                GameObjectHelper.FastSetActive(self.iconImg.item.img1, false)
                GameObjectHelper.FastSetActive(self.iconImg.fp.img1, false)
                GameObjectHelper.FastSetActive(self.onePrice.gameObject, false)
            end
        end)
    else
        GameObjectHelper.FastSetActive(self.alarm, false)
    end

    -- 消耗友情值
    if priceType == "fp" then
        for k, v in pairs(self.iconImg) do
            if k == "fp" then
                for k1, v1 in pairs(v) do
                    GameObjectHelper.FastSetActive(v1, true)
                end
            else
                for k1, v1 in pairs(v) do
                    GameObjectHelper.FastSetActive(v1, false)
                end
            end
        end
        return
    end
    -- 消耗钻石
    if priceType == "d" then
        for k, v in pairs(self.iconImg) do
            if k == "item" then
                for k1, v1 in pairs(v) do
                    GameObjectHelper.FastSetActive(v1, true)
                end
            else
                for k1, v1 in pairs(v) do
                    GameObjectHelper.FastSetActive(v1, false)
                end
            end
        end
        return
    end
end

function StoreView:OnDetailBtnClick(func)
    self.cardLibraryBtn:regOnButtonClick(func)
end

function StoreView:SetBtnCardLibraryEnable(status)
    self.btnCardLibraryEnable = status
end

function StoreView:GetBtnCardLibraryEnable()
    return self.btnCardLibraryEnable
end

function StoreView:SetFriendPoint(fp)
    if type(fp) == "number" then
        GameObjectHelper.FastSetActive(self.friendPointArea, true)
        self.friendPointValue.text = format("X %d", fp)
    else
        GameObjectHelper.FastSetActive(self.friendPointArea, false)
    end
end

-- 暂时只有友情抽和新手抽不显示
function StoreView:SetTicketArea(itemUse)
    GameObjectHelper.FastSetActive(self.ticketArea, tostring(itemUse) ~= "0" and self.curTag ~= "C1" and self.curTag ~= "B2")

    GameObjectHelper.FastSetActive(self.consumeTicket.one, tostring(itemUse) ~= "0" and
        ItemsMapModel.new():GetItemNum(CommonConstants.OneTicket) > 0 and self.curTag ~= "C1" and self.curTag ~= "B2")
    GameObjectHelper.FastSetActive(self.consumeTicket.ten, tostring(itemUse) ~= "0" and
        ItemsMapModel.new():GetItemNum(CommonConstants.TenTicket) > 0 and self.curTag ~= "C1" and self.curTag ~= "B2")
end

function StoreView:OnAnimStart()

end

function StoreView:OnAnimEnd()

end

--]]抽卡部分END

function StoreView:onDestroy()
    for k, v in pairs(self.timerTable) do
        v:Destroy()
    end
    if self.freeGachaTimer ~= nil then
        self.freeGachaTimer:Destroy()
    end
end

return StoreView

