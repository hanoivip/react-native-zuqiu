local BaseCtrl = require("ui.controllers.BaseCtrl")

local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GachaTenCtrl = require("ui.controllers.gacha.GachaTenCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local ChargeItemCtrl = require("ui.controllers.store.ChargeItemCtrl")
local GiftBoxItemCtrl = require("ui.controllers.store.GiftBoxItemCtrl")
local StoreModel = require("ui.models.store.StoreModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local GachaMainModel = require("ui.models.gacha.GachaMainModel")
local AgentCtrl = require("ui.controllers.store.AgentCtrl")
local MallCtrl = require("ui.controllers.store.MallCtrl")
local MusicManager = require("ui.control.manager.MusicManager")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local CustomEvent = require("ui.common.CustomEvent")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CommonConstants = require("ui.common.CommonConstants")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local Timer = require('ui.common.Timer')
local EventSystem = require("EventSystem")

local StoreCtrl = class(BaseCtrl, "StoreCtrl")

StoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Store/Store.prefab"

local function IsInTable(e, t)
    for i, v in ipairs(t) do
        if v == e then
            return true
        end
    end
    return false
end

-- tag只能是gacha和item
function StoreCtrl:Init(tag)
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self, true, nil, true)
        self.infoBarCtrl:RegOnBtnBack(function ()
            self.view:PlayLeaveAnimation()
            StoreModel.ResetStateDefault()
        end)
        self.view:RegOnLeaveComplete(function()
            clr.coroutine(function()
                unity.waitForEndOfFrame()
                res.PopSceneImmediate()
                -- 关闭抽卡界面
                GuideManager.Show(res.curSceneInfo.ctrl)
            end)
        end)
    end)
    self.view:RegOnMenuGroup(StoreModel.MenuTags.ITEM, function ()
        StoreModel.ResetStateDefault()
        self:RecruitRewardController(false)
        self:SwitchMenu(StoreModel.MenuTags.ITEM)
    end)
    self.view:RegOnMenuGroup(StoreModel.MenuTags.GACHA, function ()
        self:RecruitRewardController(false)
        self:SwitchMenu(StoreModel.MenuTags.GiftBox)
    end)
    self.view:RegOnMenuGroup(StoreModel.MenuTags.GiftBox, function ()
        self:SwitchMenu(StoreModel.MenuTags.GACHA, nil, self.isBuyOne, self.resp, self.gachaModel and self.gachaModel:GetLabelTag())
    end)
    self.view:RegOnMenuGroup(StoreModel.MenuTags.Agent, function ()
        self:RecruitRewardController(false)
        self:SwitchMenu(StoreModel.MenuTags.Agent)
    end)
    self.view.clickBtnBuyOne = function()
        local priceType = self.gachaModel:GetPriceType()
        if not GuideManager.GuideIsOnGoing("main") and (priceType == "d" or priceType == "item" and tonumber(ItemsMapModel.new():GetItemNum(CommonConstants.OneTicket)) <= 0) then
            local cost = self.gachaModel:GetPrice()
            local step = self.gachaModel:GetCurrentStep()
            local message = lang.trans("gacha_normal_one")
            if step then
                message = lang.trans("gacha_limit_step" .. step)
            end
            DialogManager.ShowConfirmPop(lang.trans("tips"), message, function ()
                self:OnBtnBuyOneClick()
            end, nil)
        else
            self:OnBtnBuyOneClick()
        end
    end
    self.view.clickBtnBuyTen = function()
        self:TenViewBuyTenClick()
    end

    self.view:OnDetailBtnClick(function() self:OnBtnDetailClick() end)

    self.view.clickRecruitReward = function() self:OnBtnRecruitReward() end

    self.view.initAgent = function(model, content) self:InitAgent(model, content) end

    self.view:SetBtnCardLibraryEnable(true)
end

function StoreCtrl:OnBtnRecruitReward()
    if self.isRecruitReward and self.isRecruitReward == "RecruitRewardActivity" then
        res.PopScene()
    else
        res.PushScene("ui.controllers.activity.ActivityCtrl", "TimeLimitGacha")
    end
end

function StoreCtrl:RecruitRewardController(isShow)
    self.view:RegOnRecruitRewardBtn(isShow)
end

