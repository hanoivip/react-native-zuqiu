local ActivitySort = require("data.ActivitySort")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ReqEventModel = require("ui.models.event.ReqEventModel")

local ActivityLabelView = class(unity.base)

--合并后的红点逻辑
local specialActivityType = {}
specialActivityType["GrowthPlan"] = true
specialActivityType["TimeLimitGiftBag"] = true
specialActivityType["TimeLimitLetter"] = true
specialActivityType["ChainGrowthPlan"] = true

function ActivityLabelView:ctor()
    self.labelIcon = self.___ex.labelIcon
    self.btnLabel = self.___ex.btnLabel
    self.labelText = self.___ex.labelText
    self.selectButton = self.___ex.selectButton
    self.redPoint = self.___ex.redPoint
    self.labelSelectText = self.___ex.labelSelectText
    self.newPlayerLogo = self.___ex.newPlayerLogo
    self.newLogo = self.___ex.newLogo
    
    self.isFirstRead = false
    self.activityType = nil
    self.activityId = nil
end

function ActivityLabelView:start()
    self.btnLabel:regOnButtonClick(function()
        self:OnBtnClick()
    end)

    EventSystem.AddEvent("ReqEventModel_activity", self, self.UpdateRedPointState)
    EventSystem.AddEvent("ReqEventModel_lotteryStake", self, self.UpdateRedPointState)
end

function ActivityLabelView:ChangeSelectState(isSelect)
    GameObjectHelper.FastSetActive(self.selectButton, isSelect)
    self.btnLabel:onPointEventHandle(not isSelect)
end

function ActivityLabelView:OnBtnClick()
    if self.clickBack then
        self.clickBack()
    end
end

function ActivityLabelView:UpdateRedPointState()
    if specialActivityType[self.activityType] then
        self:RedPointFuncForGrowthPlanAndGiftBag()
        return
    end

    local isCanReceive = false
    if self.activityType == "QuizLottery" then
        local lotteryStake = ReqEventModel.GetInfo("lotteryStake")
        isCanReceive = tonumber(lotteryStake) > 0
    end

    if isCanReceive == false then
        local activity = ReqEventModel.GetInfo("activity")
        local activityData = activity[self.activityType]

        if activityData == nil then
            GameObjectHelper.FastSetActive(self.redPoint, false)
            return
        end

        if type(activityData) == "table" then
            self.isFirstRead = tonumber(activityData[tostring(self.activityId)]) == -2
            isCanReceive = tostring(activityData[tostring(self.activityId)]) == "0" -- tonumber(nil) == 0
        else
            self.isFirstRead = tonumber(activityData) == -2
            isCanReceive = tostring(activityData) == "0"
        end
    end
    GameObjectHelper.FastSetActive(self.redPoint, self.isFirstRead or isCanReceive)
end

--合并豪门契约和限时售卖后 由于服务器端的逻辑未修改，客户端要为合并后做特有的处理
function ActivityLabelView:RedPointFuncForGrowthPlanAndGiftBag()
    local isShowRedPoint = false
    local activity = ReqEventModel.GetInfo("activity")
    local activityStatus = activity[self.activityType]
    if activityStatus then
        if type(activityStatus) == "table" then
            for k, v in pairs(activityStatus) do
                if tonumber(v) == -2 or tostring(v) == "0" then
                    isShowRedPoint = true
                    break
                end
            end
        else
            if tonumber(activityStatus) == -2 or tostring(activityStatus) == "0" then
                isShowRedPoint = true
            end
        end
    end

    GameObjectHelper.FastSetActive(self.redPoint, isShowRedPoint)
end

local DefaultId = 1
function ActivityLabelView:InitView(data, activityRes)
    self.newPlayerLogo:SetActive(ActivitySort[data.type] and ActivitySort[data.type].noobTag == 1)
    self.activityType = data["type"]
    self.activityId = data["id"] or DefaultId
    local desc = activityRes:GetLabelName(self.activityType, self.activityId)
    desc = (desc == "") and data.name or desc
    self.labelText.text = desc
    self.labelSelectText.text = desc
    self:ChangeSelectState()
    self:UpdateRedPointState()
end

function ActivityLabelView:IsFirstRead()
    return self.isFirstRead
end

function ActivityLabelView:SetReadState(isFirstRead)
    self.isFirstRead = isFirstRead
end

function ActivityLabelView:onDestroy()
    EventSystem.RemoveEvent("ReqEventModel_activity", self, self.UpdateRedPointState)
    EventSystem.RemoveEvent("ReqEventModel_lotteryStake", self, self.UpdateRedPointState)
end

return ActivityLabelView
