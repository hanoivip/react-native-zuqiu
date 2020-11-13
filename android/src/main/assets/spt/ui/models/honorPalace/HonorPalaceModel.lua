local Model = require("ui.models.Model")
local HonorBase = require("data.HonorBase")
local Honor = require("data.Honor")
local HonorReward = require("data.HonorReward")
local HonorLevel = require("data.HonorLevel")
local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")

local HonorPalaceModel = class(Model)

function HonorPalaceModel:ctor()
    HonorPalaceModel.super.ctor(self)
end

function HonorPalaceModel:InitWithProtocol(data)
    self.data = data.list
    self.level = data.level
    self.rank = data.selfRank
    self.honor = data.honor
    self.reward = data.reward
    self.point = data.point
    self.staticData = HonorBase
    cache.setHonorShowData(self.honor)
end

-- 返回排序后的所有成就列表
function HonorPalaceModel:InitAchieveList()
    local achieveList = {}
    for typeID, typeTable in pairs(self.staticData) do
        local tagName = typeTable.tag
        local tableFromServer = self.data[tagName]
        if tableFromServer then
            tableFromServer = self:AddGuildWarHonor(tableFromServer)
        end
        local baseInfo = self:SetStartBaseInfo(typeID)
        if tableFromServer then
            if tableFromServer[typeID] then
                local tableToShow = self:GetTableToShowFromType(tableFromServer[typeID], tagName)
                -- 主线24章完成并领取后若没25章三星副本信息，服务器不会返回下一成就数据，需自行构建
                if tonumber(typeID) == 1 and tableToShow.state == 1 then
                    local honorInfo = self:GetNextHonorInfo(typeID, tableToShow)
                    table.insert(achieveList, honorInfo)
                else
                    table.insert(achieveList, tableToShow)
                end
            else
                table.insert(achieveList, baseInfo)
            end
        else
            table.insert(achieveList, baseInfo)
        end
    end
    table.sort(achieveList, function(a, b) return tonumber(a.ID) < tonumber(b.ID) end)
    return achieveList
end

-- 返回同一个tag中的成就列表
function HonorPalaceModel:InitAchieveListByTag(tag)
    local achieveList = self:InitAchieveList()
    local achieveTagTable = {}
    if tag == "ShowAll" then
        achieveTagTable = achieveList
    else
        for i, typeTable in ipairs(achieveList) do
            if typeTable.tag == tag then
                table.insert(achieveTagTable, typeTable)
            end
        end
    end
    table.sort(achieveTagTable, function(a, b)
        if a.state == b.state then
            return tonumber(a.ID) < tonumber(b.ID)
        else
            if a.state < 1 and b.state < 1 then
                return a.state > b.state
            else
                return a.state < b.state
            end
        end
    end)
    return achieveTagTable
end

-- 返回当前分类中需要显示的奖杯数据
function HonorPalaceModel:GetTableToShowFromType(tableToShow, tagName)
    local array = {}
    for id, itemTable in pairs(tableToShow) do
        table.insert(array, itemTable)
    end
    table.sort(array, function(a, b) return tonumber(a.ID) < tonumber(b.ID) end)
    local haveFinishedTable = {}
    local notFinishItemTable = {}
    for id, itemTable in ipairs(array) do
        if itemTable.state == 0 then
            itemTable.tag = tagName
            return itemTable
        elseif itemTable.state == -1 then
            if not next(notFinishItemTable) then
                itemTable.tag = tagName
                notFinishItemTable = itemTable
            end
        elseif itemTable.state == 1 then
            haveFinishedTable = itemTable
        end
    end
    return next(notFinishItemTable) and notFinishItemTable or haveFinishedTable
end

-- 将服务器没传的数据设置一个初始值
function HonorPalaceModel:SetStartBaseInfo(typeID)
    local baseInfo = {}
    baseInfo.tag = self.staticData[typeID].tag
    baseInfo.ID = tostring(typeID) .. "01"
    baseInfo.state = -1
    baseInfo.value = 0
    return baseInfo
end