function StoreCtrl:TenViewBuyTenClick(success)
    local priceType = self.gachaModel:GetPriceType()
    if priceType == "d" or ((priceType == "item" or priceType == "free") and tonumber(ItemsMapModel.new():GetItemNum(CommonConstants.TenTicket)) <= 0) then
        local cost = self.gachaModel:GetTenPrice()
        local step = self.gachaModel:GetCurrentStep()
        local message = lang.trans("gacha_normal_ten")
        if step then
            message = lang.trans("gacha_limit_step" .. step)
        end
        DialogManager.ShowConfirmPop(lang.trans("tips"), message, function ()
            self:OnBtnBuyTenClick(success)
        end, self.OnBtnBuyTenCancle)
    else
        self:OnBtnBuyTenClick(success)
    end
end

function StoreCtrl:InitAgent(model, content)
    if not self.agentCtrl then 
        self.agentCtrl = AgentCtrl.new(nil, content)
    end

    self.agentCtrl:InitView(model, self.mysteryLastTime)
end

function StoreCtrl:GetRecruitRewardActState()
    local activityInfo = cache.getRecruitRewardPhase()
    if not activityInfo then
        return false
    else
        return activityInfo.isActive
    end
end

function StoreCtrl:GetRecruitRewardActEndTime()
    local activityInfo = cache.getRecruitRewardPhase()
    return activityInfo.activityEndTime
end

function StoreCtrl:OnEnterScene()
    self:RecruitRewardController(false)
    -- TODO 解决一个bug，暂时先这么改
    if not self.tmpReflectivePrefab then
        self.tmpReflectivePrefab = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/TrophyRenderRoot.prefab")
    end

    -- 进入游戏
    luaevt.trig("Enter_Into_Store")

    EventSystem.AddEvent("BuyStoreItem", self, self.RefreshCurrentPage)
    EventSystem.AddEvent("CongratulationsPageClosed", self, self.GotoiOSStore)
    EventSystem.AddEvent("CardLibraryStatus", self, self.SetBtnCardLibraryEnable)
    EventSystem.AddEvent("SwitchMenu", self, self.SwitchMenu)
end

function StoreCtrl:OnExitScene()
    if self.mallCtrl then
        self.mallCtrl:OnExitScene()
    end
    if self.tmpReflectivePrefab then
        if self.tmpReflectivePrefab ~= clr.null then
            clr.UnityEngine.Object.Destroy(self.tmpReflectivePrefab)
        end
        self.tmpReflectivePrefab = nil
    end

    EventSystem.RemoveEvent("CongratulationsPageClosed", self, self.GotoiOSStore)
    EventSystem.RemoveEvent("BuyStoreItem", self, self.RefreshCurrentPage)
    EventSystem.RemoveEvent("CardLibraryStatus", self, self.SetBtnCardLibraryEnable)
    EventSystem.RemoveEvent("SwitchMenu", self, self.SwitchMenu)
    self.resp = nil
    self.isBuyOne = nil
    self.view:HideAll()
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
end

function StoreCtrl:OnClickLabel(tag)
    self.tempTag = tag
    -- 静默发送请求，告诉服务器玩家已经切换到这个标签页了，同时去掉红点显示
    clr.coroutine(function()
        req.storeView(tag)
    end)
    self.view:OnClickLabel(tag)
    self.view:SetFinished(self.gachaModel:IsFinished())
    self.view:SetTicketCount(ItemsMapModel.new():GetItemNum(CommonConstants.OneTicket),ItemsMapModel.new():GetItemNum(CommonConstants.TenTicket))
    self.view:RefreshIconWithTicket(self.gachaModel:GetPriceType(), self.gachaModel:IsTagNormalGacha(tag), self.gachaModel:GetCountDownTime(tag))
    self.view:SetFriendPoint(self.gachaModel:GetFriendshipPoint())
    self.view:SetTicketArea(self.gachaModel:GetIsUseTicket(tag))
    if self.gachaModel:GetPriceType() == "fp" then
        self.view:SetBuyOnePrice(self.gachaModel:GetPrice())
        self.view:SetBuyTenPrice(self.gachaModel:GetTenPrice())
    else
        self.view:SetBuyOnePrice(tonumber(self.gachaModel:GetPrice()) > 0 and 1 or 0)
        self.view:SetBuyTenPrice(tonumber(self.gachaModel:GetTenPrice()) > 0 and 1 or 0)
    end
    self.view:SetBoard(self.gachaModel:GetBoard(), self.gachaModel:GetText1(), self.gachaModel:GetText2(), self.gachaModel:GetText3(), self.gachaModel:GetCurrentStep())
    self.view:SetBanner(self.gachaModel:GetLayout(), self.gachaModel:GetBanner(), self.gachaModel:GetArtWords(), self.gachaModel:GetLeftTime(), self.gachaModel:GetCardDisplay())
