local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local LuckyWheelView = require("ui.scene.activity.content.LuckyWheelView")
local LuckyWheelViewEx = class(LuckyWheelView)

function LuckyWheelViewEx:ctor()
    LuckyWheelViewEx.super.ctor(self)
    self.btnOneIndiana = self.___ex.btnOneIndiana
    self.btnMoreIndiana = self.___ex.btnMoreIndiana
    self.oneBuyText = self.___ex.oneBuyText
    self.moreBuyText = self.___ex.moreBuyText
    self.oneBuyCost = self.___ex.oneBuyCost
    self.moreBuyCost = self.___ex.moreBuyCost
    self.pointScroll = self.___ex.pointScroll
    self.scrollRect = self.___ex.scrollRect
    self.contentRect = self.___ex.contentRect
    self.arrow = self.___ex.arrow
    self.openCount = self.___ex.openCount
    -- 跳过动画
    self.tglSkipAnim = self.___ex.tglSkipAnim
end

function LuckyWheelViewEx:InitView(luckyWheelExModel)
    self.luckyWheelExModel = luckyWheelExModel
    self:BuildView()
end

function LuckyWheelViewEx:start()
    self.btnTips:regOnButtonClick(function()
        DialogManager.ShowAlertAlignmentPop(lang.trans("instruction"), lang.trans("indiana_tip_desc"), 3)
    end)

    self.btnOneIndiana:regOnButtonClick(function()
        self:IndianaOpen("oneGacha")
    end)

    self.btnMoreIndiana:regOnButtonClick(function()
        self:IndianaOpen("fiveGacha")
    end)
    -- 跳过动画
    self.tglSkipAnim:regOnButtonClick(function()
        self:OnToggleSkipAnim()
    end)
end

function LuckyWheelViewEx:IndianaOpen(indianaType)
    if self.isAnimationPlaying then return end

    if type(self.onIndianaStart) == "function" then
        for k, itemViewSpt in pairs(self.wheelItems) do
            itemViewSpt:SetDefault()
        end
        local reqStartCallback = function()
            self.isRequesting = true
        end
        local waitAnimationCallback = function()
            local gachaRewardIDs = self.luckyWheelExModel:GetCurrentRewardIds()
            if self.rewardCountOpen < table.nums(gachaRewardIDs) then 
                if not self.isAnimationPlaying then
                    self.isAnimationPlaying = true
                    self:SetNextRewardIndex(self.luckyWheelExModel:GetRewardIndex(self.rewardCountOpen + 1))
                end
                return true
            else
                return false
            end
        end
        self.onIndianaStart(reqStartCallback, waitAnimationCallback, indianaType)
    end
end

-- 开始转盘动画
function LuckyWheelViewEx:StartDial()
    self.isRequesting = true
    self:StartDialAnimation()
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

function LuckyWheelViewEx:StartDialAnimation()
    self:coroutine(function()
        self.circleCount = 0
        self.currentRewardIndex = nil
        self.nextHighlightIndex = 1
        self.intervalTime = 0.1
        self.rewardCountOpen = 0
        self.isAnimationPlaying = true
        local startDialTime = Time.time
        
        -- while true do
        while self.isRequesting or self.circleCount < 3 do
            self.intervalTime = 1 / getSpeed(Time.time - startDialTime, true)
            coroutine.yield(WaitForSeconds(self.intervalTime))
            local itemViewSpt = self.wheelItems["w" .. tostring(self.nextHighlightIndex)]
            itemViewSpt:SetHighlight()
            self.nextHighlightIndex = self:GetNextHighlightIndex(self.nextHighlightIndex)
        end

        -- 减速
        self:MoveToReward()
    end)
end

function LuckyWheelViewEx:MoveToReward()
    self:coroutine(function()
        if self.currentRewardIndex then
            while true do
                coroutine.yield(WaitForSeconds(self.intervalTime))
                local itemViewSpt = self.wheelItems["w" .. tostring(self.nextHighlightIndex)]
                itemViewSpt:SetHighlight()
                if self.nextHighlightIndex == self.currentRewardIndex then
                    itemViewSpt:SetShining()
                    coroutine.yield(WaitForSeconds(1))
                    self.isAnimationPlaying = false
                    self.rewardCountOpen = self.rewardCountOpen + 1
                    break
                end
                self.nextHighlightIndex = self:GetNextHighlightIndex(self.nextHighlightIndex)
            end
        end
    end)
