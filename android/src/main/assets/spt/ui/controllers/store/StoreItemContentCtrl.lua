local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local ItemModel = require("ui.models.cardDetail.ItemModel")
local EquipPieceModel = require("ui.models.cardDetail.EquipPieceModel")

local StoreItemContentCtrl = class()

--- 构建奖励的道具
-- @param parentObj 父节点
-- @param rewardData 奖励数据
-- @param isShowName 是否显示名称
-- @param isReceive 是否已获得
-- @param isShowBaseReward 是否显示基础奖励
-- @param isShowCardReward 是否显示卡牌奖励
-- @param isShowDetail 是否点击显示详情
function StoreItemContentCtrl:ctor(parentObj, rewardData, isShowName, isReceive, isShowBaseReward, isShowCardReward, isShowDetail)
    self.parentTrans = parentObj.transform
    self.rewardData = rewardData
    self.isShowName = isShowName
    self.isReceive = isReceive
    self.isShowBaseReward = isShowBaseReward
    self.isShowCardReward = isShowCardReward
    self.isShowDetail = isShowDetail or false

    self:BuildReward()
end

function StoreItemContentCtrl:BuildReward()
    if self.isShowBaseReward then
        self:BuildBaseReward()
    end
    self:BuildItemReward()
    self:BuildEquipReward()
    self:BuildEquipPieceReward()
    if self.isShowCardReward then
        self:BuildCardReward()
    end
end

--- 构建基础奖励
function StoreItemContentCtrl:BuildBaseReward()
    -- 钻石
    if self.rewardData.d ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithDiamondAddNum(self.rewardData.d)
        self:InstantiateItemBox(itemModel)
    end

    -- 欧元
    if self.rewardData.m ~= nil then
        if not self.rewardData.mDetail then
            local itemModel = ItemModel.new()
            itemModel:InitWithMoneyAddNum(self.rewardData.m)
            self:InstantiateItemBox(itemModel)
        else
            for i, v in ipairs(self.rewardData.mDetail) do
                local itemModel = ItemModel.new()
                itemModel:InitWithMoneyAddNum(v)
                self:InstantiateItemBox(itemModel)
            end
        end
    end

    -- 体力
    if self.rewardData.sp ~= nil then
        local itemModel = ItemModel.new()
        itemModel:InitWithStrengthAddNum(self.rewardData.sp)
        self:InstantiateItemBox(itemModel)
    end

    -- 经验
    if type(self.rewardData.exp) == "number" then
        local itemModel = ItemModel.new()
        itemModel:InitWithExpAddNum(self.rewardData.exp)
        self:InstantiateItemBox(itemModel)
    elseif type(self.rewardData.exp) == "table" and tonumber(self.rewardData.exp.addExp) > 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithExpAddNum(self.rewardData.exp.addExp)
        self:InstantiateItemBox(itemModel)
    end

    -- 卡牌上限
    if type(self.rewardData.bagLimit) == "number" and self.rewardData.bagLimit > 0 then
        local itemModel = ItemModel.new()
        itemModel:InitWithBagLimitAddNum(self.rewardData.bagLimit)
        self:InstantiateItemBox(itemModel)
    end
end

--- 构建道具奖励
function StoreItemContentCtrl:BuildItemReward()
    if type(self.rewardData.item) == "table" then
        local itemListData = self.rewardData.item
        if self.isReceive then
            for i, itemData in ipairs(itemListData) do
                local itemModel = ItemModel.new()
                itemModel:InitWithCache(itemData)
                self:InstantiateItemBox(itemModel)
            end
        else
            for i, itemData in ipairs(itemListData) do
                local itemModel = ItemModel.new()
                local newItemData = {id = itemData.id, add = itemData.num}
                itemModel:InitWithCache(newItemData)
                self:InstantiateItemBox(itemModel)
            end
        end
    end
end

--- 构建装备奖励
function StoreItemContentCtrl:BuildEquipReward()
    if type(self.rewardData.eqs) == "table" then
        local equipListData = self.rewardData.eqs
        if self.isReceive then
            for i, itemData in ipairs(equipListData) do
                local equipItemModel = EquipItemModel.new()
                equipItemModel:InitWithCache(itemData)
                self:InstantiateEquipBox(equipItemModel, false)
            end
        else
            for i, itemData in ipairs(equipListData) do
                local equipItemModel = EquipItemModel.new()
                local newItemData = {eid = itemData.id, add = itemData.num}
                equipItemModel:InitWithCache(newItemData)
                self:InstantiateEquipBox(equipItemModel, false)
            end
        end
    end
end

--- 构建装备碎片奖励
function StoreItemContentCtrl:BuildEquipPieceReward()
    if type(self.rewardData.equipPiece) == "table" then
        local equipPieceListData = self.rewardData.equipPiece
        if self.isReceive then
            for i, itemData in ipairs(equipPieceListData) do
                local equipPieceModel = EquipPieceModel.new()
                equipPieceModel:InitWithCache(itemData)
                self:InstantiateEquipBox(equipPieceModel, true)
            end
        else
            for i, itemData in ipairs(equipPieceListData) do
                local equipPieceModel = EquipPieceModel.new()
                local newItemData = {pid = itemData.id, add = itemData.num}
                equipPieceModel:InitWithCache(newItemData)
                self:InstantiateEquipBox(equipPieceModel, true)
            end
        end
    end
end

--- 构建卡牌奖励
function StoreItemContentCtrl:BuildCardReward()
    if type(self.rewardData.card) == "table" then
        local cardListData = self.rewardData.card
        if self.isReceive then
            for i, cardData in ipairs(cardListData) do
                self:InstantiateAvatarBox(cardData.cid)
            end
        else
            for i, cardData in ipairs(cardListData) do
                self:InstantiateAvatarBox(cardData.id)
            end
        end
    end
end

--- 实例化道具框
function StoreItemContentCtrl:InstantiateItemBox(itemModel)
    local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/ItemBox.prefab")
    itemBoxObj.transform:SetParent(self.parentTrans, false)
    itemBoxView:InitView(itemModel, itemModel:GetID(), self.isShowName, true, self.isShowDetail)
end

--- 实例化装备框
function StoreItemContentCtrl:InstantiateEquipBox(equipModel, isShowPiece)
    local equipBoxObj, equipBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/EquipBox.prefab")
    equipBoxObj.transform:SetParent(self.parentTrans, false)
    equipBoxView:InitView(equipModel, equipModel:GetEquipID(), self.isShowName, true, isShowPiece, self.isShowDetail)
end

--- 实例化球员头像框
function StoreItemContentCtrl:InstantiateAvatarBox(cardId)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PlayerAvatarBox.prefab")
    avatarBoxObj.transform:SetParent(self.parentTrans, false)
    avatarBoxView:InitView(cardId, true)
end

return StoreItemContentCtrl

