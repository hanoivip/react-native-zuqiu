local RewardItemViewModel = require("ui.models.quest.RewardItemViewModel")
local StageRewardItemModel = class(RewardItemViewModel, "StageRewardItemModel")

function StageRewardItemModel:ctor(data)
    assert(type(data) == "table", "data error!!!")
    StageRewardItemModel.super.ctor(self, data)
    self.itemData = data
end

function StageRewardItemModel:GetStageIndex()
    local index = self.itemData.index or 1
    return index
end

function StageRewardItemModel:GetPointsNeededStr()
    local pointsNeeded = self:GetPointsNeeded()
    local str = lang.transstr("goldCup_desc7", pointsNeeded)
    return str
end

function StageRewardItemModel:GetPointsNeeded()
    local points = self.itemData.condition or 0
    return points
end

function StageRewardItemModel:GetStagePointsStr()
    local stagePoints = self.itemData.condition1 or 0
    local str = lang.transstr("goldCup_desc13", stagePoints)
    return str
end

function StageRewardItemModel:GetSubID()
    local subID = self.itemData.subID
    assert(subID, "data error!!!")
    return subID
end

function StageRewardItemModel:GetSeparateContents()
    local contents = self.itemData.contents
    local separateContents = {}

    for key, value in pairs(contents) do
        local item = {}
        if type(value) == "table" then
            for k, v in pairs(value) do
                item = {}
                item[key] = {}
                table.insert(item[key], v)
                table.insert(separateContents, item)
            end
        else
            item[key]= value
            table.insert(separateContents, item)
        end
    end
    return separateContents
end

return StageRewardItemModel