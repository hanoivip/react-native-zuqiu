local Model = require("ui.models.Model")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local ImproveType = require("ui.models.heroHall.main.HeroHallImproveType")
local FootballHallImprove = require("data.FootballHallImprove")
local HeroHallDataModel = require("ui.models.heroHall.main.HeroHallDataModel")

local HeroHallImproveModel = class(Model, "HeroHallImproveModel")

local HW_Special_id = "quality_5_1"
function HeroHallImproveModel:ctor()
    self.scrollData = {}
    self.heroHallDataModel = HeroHallDataModel.new()
end

function HeroHallImproveModel:InitWithProtocol(improveList)
    local tempScrollData = {}
    local index = 1
    for configID, config in pairs(FootballHallImprove) do
        if config.isShow == 1 then
            local itemData = clone(config)
            itemData.improveID = tonumber(configID)
            itemData.isTitle = false
            if improveList[itemData.improveType] == configID then
                itemData.isCurrLevel = false
            else
                itemData.isCurrLevel = false
            end
            itemData.improveStatus, itemData.improveSpecial = self.heroHallDataModel:GetImproveStatus(configID)
            -- S+卡华为渠道特殊判断
            if itemData.improveType == ImproveType.quality.improveType and tonumber(itemData.improveStatus) == 5 and tonumber(itemData.improveSpecial) == 1 then
                HW_Special_id = index
            end
            table.insert(tempScrollData, itemData)
            index = index + 1
        end
    end

    if not cache.getIsContainHWCard() then
        table.remove(tempScrollData, HW_Special_id)
    end

    table.sort(tempScrollData, function(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end)



    local currImrpvoeType = nil
    local headNum = 0
    for k, v in pairs(tempScrollData) do
        if currImrpvoeType == nil then
            -- 插入第一个title
            local itemData = clone(v)
            itemData.id = itemData.id + headNum
            itemData.isTitle = true
            table.insert(self.scrollData, itemData)
            currImrpvoeType = v.improveType
            headNum = headNum + 1
        end
        if currImrpvoeType ~= v.improveType then
            -- 插入一个title
            local itemData = clone(v)
            itemData.id = itemData.id + headNum
            itemData.isTitle = true
            table.insert(self.scrollData, itemData)
            currImrpvoeType = v.improveType
            headNum = headNum + 1
        end
        v.id = v.id + headNum
        table.insert(self.scrollData, v)
    end

    table.sort(self.scrollData, function(a, b)
        return a.id < b.id
    end)
end

function HeroHallImproveModel:GetScrollData()
    return self.scrollData or {}
end

return HeroHallImproveModel