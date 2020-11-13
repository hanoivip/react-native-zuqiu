local GuildMistWarMap = require("data.GuildMistWarMap")
local Model = require("ui.models.Model")

local GuildMistChooseMapModel = class(Model, "GuildMistChooseMapModel")

function GuildMistChooseMapModel:ctor()
    GuildMistChooseMapModel.super.ctor(self)
end

function GuildMistChooseMapModel:Init()

end

function GuildMistChooseMapModel:InitWithProtocol(data)
    self.data = data
end

function GuildMistChooseMapModel:RefreshData(mapData)
    local round = self:GetRound()
    round = tostring(round)
    self.data.shopMapInfo = mapData.shopMapInfo
    self.data.roundMapIds[round].mapIds = mapData.mapIds
    self.data.roundMapIds[round].mistMapId = mapData.mistMapId
    EventSystem.SendEvent("GuildWarMist_RefreshDefenderMap", mapData)
end

function GuildMistChooseMapModel:SetRound(round)
    self.round = round or 1
end

function GuildMistChooseMapModel:GetRound()
    return self.round
end

function GuildMistChooseMapModel:GetCurRoundMapInfo()
    local round = self:GetRound()
    round = tostring(round)
    return self.data.roundMapIds[round]
end

-- 筛选按钮列表 按照默认打开的格子个数进行筛选
-- 从表里取出所有可能的
-- 0 表示全部地图
function GuildMistChooseMapModel:GetTabList()
    local temp = {}
    temp.all = {count = 0}
    for i, v in pairs(GuildMistWarMap) do
        local default = v.default
        local defaultCount = #default
        temp[defaultCount] = {count = defaultCount}
    end
    local tabList = {}
    for i, v in pairs(temp) do
        table.insert(tabList, v)
    end
    table.sort(tabList, function(a, b) return a.count < b.count end)
    return tabList
end

-- tag 默认开启个数为tag的所有地图
function GuildMistChooseMapModel:GetMapListByTag(tag)
    local mapList = {}
    local curMapInfo = self:GetCurRoundMapInfo()
    local curMistMapId = curMapInfo.mistMapId
    local curMapData
    for i, v in pairs(GuildMistWarMap) do
        local default = v.default
        local defaultCount = #default
        local mapInfo = {}
        mapInfo.staticData = clone(v)
        mapInfo.cacheInfo = curMapInfo
        mapInfo.shopMapCountInfo = self.data.shopMapInfo
        if v.id == curMistMapId then
            curMapData = mapInfo
        else
            if tag <= 0 then
                table.insert(mapList, mapInfo)
            else
                if tag == defaultCount then
                    table.insert(mapList, mapInfo)
                end
            end
        end
    end
    table.sort(mapList,function(a, b)
        return a.staticData.id < b.staticData.id
    end)
    if curMapData then
        table.insert(mapList, 1, curMapData)
    end
    return mapList
end

return GuildMistChooseMapModel
