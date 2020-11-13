local ReqEventModel = require("ui.models.event.ReqEventModel")
local ActivityModel = require("ui.models.activity.ActivityModel")
local TimeLimitGiftBoxModel = class(ActivityModel)

local defaultTableIndex = 1
function TimeLimitGiftBoxModel:InitWithProtocol()
    self.dataListMap = self:GetActivitySingleData().giftBag or {}
    local activityFirstRead = -2
    local activity = ReqEventModel.GetInfo("activity")
    local activityType = self:GetActivityType()
    local activityData = activity[activityType]
    self.dataList = {}
    for k, v in pairs(self.dataListMap) do
        assert(type(v) == "table" and next(v), "data error!!!")
        v.tabTag  = k
        if activityData then
            if type(activityData) == "table" then
                v.isFirstRead = tonumber(activityData[tostring(v.id)]) == activityFirstRead
            else
                v.isFirstRead = tonumber(activityData) == activityFirstRead
            end
        else
            v.isFirstRead = false
        end
        table.insert(self.dataList, v)
    end
    if not self.tabTag and self.dataList[defaultTableIndex] then
        self.defaultTabTag = self.dataList[defaultTableIndex].tabTag
        self.tabTag = self.defaultTabTag
    end
end

function TimeLimitGiftBoxModel:GetTabDataList()
    return self.dataList or {}
end

function TimeLimitGiftBoxModel:IsSpecialTabByTag(tag)
    assert(type(self.dataListMap[tag]) == "table", "data error!!!")
    local isSpecial = tostring(self.dataListMap[tag].titleType) ~= "0"
    return isSpecial
end

function TimeLimitGiftBoxModel:GetBeginTime()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].beginTime
end

function TimeLimitGiftBoxModel:GetEndTime()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].endTime
end

function TimeLimitGiftBoxModel:GetGiftBoxInfo()
    local tabTag = self:GetSelectedTabTag()
    local selectedTabData = self.dataListMap[tabTag]
    local info = selectedTabData.store
    if type(info) ~= "table" then info = {} end
    table.sort(info, function (a, b)
        return a.idBox < b.idBox
    end)
    return info
end

function TimeLimitGiftBoxModel:GetPlateType()
    return self:GetActivitySingleData().plate
end

function TimeLimitGiftBoxModel:GetSelectedTabTag()
    return self.tabTag
end

--只需要在最开始做一次数据检查
function TimeLimitGiftBoxModel:SetSelectedTabTag(tabTag)
    self.tabTag = tabTag
    local selectedTabData = self.dataListMap[tabTag]
    assert(type(selectedTabData) == "table" and next(selectedTabData), "data error!!!")
end

function TimeLimitGiftBoxModel:IsActFirstRead()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].isFirstRead
end

function TimeLimitGiftBoxModel:SetActFirstRead(isFirstRead)
    local tabTag = self:GetSelectedTabTag()
    self.dataListMap[tabTag].isFirstRead = isFirstRead
end

function TimeLimitGiftBoxModel:GetActID()
    local tabTag = self:GetSelectedTabTag()
    return self.dataListMap[tabTag].id
end

return TimeLimitGiftBoxModel