end

function StoreCtrl:AheadRequest(tag, isNeedGachaRedPoint, isOpenMystery, isBuyOne, resp, gachaLabelTag, isBufeng, ClickItemID)
    local menuTags = StoreModel.MenuTags.GACHA
    clr.coroutine(function()
        local response = req.storeDay()
        if api.success(response) then
            local data = response.val
            local today = data.createDays
            local listNull = data.listNull
            local isNeedShowGachaRedPoint = tobool(data.gacha == 1)
            if today < 7 then
                if not listNull then
                    menuTags = StoreModel.MenuTags.GiftBox
                end
            end

            if GuideManager.GuideIsOnGoing("main") then
                menuTags = StoreModel.MenuTags.GACHA
            end
            UIBgmManager.play("Store/storeEnter")
            local isOpenMystery = data.mystery and data.mystery.isOpen
            tag = tag or menuTags
            self.isNeedGachaRedPoint = isNeedShowGachaRedPoint
            self.isOpenMystery = isOpenMystery
            self.mysteryLastTime = data.mystery.activity.lastTime
            self.view:IsOpenMystery(isOpenMystery, data.mystery.activity.lastTime)
            self:SwitchMenu(tag, self.isNeedGachaRedPoint, isBuyOne, resp, gachaLabelTag, isBufeng, ClickItemID)
        end
    end)
end

-- tag只能是gacha和item
function StoreCtrl:Refresh(tag, isNeedGachaRedPoint, isOpenMystery, isBuyOne, resp, gachaLabelTag, isBufeng, ClickItemID, isRecruitReward)
    self.isRecruitReward = isRecruitReward
    StoreCtrl.super.Refresh(self)
end

function StoreCtrl:GetStatusData()
    if self.tag == StoreModel.MenuTags.ITEM or self.tag == StoreModel.MenuTags.GiftBox or self.tag == StoreModel.MenuTags.Agent then
        return self.tag, self.isNeedGachaRedPoint, self.isOpenMystery
    else
        return self.tag, self.isNeedGachaRedPoint, self.isOpenMystery, self.isBuyOne, self.resp, self.gachaModel:GetLabelTag()
    end
end

function StoreCtrl:OnBtnBuyOneClick()
    local isFree = self.gachaModel:IsHaveFreeTime(self.view.curTag)

    if not isFree and self.view.curTag ~= "C1" and ItemsMapModel.new():GetItemNum(CommonConstants.OneTicket) <= 0 then
        if PlayerInfoModel:new():GetDiamond() < tonumber(self.gachaModel:GetPrice(self.view.curTag)) then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_gacha_tip"), function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
            end, nil)
            return
        end
    end

    clr.coroutine(function()
        local response = req.buyOneCard(self.view.curTag)
        if api.success(response) then
            if next(response.val) then
                CustomEvent.GachaOne(self.view.curTag, response.val.cost.num)
                MusicManager.stop()
                clr.coroutine(function()
                    unity.waitForEndOfFrame()
                    self.isBuyOne = true
                    --self.resp = response.val
                    local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
                    rewardUpdateCacheModel:UpdateCache(response.val.contents)
                    local playerInfoModel = PlayerInfoModel.new()
                    if response.val.cost.type == "d" then
                        local mInfo = {}
                        mInfo.phylum = "store"
                        mInfo.classfield = "gacha"
                        mInfo.genus = "one"
                        playerInfoModel:SetDiamond(response.val.cost.curr_num)
                        CustomEvent.ConsumeDiamond("6", response.val.cost.num, mInfo)
                    elseif response.val.cost.type == "fp" then
                        playerInfoModel:SetFriendshipPoint(response.val.cost.curr_num)
                    elseif response.val.cost.item ~= nil then
                        ItemsMapModel.new():ResetItemNum(response.val.cost.item.id, response.val.cost.item.num)
                    end
                    clr.coroutine(function()
                    local response = req.storeInfo()
                        if api.success(response) then
                            self.gachaModel:InitData(response.val)
                            self:OnClickLabel(self.tempTag)
                        end
                    end)
                    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Congratulations/Congratulations.prefab", "camera", true, true)
                    local script = dialogcomp.contentcomp
                    local playerInfoModel = PlayerInfoModel.new()
                    script:InitView(response.val.contents, playerInfoModel)
                    script:SetShareBtnVisible(not GuideManager.GuideIsOnGoing("main") and cache.getIsOpenShareSDK())
                    GuideManager.Show(self)
                end)
            end
        end
    end)
    if GuideManager.GuideIsOnGoing("main") then
        GuideManager.HideLastGuide()
    end
