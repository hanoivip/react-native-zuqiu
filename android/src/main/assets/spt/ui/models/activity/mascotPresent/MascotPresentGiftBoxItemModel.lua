local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local Model = require("ui.models.Model")

local MascotPresentGiftBoxItemModel = class(Model, "MascotPresentGiftBoxItemModel")

function MascotPresentGiftBoxItemModel:ctor(data)
    MascotPresentGiftBoxItemModel.super.ctor(self)
    self.data = data
end

function MascotPresentGiftBoxItemModel:IsGiftAlreadyCollected()
    return type(self.data.state) == "table" and next(self.data.state) ~= nil
end

function MascotPresentGiftBoxItemModel:GetBoxIndex()
    return self.data.index
end

function MascotPresentGiftBoxItemModel:GetRewardContents()  --只选取一个道具显示
    local rewardContents = {}

    if type(self.data.static) == "table" then
        for k, v in pairs(self.data.static) do
            rewardContents[k] = v
            break
        end
    end
    return rewardContents
end

function MascotPresentGiftBoxItemModel:GetGiftOwnerName()
    return self.data.state.name or ""
end

function MascotPresentGiftBoxItemModel:GetPropName()
    local contents = self:GetRewardContents()
    local mType = contents and next(contents)
    local rewardTable = contents and contents[mType]
    if type(rewardTable) ~= "table" then
        rewardTable = {}
    end
    local name = RewardNameHelper.GetTypeName(next(rewardTable) and rewardTable[1], mType)
    return name
end

return MascotPresentGiftBoxItemModel