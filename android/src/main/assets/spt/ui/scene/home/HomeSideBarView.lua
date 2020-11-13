local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local HomeSideBarView = class(unity.base)

function HomeSideBarView:ctor()
    self.btnStore = self.___ex.btnStore
    self.btnEmail = self.___ex.btnEmail
    self.btnActivity = self.___ex.btnActivity
    self.btnMore = self.___ex.btnMore

    -- 红点
    self.emailRedPoint = self.___ex.emailRedPoint
    self.moreRedPoint = self.___ex.moreRedPoint
    self.storeRedPoint = self.___ex.storeRedPoint
    self.activityRedPoint = self.___ex.activityRedPoint
end

function HomeSideBarView:start()
    self.btnStore:regOnButtonClick(function()
        self:OnBtnStoreClick()
    end)
    self.btnEmail:regOnButtonClick(function()
        self:OnBtnEmailClick()
    end)
    self.btnActivity:regOnButtonClick(function()
        self:OnBtnActivityClick()
    end)
    self.btnMore:regOnButtonClick(function()
        self:OnBtnMoreClick()
    end)

    self:UpdateEmailState()
    EventSystem.AddEvent("ReqEventModel_email", self, self.UpdateEmailState)
    self:UpdateMoreState()
    EventSystem.AddEvent("ReqEventModel_friend", self, self.UpdateMoreState)
    EventSystem.AddEvent("ReqEventModel_honor", self, self.UpdateMoreState)
    self:UpdateActivityState()
    EventSystem.AddEvent("ReqEventModel_activity", self, self.UpdateActivityState)
    EventSystem.AddEvent("ReqEventModel_lotteryStake", self, self.UpdateActivityState)
    EventSystem.AddEvent("ReqEventModel_item", self, self.UpdateMoreState)
    EventSystem.AddEvent("ReqEventModel_medal", self, self.UpdateMoreState)
end

function HomeSideBarView:onDestroy()
    EventSystem.RemoveEvent("ReqEventModel_email", self, self.UpdateEmailState)
    EventSystem.RemoveEvent("ReqEventModel_honor", self, self.UpdateMoreState)
    EventSystem.RemoveEvent("ReqEventModel_activity", self, self.UpdateActivityState)
    EventSystem.RemoveEvent("ReqEventModel_lotteryStake", self, self.UpdateActivityState)
    EventSystem.RemoveEvent("ReqEventModel_friend", self, self.UpdateMoreState)
    EventSystem.RemoveEvent("ReqEventModel_item", self, self.UpdateMoreState)
    EventSystem.RemoveEvent("ReqEventModel_medal", self, self.UpdateMoreState)
end

function HomeSideBarView:UpdateEmailState()
    if GuideManager.GuideIsOnGoing("main") then return end
    local emailNum = ReqEventModel.GetInfo("email")
    GameObjectHelper.FastSetActive(self.emailRedPoint, tonumber(emailNum) > 0)
end

function HomeSideBarView:UpdateMoreState()
    if GuideManager.GuideIsOnGoing("main") then return end
    local honorNum = ReqEventModel.GetInfo("honor")
    local honorReward = ReqEventModel.GetInfo("honorReward")
    local itemNum = ReqEventModel.GetInfo("item")
    local medalNum = ReqEventModel.GetInfo("medal")
    local isShowRedPoint = tonumber(honorNum) > 0 or tonumber(itemNum) > 0 or tonumber(honorReward) > 0 or (medalNum) > 0
    GameObjectHelper.FastSetActive(self.moreRedPoint, isShowRedPoint)
end

-- 更新活动和商店的红点
function HomeSideBarView:UpdateActivityState()
    if GuideManager.GuideIsOnGoing("main") then return end

    local activity = ReqEventModel.GetInfo("activity")
    local isShow = false

    local lotteryStake = ReqEventModel.GetInfo("lotteryStake")
    isShow = tonumber(lotteryStake) > 0

    if isShow == false then

        local activityRes = ActivityRes.new()
        local activityList = activityRes:GetActivityList()

        for i, activityType in ipairs(activityList) do
            local activityData = activity[activityType]
            if activityData ~= nil then
                if type(activityData) == "table" then
                    if tonumber(activityData["1"]) == -2 or tonumber(activityData["1"]) == 0 then
                        isShow = true
                        break
                    end
                else
                    if tonumber(activityData) == -2 or tonumber(activityData) == 0 then
                        isShow = true
                        break
                    end
                end
            end
        end
    end

    GameObjectHelper.FastSetActive(self.activityRedPoint, isShow)

    local storeNum = ReqEventModel.GetInfo("freeGacha")

    if (type(activity.GachaSpecialSelf) == "table" and next(activity.GachaSpecialSelf))
        or (type(activity.GachaSpecial) == "table" and next(activity.GachaSpecial)) or tonumber(storeNum) > 0 then
        GameObjectHelper.FastSetActive(self.storeRedPoint, true)
    else
        GameObjectHelper.FastSetActive(self.storeRedPoint, false)
    end
end

function HomeSideBarView:OnBtnStoreClick()
    if self.clickStore then
        self.clickStore()
    end
end

function HomeSideBarView:OnBtnEmailClick()
    if self.clickEmail then
        self.clickEmail()
    end
end

function HomeSideBarView:OnBtnActivityClick()
    if self.clickActivity then
        self.clickActivity()
    end
end

function HomeSideBarView:OnBtnMoreClick()
    if self.clickMore then
        self.clickMore()
    end
end

return HomeSideBarView
