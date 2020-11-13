local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local Object = UnityEngine.Object
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local ItemModel = require("ui.models.cardDetail.ItemModel")

local GuildChallengeRewardItemView = class(unity.base)

function GuildChallengeRewardItemView:ctor()
    self.content = self.___ex.content
end

function GuildChallengeRewardItemView:start()
    
end


function GuildChallengeRewardItemView:InitViewByDiamond(diamond)
    if diamond > 0 then
        local diamondItemModel = ItemModel.new()
        diamondItemModel:InitWithDiamondAddNum(diamond)
        self:InstantiateItemBox(diamondItemModel)
    end
end

function GuildChallengeRewardItemView:InitViewByMoney(money)
    if money > 0 then
        local moneyItemModel = ItemModel.new()
        moneyItemModel:InitWithMoneyAddNum(money)
        self:InstantiateItemBox(moneyItemModel)
    end
end

function GuildChallengeRewardItemView:InitViewByItem(itemId, itemNum)
    local itemModel = ItemModel.new()
    local newItemData = {id = itemId, add = tonumber(itemNum)}
    itemModel:InitWithCache(newItemData)
    self:InstantiateItemBox(itemModel)
end

function GuildChallengeRewardItemView:InitViewByEqs(eqsData)
    local equipBoxPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
    self:BuildEquipBox(eqsData, equipBoxPrefab, true)
end

function GuildChallengeRewardItemView:BuildEquipBox(equipId, equipBoxPrefab, isShowPiece)
    local equipItemModel = EquipItemModel.new()
    equipItemModel:InitWithStaticId(equipId)
    local obj = Object.Instantiate(equipBoxPrefab)
    obj.transform:SetParent(self.content, false)
    local objScript = obj:GetComponent(clr.CapsUnityLuaBehav)
    objScript:InitView(equipItemModel, equipId, false, false, isShowPiece, true, ItemOriginType.OTHER)
end

function GuildChallengeRewardItemView:InstantiateItemBox(itemModel)
    local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
    itemBoxObj.transform:SetParent(self.content, false)
    itemBoxView:InitView(itemModel, itemModel:GetID(), false, true, true, ItemOriginType.OTHER)
end

return GuildChallengeRewardItemView
