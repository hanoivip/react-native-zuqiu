local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Model = require("ui.models.Model")
local FreshPlayerLevelBox = require("data.FreshPlayerLevelBox")
local FreshPlayerLevelModel = class(Model, "FreshPlayerLevelModel")

FreshPlayerLevelModel.BuyType ={}
FreshPlayerLevelModel.BuyType.Free = 1  -- 免费
FreshPlayerLevelModel.BuyType.Cost = 2  -- 收费

function FreshPlayerLevelModel:ctor()
    FreshPlayerLevelModel.super.ctor(self)
end

function FreshPlayerLevelModel:Init(data)
    if not data then
        data = cache.getFreshPlayerLevelData()
    end
    self.data = data.result
    self.allCacheData = data.allCacheData or {}
    self.serverTime = data.serverTime
    self.startTime = data.startTime
end

function FreshPlayerLevelModel:InitWithProtocol(data)
    data = data or {}
    local levelBoxData = {}
    local list = data.list or {}
    for id, content in pairs(list) do
        local boxData = self:GetStaticDataById(id)
        local pageId = boxData.id
        local buyType = tonumber(boxData.type)
        if not levelBoxData[pageId] then
            levelBoxData[pageId] = {}
        end
        if not levelBoxData[pageId].pageContent then
            levelBoxData[pageId].pageContent = {}
        end
        levelBoxData[pageId].pageId = pageId
        levelBoxData[pageId].pageContent[buyType] = {}
        levelBoxData[pageId].pageContent[buyType].staticData = boxData
        levelBoxData[pageId].pageContent[buyType].cacheData = content
        levelBoxData[pageId].pageContent[buyType].id = id
    end
    local result = {}
    for i, v in pairs(levelBoxData) do
        local completeNum = 0
        for k, value in pairs(v.pageContent) do
            completeNum = completeNum + value.cacheData.state
        end
        if completeNum < 2 then
            table.insert(result, v)
        end
    end
    table.sort(result, function(a, b) return a.pageId < b.pageId end)
    for i, v in ipairs(result) do
        v.index = i
    end
    local cacheFreshPlayerLevelData = {}
    cacheFreshPlayerLevelData.result = result
    cacheFreshPlayerLevelData.startTime = Time.unscaledTime
    cacheFreshPlayerLevelData.serverTime = data.serverTime
    cacheFreshPlayerLevelData.allCacheData = list
    cache.setFreshPlayerLevelData(cacheFreshPlayerLevelData)
    self:Init(cacheFreshPlayerLevelData)
    EventSystem.SendEvent("FreshPlayerLevel_Changed")
end

function FreshPlayerLevelModel:GetAllBoxData()
    -- 剔除过期的
    local boxList = {}
    for i, v in ipairs(self.data) do
        local isInTime = false
        for index, value in pairs(v.pageContent) do
            local subid = value.staticData.subid
            local outOfTimeState = self:GetOutOfTimeStateById(subid)
            if outOfTimeState then
                isInTime = true
                break
            end
        end
        if isInTime then
            table.insert(boxList, v)
        end
    end
    for i, v in ipairs(boxList) do
        v.index = i
    end
    return boxList
end

function FreshPlayerLevelModel:GetNowServerTime()
    local nowServerTime = Time.unscaledTime - self.startTime + self.serverTime
    return nowServerTime
end

-- 获取所有页面中剩余时间最小的那个页面的时间
function FreshPlayerLevelModel:GetShortestEndTime()
    local endTime = -1
    local shortestEndId
    for i, v in pairs(self.allCacheData) do
        local idStr = tostring(i)
        local tRemain = self:GetRemainTimeById(idStr)
        if v.state == 0 and tRemain > 1 then
            if endTime < 0 then
                endTime = v.endTime
                shortestEndId = idStr
            end
            if endTime > v.endTime then
                endTime = v.endTime
                shortestEndId = idStr
            end
        end
    end
    local remainTime = self:GetRemainTimeById(shortestEndId)
    return remainTime
end

function FreshPlayerLevelModel:GetRemainTimeById(id)
    if not id then
        return -1
    end
    local endTime = self.allCacheData[tostring(id)].endTime
    local nowServerTime = self:GetNowServerTime()
    return endTime - nowServerTime
end

function FreshPlayerLevelModel:GetOutOfTimeStateById(id)
    local remainTime = self:GetRemainTimeById(id)
    return remainTime > 1
end

function FreshPlayerLevelModel:GetStaticDataById(id)
    id = tostring(id)
    return FreshPlayerLevelBox[id]
end

function FreshPlayerLevelModel:RefreshSingleData(data)
    local pData = {}
    pData.serverTime = data.serverTime
    pData.list = {}
    local subId = tostring(data.subId)
    local levelBox = data.levelBox
    for i, v in pairs(self.allCacheData) do
        if i == subId then
            pData.list[i] = levelBox
        else
            pData.list[i] = v
        end
    end
    self:InitWithProtocol(pData)
end

function FreshPlayerLevelModel:SetPageIndex(index)
    self.pageIndex = index
end

function FreshPlayerLevelModel:GetPageIndex()
    return self.pageIndex or 1
end

return FreshPlayerLevelModel
