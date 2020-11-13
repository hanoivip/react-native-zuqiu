local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local ItemModel = require("ui.models.ItemModel")
local ItemPlaceType = require("ui.scene.itemList.ItemPlaceType")
local CoachItemListModel = class(CoachItemMapModel, "CoachItemListModel")

function CoachItemListModel:ctor()
    CoachItemListModel.super.ctor(self)
    self.contentTalentSkillBook = {}  -- 特性书礼包
    self.contentTalentFuncItem = {}  -- 特性道具礼包
    self.contentTacticItem = {}  -- 阵型/战术升级道具礼包
    self.contentCoachInfo = {}  -- 助教情报礼包
    self.contentTalentSkillBookModel = {}  -- 特性书礼包Model
    self.contentTalentFuncItemModel = {}  -- 特性道具礼包Model
    self.contentTacticItemModel = {}  -- 阵型/战术升级道具礼包Model
    self.contentCoachInfoModel = {}  -- 助教情报礼包Model
    self.allContentModel = {}  -- 所有礼包Model
    self.itemsMapModel = ItemsMapModel.new()
end

function CoachItemListModel:InitData()
    local items = self.itemsMapModel:GetItems()
    for k, v in pairs(items) do
        if v.num ~= 0 then
            local itemModel = ItemModel.new(k)
            local isValid = itemModel:HasValid()
            local itemPlaceType = itemModel:GetItemType()
            if isValid then 
                if itemPlaceType == ItemPlaceType.PlayerTalentSkillBook
                    or itemPlaceType == ItemPlaceType.PlayerTalentFunctionalityItem
                    or itemPlaceType == ItemPlaceType.CoachTacticsItem
                    or itemPlaceType == ItemPlaceType.AssistCoachInfo then
                    self.allContentModel[k] = itemModel
                end
            end
        end
    end
    self:Init()
end

-- 所有教练礼包
function CoachItemListModel:AllContentModel()
    local fixedContentModel = {}
    for k,v in pairs(self.allContentModel) do
        if v:GetAddNum() > 0 then
            table.insert(fixedContentModel, v)
        end
    end
    return fixedContentModel
end

function CoachItemListModel:GetItemType(id)
    id = tostring(id)
    local itemType = self:GetCoachItemType(id)
    if not itemType then
        local itemModel = self.allContentModel[id]
        return itemModel and itemModel:GetItemType()
    end
    return itemType
end

function CoachItemListModel:GetItemBoxPrefabPathByType(itemType)
    itemType = tonumber(itemType)
    if itemType == ItemPlaceType.PlayerTalentSkillBook then -- 特性书
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/PlayerTalentSkillBookItem/CoachSkillBookBox.prefab"
    elseif itemType == ItemPlaceType.PlayerTalentFunctionalityItem then -- 特性道具
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/TacticItem/CoachItemBox.prefab"
    elseif itemType == ItemPlaceType.CoachTacticsItem then -- 阵型/战术道具
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/TacticItem/CoachItemBox.prefab"
    elseif itemType == ItemPlaceType.AssistCoachInfo then -- 助教情报
        return "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/AssistCoachInfo/AssistCoachInfoBox.prefab"
    elseif itemType == ItemPlaceType.Normal then
        return "Assets/CapstonesRes/Game/UI/Scene/ItemList/Item.prefab" -- 礼包
    else
        -- dump("wrong coach item config type!")
        return ""
    end
end

return CoachItemListModel
