local Model = require("ui.models.Model")
local AdventureRewardBase = require("data.AdventureRewardBase")

local TreasurePreviewModel = class(Model, "TreasurePreviewModel")

function TreasurePreviewModel:ctor()
    self.contents = nil
    TreasurePreviewModel.super.ctor(self)
end

function TreasurePreviewModel:Init()
end

function TreasurePreviewModel:InitWithProtocol(data)
    self.contentsArray = {}
    for k, id in ipairs(data) do
        id = tostring(id)
        if AdventureRewardBase[id] ~= nil then
            if not table.isEmpty(AdventureRewardBase[id].contents) then
                table.insert(self.contentsArray, AdventureRewardBase[id].contents)
            end
        end
    end
end

function TreasurePreviewModel:SetBuildModel(greenswardBuildModel)
    self.buildModel = greenswardBuildModel
end

function TreasurePreviewModel:SetItemModel(greenswardItemModel)
    self.itemModel = greenswardItemModel
end

function TreasurePreviewModel:GetRewardContents()
    return self.contentsArray
end

return TreasurePreviewModel
