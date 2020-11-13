local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds

local DialogManager = require("ui.control.manager.DialogManager")
local StoreCtrl = require("ui.controllers.store.StoreCtrl")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")

local EventSystem = require("EventSystem")

local LuckyWheelView = class(ActivityParentView)

function LuckyWheelView:ctor()
    -- 活动时间
    self.activityTime = self.___ex.activityTime
    self.btnDiscountStore = self.___ex.btnDiscountStore
    self.btnStartWheel = self.___ex.btnStartWheel
    self.btnTips = self.___ex.btnTips
    self.txtRestTimes = self.___ex.txtRestTimes
    self.wheelItems = self.___ex.wheelItems -- table
    self.wheelNums = table.nums(self.wheelItems)
    self.isRequesting = false
    self.isAnimationPlaying = false
    self.circleCount = 0
end

function LuckyWheelView:InitView(luckyWheelModel)
    self.luckyWheelModel = luckyWheelModel
    self:BuildView()
end

function LuckyWheelView:start()
    self.btnTips:regOnButtonClick(function()
        res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheel/LuckyWheelDescBoard.prefab", "camera", false, true)
    end)
    self.btnDiscountStore:regOnButtonClick(function()
        if type(self.onDiscountStore) == "function" then
            self.onDiscountStore()
        end
    end)
    self.btnStartWheel:regOnButtonClick(function()
        if self.isAnimationPlaying then return end

        if type(self.onStartDial) == "function" then
            for k, itemViewSpt in pairs(self.wheelItems) do
                itemViewSpt:SetDefault()
            end
            self.onStartDial(function()
                self.isRequesting = true
            end,
            function()
                return self.isAnimationPlaying
            end)
        end

        -- 开始转盘动画
        if self.isRequesting then
            self:StartDialAnimation()
        end
    end)
end

-- 转盘最大速度（单位时间内通过的点）
local maxSpeed = 30
local minSpeed = 10
-- 加速时间
local accelerateTime = 0.5
-- @prarm relativeTime 相对时间
-- @param isPositive 加速或减速
local function getSpeed(relativeTime, isPositive)
    relativeTime = math.clamp(relativeTime, 0, accelerateTime)
    local normalizedTime = (math.pi * relativeTime) / (2 * accelerateTime)
    if isPositive then
        return minSpeed + math.sin(normalizedTime) * (maxSpeed - minSpeed)
    else
        return minSpeed + math.cos(normalizedTime) * (maxSpeed - minSpeed)
    end
end

function LuckyWheelView:GetNextHighlightIndex(currentIndex)
    if currentIndex + 1 > self.wheelNums then
        self.circleCount = self.circleCount + 1
        return 1
    else
        return currentIndex + 1
    end
end

function LuckyWheelView:StartDialAnimation()
    self:coroutine(function()
        self.circleCount = 0
        self.currentRewardIndex = nil
        self.nextHighlightIndex = 1
        self.isAnimationPlaying = true
        local startDialTime = Time.time
        local intervalTime = 0.1
        -- while true do
        while self.isRequesting or self.circleCount < 3 do
            intervalTime = 1 / getSpeed(Time.time - startDialTime, true)
            coroutine.yield(WaitForSeconds(intervalTime))
            local itemViewSpt = self.wheelItems["w" .. tostring(self.nextHighlightIndex)]
            itemViewSpt:SetHighlight()
            self.nextHighlightIndex = self:GetNextHighlightIndex(self.nextHighlightIndex)
        end
        -- 减速
        if self.currentRewardIndex then
            startDialTime = Time.time
            while true do
                -- intervalTime = 1 / getSpeed(Time.time - startDialTime, false)
                coroutine.yield(WaitForSeconds(intervalTime))
                local itemViewSpt = self.wheelItems["w" .. tostring(self.nextHighlightIndex)]
                itemViewSpt:SetHighlight()
                if self.nextHighlightIndex == self.currentRewardIndex then
                    itemViewSpt:SetShining()
                    coroutine.yield(WaitForSeconds(1))
                    self.isAnimationPlaying = false

                    break
                end
                self.nextHighlightIndex = self:GetNextHighlightIndex(self.nextHighlightIndex)
            end
        end
    end)
end

function LuckyWheelView:BuildView()
    local startTime = self.luckyWheelModel:GetStartTime()
    local endTime = self.luckyWheelModel:GetEndTime()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.formatTimestampNoYear(startTime), string.formatTimestampNoYear(endTime))

    self:SetRestTimes(self.luckyWheelModel:GetRestTimes())

    -- 构建转盘的18个奖项
    local wheelItemsCount = self.luckyWheelModel:GetWheelItemsCount()
    for i = 1, wheelItemsCount do
        local itemData = self.luckyWheelModel:GetWheelItemDataByIndex(i)
        local itemViewSpt = self.wheelItems["w" .. tostring(i)]
        -- 处理一下折扣券实际拥有的数量
        if type(itemData.coupon) == "table" and next(itemData.coupon) then
            itemData.coupon[1].ownNum = self.luckyWheelModel:GetCouponNum(itemData.coupon[1].id)
        end
        itemViewSpt:InitView(itemData)
    end
end

function LuckyWheelView:SetRestTimes(times)
    self.txtRestTimes.text = lang.trans("luckyWheel_remainTimes", tostring(times))
end

function LuckyWheelView:SetRewardHighlightByIndex(index)
    self.isRequesting = false
    self.currentRewardIndex = index
end

function LuckyWheelView:OnVIPLevelUp()
    -- VIP等级提升时需要刷新剩余的转盘次数
    if type(self.resetRestTimes) == "function" then
        self.resetRestTimes(function(times)
            self:SetRestTimes(times)
        end)
    end
end

function LuckyWheelView:OnEnterScene()
    LuckyWheelView.super.OnEnterScene(self)
    EventSystem.AddEvent("LuckyWheelModel_SetRestTimes", self, self.SetRestTimes)
    EventSystem.AddEvent("LuckyWheelModel_SetCurrentRewardIndex", self, self.SetRewardHighlightByIndex)
    EventSystem.AddEvent("VIPLevelUpInVIPPage", self, self.OnVIPLevelUp)
end

function LuckyWheelView:OnExitScene()
    LuckyWheelView.super.OnExitScene(self)
    EventSystem.RemoveEvent("LuckyWheelModel_SetRestTimes", self, self.SetRestTimes)
    EventSystem.RemoveEvent("LuckyWheelModel_SetCurrentRewardIndex", self, self.SetRewardHighlightByIndex)
    EventSystem.RemoveEvent("VIPLevelUpInVIPPage", self, self.OnVIPLevelUp)

    self.isAnimationPlaying = false
end

function LuckyWheelView:onDestroy()
    self.isAnimationPlaying = false    
end

return LuckyWheelView