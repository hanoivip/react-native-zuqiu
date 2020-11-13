local BuildingBase = require("data.BuildingBase")
local Model = require("ui.models.Model")
local FeatureSkillEnum = require("ui.scene.cardDetail.feature.FeatureSkillEnum")
local ItemPlateType = require("ui.scene.itemList.ItemPlateType")
local ItemType = require("ui.scene.itemList.ItemType")
local LimitType = require("ui.scene.itemList.LimitType")
local Time = clr.UnityEngine.Time
local EventGiftBoxModel = class(Model)

function EventGiftBoxModel:ctor()
    EventGiftBoxModel.super.ctor(self)
end

function EventGiftBoxModel:Init()
    self.data = cache.GetEventGiftBox()
    if not self.data then
        self.data = {}
        self.data.list = {}
        cache.SetEventGiftBox(self.data)
    end
end

local function sortFunc(tb1, tb2)
    if tb1.endTime == tb2.endTime then
        return false
    end
    return tb1.endTime > tb2.endTime
end

function EventGiftBoxModel:CheckRedPoint(data)
    if not self.data or #self.data.list == 0 then
        return true
    end
    for k, v in pairs(data.list) do
        local bHave = false
        for k1, v1 in pairs(self.data.list) do
            if v1.id == k then
                bHave = true
                break
            end
        end
        if not bHave then
            return true
        end
    end
    return false
end

function EventGiftBoxModel:InitWithProtocol(data)
    local bShow = self:CheckRedPoint(data)
    self.data = {}
    self.data.serverTime = data.serverTime
    self.data.list = {}
    for k, v in pairs(data.list) do
        data.list[k].id = k
        table.insert(self.data.list, data.list[k])
    end
    table.sort(self.data.list, sortFunc)
    self.data.time = Time.realtimeSinceStartup
    self.data.isShowRedPoint = bShow
    cache.SetEventGiftBox(self.data)
end

function EventGiftBoxModel:GetGiftList()
    local list = {}
    for k,v in pairs(self.data.list) do
        if self:GetLastTime(v) > 0 and v.buyCnt < v.limitCount then
            table.insert(list, v)
        end
    end
    self.data.list = list
    return self.data.list
end

function EventGiftBoxModel:GetData()
    return self.data
end

function EventGiftBoxModel:GetGoTime()
    if not self.data then
        self.data = {}
    end
    if not self.data.time then
        self.data.time = Time.realtimeSinceStartup
    end
    return Time.realtimeSinceStartup - self.data.time
end

function EventGiftBoxModel:Remove(item)
    for i = 1, #self.data do
        if self.data[i] == item then
            table.remove(self.data, i)
            return
        end
    end
end

function EventGiftBoxModel:GetLastTime(item)
    return item.endTime - self.data.serverTime - self:GetGoTime()
end

function EventGiftBoxModel:GetBtnTime()
    local time = 0
    for k,v in pairs(self.data.list) do
        local lastTime = self:GetLastTime(v)
        if lastTime > 0 and v.buyCnt < v.limitCount then
            if time == 0 or time > lastTime then
                time = lastTime
            end
        end
    end
    return time
end

function EventGiftBoxModel:SetRedPoint()
    self.data.isShowRedPoint = false
end

function EventGiftBoxModel:IsShowRedPoint()
    return self.data.isShowRedPoint
end

return EventGiftBoxModel