end

function LuckyWheelViewEx:SetCurrentReward()
    self.isRequesting = false
    local firstIndex = self.luckyWheelExModel:GetRewardIndex(1)
    self.currentRewardIndex = firstIndex
end

function LuckyWheelViewEx:PlayingEnd()
    self.isRequesting = false
    self.isAnimationPlaying = false
end

function LuckyWheelViewEx:SetNextRewardIndex(index)
    self.currentRewardIndex = index
    self.nextHighlightIndex = self:GetNextHighlightIndex(self.nextHighlightIndex)
    self:MoveToReward()
end

local Indiana_Buy_One = 1
local Indiana_Buy_More = 5
function LuckyWheelViewEx:BuildView()
    local startTime = self.luckyWheelExModel:GetStartTime()
    local endTime = self.luckyWheelExModel:GetEndTime()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.formatTimestampNoYear(startTime), string.formatTimestampNoYear(endTime))
    self.oneBuyText.text = lang.trans("indiana_buy", Indiana_Buy_One)
    self.moreBuyText.text = lang.trans("indiana_buy", Indiana_Buy_More)
    self.oneBuyCost.text = "x" .. self.luckyWheelExModel:GetOneIndianaCost()
    self.moreBuyCost.text = "x" .. self.luckyWheelExModel:GetMoreIndianaCost()
    
    local wheelItemsData = self.luckyWheelExModel:GetWheelItemsData()
    for i = 1, table.nums(wheelItemsData) do
        local itemData = wheelItemsData[i].contents
        local itemViewSpt = self.wheelItems["w" .. tostring(i)]
        itemViewSpt:InitView(itemData)
    end

    self.pointScroll:RegOnItemButtonClick(function(isGetReward, rewardId)
        self:OpenRewardBoard(isGetReward, rewardId)
    end)
    self.pointScroll:InitView(self.luckyWheelExModel:GetPointRewardList())
    GameObjectHelper.FastSetActive(self.arrow, tobool(self.contentRect.sizeDelta.y > self.scrollRect.rect.height))

    self:ShowLuckyWheelOpenCount()

    -- 初始化跳过动画勾选框为勾选
    self:SwitchToggleSkipAnim(self.luckyWheelExModel:GetIsSkipAnim())
end

function LuckyWheelViewEx:ShowLuckyWheelOpenCount()
    self.openCount.text = tostring(self.luckyWheelExModel:GetOpenCount())
end

function LuckyWheelViewEx:OpenRewardBoard(isGetReward, rewardId)
    if self.openRewardBoard then
        self.openRewardBoard(isGetReward, rewardId) 
    end
end

function LuckyWheelViewEx:OnEnterScene()
    LuckyWheelView.super.OnEnterScene(self)
    EventSystem.AddEvent("LuckyWheelModelEx_SetCurrentReward", self, self.SetCurrentReward)
    EventSystem.AddEvent("LuckyWheelModelEx_ResetOpenCount", self, self.ShowLuckyWheelOpenCount)
end

function LuckyWheelViewEx:OnExitScene()
    LuckyWheelView.super.OnExitScene(self)
    EventSystem.RemoveEvent("LuckyWheelModelEx_SetCurrentReward", self, self.SetCurrentReward)
    EventSystem.RemoveEvent("LuckyWheelModelEx_ResetOpenCount", self, self.ShowLuckyWheelOpenCount)
    self.isAnimationPlaying = false
end

-- 跳过动画
function LuckyWheelViewEx:OnToggleSkipAnim()
    if self.onToggleSkipAnim ~= nil and type(self.onToggleSkipAnim) == "function" then
        self.onToggleSkipAnim()
    end
end

-- 更改勾选框状态
function LuckyWheelViewEx:SwitchToggleSkipAnim(isOn)
    if isOn then
        self.tglSkipAnim:selectBtn()
    else
        self.tglSkipAnim:unselectBtn()
    end
end

return LuckyWheelViewEx