end

function StoreCtrl:OnBtnBuyTenClick(onSuccess)
    if self.view.curTag ~= "C1" and ItemsMapModel.new():GetItemNum(CommonConstants.TenTicket) <= 0 then
        if PlayerInfoModel:new():GetDiamond() < tonumber(self.gachaModel:GetTenPrice(self.view.curTag)) then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_gacha_tip"), function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
            end, self.OnBtnBuyTenCancle)
            self:OnBtnBuyTenCancle()
            return
        end
    end

    clr.coroutine(function()
        local response = req.buyTenCard(self.view.curTag)
        if api.success(response) then
            if next(response.val) then
                CustomEvent.GachaTen(self.view.curTag, response.val.cost.num)
                MusicManager.stop()
                clr.coroutine(function()
                    unity.waitForEndOfFrame()
                    self.isBuyOne = false
                    --self.resp = response.val
                    local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
                    rewardUpdateCacheModel:UpdateCache(response.val.contents)
                    local playerInfoModel = PlayerInfoModel.new()
                    if response.val.cost.type == "d" then
                        playerInfoModel:SetDiamond(response.val.cost.curr_num)
                        local mInfo = {}
                        mInfo.phylum = "store"
                        mInfo.classfield = "gacha"
                        mInfo.genus = "ten"
                        CustomEvent.ConsumeDiamond("6", response.val.cost.num, mInfo)
                    elseif response.val.cost.type == "fp" then
                        playerInfoModel:SetFriendshipPoint(response.val.cost.curr_num)
                    elseif response.val.cost.item ~= nil then
                        ItemsMapModel.new():ResetItemNum(response.val.cost.item.id, response.val.cost.item.num)
                    end
                    if type(onSuccess) == "function" then
                        onSuccess()
                    end
                    clr.coroutine(function()
                    local response = req.storeInfo()
                        if api.success(response) then
                            self.gachaModel:InitData(response.val)
                            self:OnClickLabel(self.tempTag)
                        end
                    end)
                    GachaTenCtrl.new(response.val.contents, self)
                end)
            else
                self:OnBtnBuyTenCancle()
            end
        else
            self:OnBtnBuyTenCancle()
        end
    end)
end

function StoreCtrl:OnBtnBuyTenCancle()
    EventSystem.SendEvent("CardLibraryStatus", true)
end

function StoreCtrl:RefreshCurrentPage()
    self:SwitchMenu(self.tag)
end

function StoreCtrl:OnBtnDetailClick()
    if self.view:GetBtnCardLibraryEnable() then
        res.PushDialog("ui.controllers.gacha.GachaDetailCtrl", self.gachaModel)
    end
end

function StoreCtrl:SetBtnCardLibraryEnable(status)
    self.view:SetBtnCardLibraryEnable(status)
end

