local OldPlayerTabType = require("ui.scene.oldPlayer.OldPlayerTabType")
local LimitType = require("ui.scene.itemList.LimitType")
local OlduserComeback = require("data.OlduserComeback")
local EventSystem = require("EventSystem")
local Model = require("ui.models.Model")
local OldPlayerModel = class(Model)

function OldPlayerModel:ctor(isBtnClick)
    OldPlayerModel.super.ctor(self)
    self.isShowPage = isBtnClick
    self.selectMenu = OldPlayerTabType.LoginReward.pos
end

function OldPlayerModel:InitWithProtocol(cacheData)
    self.cacheData = cacheData
    self.menuDataMap ={}
    self.contentDataMap = {}
    self.menuMap = {}
    self:InitMapData()
end

function OldPlayerModel:InitMapData()
    if self.cacheData.list then
        local mList = {}
        for k,v in pairs(self.cacheData.list) do
            mList[tostring(v.subID)] = v
        end
        self.cacheData.list = mList
    end
    for k,v in pairs(self.cacheData.list) do
        if OlduserComeback[k] and OlduserComeback[k].ID == self.cacheData.id then
            self:SetData(OlduserComeback[k])
        end
    end
end

function OldPlayerModel:SetData(data)
    if not self.menuMap[data.tabNum] then
        self.menuMap[data.tabNum] = {}
        self.menuMap[data.tabNum].tabName = data.tabName
        self.menuMap[data.tabNum].tabNum = data.tabNum
        self.menuMap[data.tabNum].redPointCount = 0
    end
    if not self.contentDataMap[data.tabNum] then
        self.contentDataMap[data.tabNum] = {}
        self.contentDataMap[data.tabNum].itemDatas = {}
        self.contentDataMap[data.tabNum].title = lang.trans("oldPlayer_content_tip_" .. data.tabNum)
    end
    local tempItem = self.cacheData.list[tostring(data.subID)]
    data.status = tempItem.status
    data.status = (tempItem.param and tempItem.param > 0) and 1 or data.status
    if data.status == 0 then
        self.isShowPage = true
        self.menuMap[data.tabNum].redPointCount = self.menuMap[data.tabNum].redPointCount + 1
    end
    data.endTime = self.cacheData.endTime
    data.value = tempItem.value
    table.insert(self.contentDataMap[data.tabNum].itemDatas, data)
end

function OldPlayerModel:SetSelectMenu(selectMenu)
    self.selectMenu = selectMenu
end

function OldPlayerModel:GetSelectMenu()
    return self.selectMenu
end

function OldPlayerModel:GetMenuTab()
    table.sort(self.menuMap, function(a, b) return a.tabNum < b.tabNum end)
    return self.menuMap
end

local function sortDataList(a, b)
    local aCompareNum = math.abs(tonumber(a.status) + 0.2)
    local bCompareNum = math.abs(tonumber(b.status) + 0.2)
    if aCompareNum < bCompareNum then
        return true
    end
    if aCompareNum > bCompareNum then
        return false
    end
    return tonumber(a.condition) < tonumber(b.condition)
end

local OnlyOnceRedPoint = {[2] = true}
function OldPlayerModel:ResetTabRedPoint()
    if OnlyOnceRedPoint[self.selectMenu] then
        local itemLookMap = cache.getIsFirstLookOldPlayerItem()
        if not itemLookMap then
            itemLookMap = {}
        end
        if not itemLookMap[self.selectMenu] then
            itemLookMap[self.selectMenu] = true
            cache.setIsFirstLookOldPlayerItem(itemLookMap)
            EventSystem.SendEvent("ReduceRedPointCount", self.menuMap)
        end
    end
end

function OldPlayerModel:GetCurrContentData()
    self:ResetTabRedPoint()
    table.sort(self.contentDataMap[self.selectMenu].itemDatas, sortDataList)
    return self.contentDataMap[self.selectMenu]
end

function OldPlayerModel:SetCurrItemReduce(itemIndex)
    if self.contentDataMap[self.selectMenu] then
        local itemData = self.contentDataMap[self.selectMenu].itemDatas[itemIndex]
        itemData.status = 1
        self.contentDataMap[self.selectMenu].itemDatas[itemIndex] = itemData
    end
    if self.menuMap[self.selectMenu] then
        self.menuMap[self.selectMenu].redPointCount = self.menuMap[self.selectMenu].redPointCount - 1
        EventSystem.SendEvent("ReduceRedPointCount", self.menuMap)
    end
    return self.contentDataMap[self.selectMenu].itemDatas[itemIndex]
end

function OldPlayerModel:GetLimitTitle(limitType, exchangeCount, limitAmount)
    if limitType == LimitType.NoLimit then
        self.isCanExchange = true
        return ""
    elseif limitType == LimitType.DayLimit then
        self.isCanExchange = exchangeCount > 0
        return lang.trans("newYearExchange_property_day_buyLimit", exchangeCount, limitAmount)
    elseif limitType == LimitType.ForeverLimit then
        self.isCanExchange = exchangeCount > 0
       return lang.trans("newYearExchange_property_buyLimit", exchangeCount, limitAmount)
    end
end

function OldPlayerModel:GetPublicContentData()
    local publicContentData = {}
    publicContentData.beginTime = self.cacheData.beginTime
    publicContentData.endTime = self.cacheData.endTime
    return publicContentData
end

function OldPlayerModel:GetCurrentClassName()
    local currentKey
    for k, v in pairs(OldPlayerTabType) do
        if self.selectMenu == v.pos then
            currentKey = v.key
            break
        end
    end
    return currentKey
end

function OldPlayerModel:IsShowView()
    return self.isShowPage
end

return OldPlayerModel