-- 获取某一级成就别完成后的下一级数据
function HonorPalaceModel:GetNextHonorInfo(typeID, currentHonorInfo)
    local honorFromData = Honor[tostring(currentHonorInfo.ID)]
    if honorFromData and honorFromData.lastHonor == 0 then
        local honorInfo = {}
        honorInfo.ID = tostring(currentHonorInfo.ID + 1)
        honorInfo.tag = self.staticData[typeID].tag
        honorInfo.state = -1
        honorInfo.value = {}
        return honorInfo
    else
        return currentHonorInfo
    end
end

-- 返回已经获取的奖杯列表
function HonorPalaceModel:GetTrophyList()
    local trophyList = {}
    for tag, tagTable in pairs(self.data) do
        for typeID, typeTable in pairs(tagTable) do
            for id, itemTable in pairs(typeTable) do
                if itemTable.state == 1 then
                    table.insert(trophyList, itemTable)
                end
            end
        end
    end
    table.sort(trophyList, function (a, b)
        return a.r_t > b.r_t
    end)
    return trophyList
end

-- 返回已获取奖杯个数
function HonorPalaceModel:GetTrophyNum()
    local trophyList = self:GetTrophyList()
    if next(trophyList) then
        return #trophyList
    else
        return "0"
    end
end

-- 返回已获取奖杯占所有奖杯的百分比
function HonorPalaceModel:GetCollectedTrophyPercent(trophyNum)
    local allTrophyNum = table.nums(Honor)
    return math.round((trophyNum * 100) / allTrophyNum)
end

-- 返回正在展览的奖杯列表
function HonorPalaceModel:GetTrophyShowList()
    return cache.getHonorShowData()
end

-- 按ID返回
function HonorPalaceModel:GetTrophyByID(trophyID)
    for tag, tagTable in pairs(self.data) do
        for typeID, typeTable in pairs(tagTable) do
            for id, itemTable in pairs(typeTable) do
                if itemTable.ID == trophyID then
                    return itemTable
                end
            end
        end
    end
    return nil
end

function HonorPalaceModel:SetTrophyShowList(trophyShowList)
    cache.setHonorShowData(trophyShowList)
end

-- 返回所有奖杯的个数
function HonorPalaceModel:GetHonorNumFromTable()
    return table.nums(Honor)
end

local GuildWarID = tostring(12)
function HonorPalaceModel:AddGuildWarHonor(tableFromServer)
    if not tableFromServer[GuildWarID] then
        return tableFromServer
    else
        --找最大的key 加一级
        local maxKey = 0
        for k,v in pairs(tableFromServer[GuildWarID]) do
            maxKey = math.max(maxKey, tonumber(k))
        end
        maxKey = maxKey + 1
        if Honor[tostring(maxKey)] then
            local baseInfo = {}
            baseInfo.tag = self.staticData[GuildWarID].tag
            baseInfo.ID = tostring(maxKey)
            baseInfo.state = -1
            baseInfo.value = 0
            tableFromServer[GuildWarID][tostring(maxKey)] = baseInfo
        end
    end
    return tableFromServer
end

function HonorPalaceModel:GetRewardDataList()
    local rewardTable = {}
    for k, v in pairs(HonorReward) do
        table.insert(rewardTable, {level = tonumber(k), rewardData = v, state = self.reward[tostring(k)] and self.reward[tostring(k)].state})
    end
    table.sort(rewardTable, function (a, b)
        if a.state == 1 and b.state == 1 then
            return a.level < b.level
        end
        if a.state ~= 1 and b.state == 1 then
            return true
        end
        if a.state == 1 and b.state ~= 1 then
            return false
        end
        return a.level < b.level
    end)
    local index = 0
    for i, v in ipairs(rewardTable) do
        v.bgIndex = i
    end
    return rewardTable
end

-- 成就值
function HonorPalaceModel:GetEffortValue()
    return tostring(self.level)
end

function HonorPalaceModel:GetSelfRank()
    return tostring(self.rank)
end

function HonorPalaceModel:GetEffortPoint()
    return self.point
end

function HonorPalaceModel:GetHavePoint()
    local cumPoint = HonorLevel[tostring(self.level)].cumHonorPoint
    return self.point - cumPoint
end

function HonorPalaceModel:GetNeedPoint()
    local needPoint = HonorLevel[tostring(self.level + 1)].honorPoint
    return needPoint
end

return HonorPalaceModel