function StoreCtrl:SwitchMenu(tag, isNeedGachaRedPoint, isBuyOne, resp, gachaLabelTag, isBufeng, ClickItemID)
    self.tag = tag
    self.view:coroutine(function ()
        local items = {}
        if tag == StoreModel.MenuTags.GACHA then
            -- 抽卡
            local response = req.storeInfo()
            if api.success(response) then
                self.gachaModel = GachaMainModel.new()
                self.gachaModel:InitData(response.val)

                self.labelTab = self.gachaModel:GetLabels()
                self.view:InitGachaView(self.gachaModel)
                self.view:ClearAllLabels()

                self.view:InitLabelTab(self.labelTab, function(labelTag)
                    self:OnClickLabel(labelTag)
                end)

                if (not gachaLabelTag or not IsInTable(gachaLabelTag, self.labelTab)) and #self.labelTab >= 1 then
                    gachaLabelTag = self.labelTab[1]
                end
                self.view.gachaMenuGroup:selectMenuItem(gachaLabelTag)
                self:OnClickLabel(gachaLabelTag)

                local isRecruitRewardActive = self:GetRecruitRewardActState() or false
                self:RecruitRewardController(isRecruitRewardActive)
                if isRecruitRewardActive then
                    self:CheckActivityEnd()
                end

                if resp then
                    if isBuyOne then
                        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Congratulations/Congratulations.prefab", "camera", true, true)
                        local script = dialogcomp.contentcomp
                        local playerInfoModel = PlayerInfoModel.new()
                        script:InitView(resp.contents, playerInfoModel)
                        -- 抽卡动画结束后
                        GuideManager.Show(self)
                    else
                        GachaTenCtrl.new(resp.contents, self)
                    end
                end
            end
        elseif tag == StoreModel.MenuTags.ITEM then
            -- 购买功能
            if isNeedGachaRedPoint ~= nil  then 
                --只有在进入商店跳转为特殊礼包和购买功能是检查抽卡的红点是否显示正确
                --但根据服务器架构又只可以在进入商店时传递该参数，所以对该参数做是否为空的判断
                self.view:SetGachaRedPoint(isNeedGachaRedPoint)
            end

            if not self.mallCtrl then 
                self.mallCtrl = MallCtrl.new(self.view.storeContentArea)
            end
            self.mallCtrl:InitView(StoreModel.GetMallPageType())
            self.view:InitStoreItemView()
        elseif tag == StoreModel.MenuTags.GiftBox then
            -- 特惠礼盒
            local curItems = {}
            if isNeedGachaRedPoint ~= nil  then 
                self.view:SetGachaRedPoint(isNeedGachaRedPoint)
            end
            local response = req.giftBoxList()
            if api.success(response) then
                local data = response.val
                table.sort(data.list, function (a, b)
                    return a.order < b.order
                end)
                for k, v in pairs(data.list) do
                    if v.lastTime ~= 0 or v.lastTime == nil then
                        local item = nil
                        local isClickShow = ClickItemID and (v.ID == ClickItemID)
                        item = GiftBoxItemCtrl.new(v, isBufeng, isClickShow)
                        if  item.model:IsCanBuy() then 
                            table.insert(items, item.view)
                        else
                            table.insert(curItems, item.view)
                        end
                    end
                end
                --因为该数据已经在服务器端做了需求排序
                --为了维持之前传递的顺序，添加另一组table用来存储已购的数据，之后插入列表
                if curItems ~= nil then 
                    for m, v in pairs(curItems) do 
                        table.insert(items, v)
                    end
                end
                self.view:InitGiftBoxView(items)
            end
        elseif tag == StoreModel.MenuTags.Agent then
            self.view:InitAgentView()
        end
    end)
end

function StoreCtrl:CheckActivityEnd()
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    local beforeEndInterval = tonumber(self:GetRecruitRewardActEndTime()) - serverTimeNow
    if beforeEndInterval <= 0 then
        self:RecruitRewardController(false)
        return
    end

    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(beforeEndInterval, function(time)
        if time <= 0 then
            self:RecruitRewardController(false)
        end
    end)
end

-- 单抽才会使用庆祝面板，所以只有一张卡
function StoreCtrl:GotoiOSStore(rewardData)
    local isHave = cache.getIsHasSSCard()
    if isHave then return end
    
    if rewardData and rewardData.card ~= nil and clr.plat == "IPhonePlayer" and self.tag == StoreModel.MenuTags.GACHA then
        local quality = StaticCardModel.new(rewardData.card[1].cid):GetCardQuality()
        if tonumber(quality) >= tonumber(CommonConstants.PlatinumID) then
            res.PushDialog("ui.control.guideComment.GoodGuideCtrl", true)
            cache.setIsHasSSCard(true)
        end
    end
end

return StoreCtrl

