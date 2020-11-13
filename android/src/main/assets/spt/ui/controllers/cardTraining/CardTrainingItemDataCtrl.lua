local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local ItemModel = require("ui.models.cardDetail.ItemModel")

local CardTrainingItemDataCtrl = class(RewardDataCtrl, "CardTrainingItemDataCtrl")

function CardTrainingItemDataCtrl:ctor(params, cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    CardTrainingItemDataCtrl.super.ctor(self, params)
end

--- 构建基础奖励
function CardTrainingItemDataCtrl:BuildBaseReward()
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
end

--- 实例化装备框
function CardTrainingItemDataCtrl:InstantiateEquipBox(equipModel, isShowPiece)
    local equipBoxObj, equipBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/Part/EquipBox.prefab")
    equipBoxObj.transform:SetParent(self.parentTrans, false)
    equipBoxView:InitViewWithCount(equipModel, equipModel:GetEquipID(), self.isShowName, self.isShowCount, isShowPiece, self.isShowDetail, ItemOriginType.OTHER, self.cardTrainingMainModel)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            equipBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
    end
end

--- 实例化道具框
function CardTrainingItemDataCtrl:InstantiateItemBox(itemModel)
    local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/Part/ItemBox.prefab")
    itemBoxObj.transform:SetParent(self.parentTrans, false)
    itemBoxView:InitViewWithCount(itemModel, itemModel:GetID(), self.isShowName, self.isShowCount, self.isShowDetail, ItemOriginType.OTHER, self.cardTrainingMainModel)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            itemBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then 
            itemBoxView:SetNumFont(self.itemParams.numFont)
        end
    end
end

--- 实例化球员碎片
function CardTrainingItemDataCtrl:InstantiateCardPieceBox(cardPieceModel)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/Part/CardPiece.prefab")
    avatarBoxObj.transform:SetParent(self.parentTrans, false)
    avatarBoxView:InitViewWithTrainingModel(cardPieceModel, self.isShowName, self.isShowCount, self.isShowDetail, self.cardTrainingMainModel)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            avatarBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then 
            avatarBoxView:SetNumFont(self.itemParams.numFont)
        end
    end
end

--- 实例化球员贴纸碎片
function CardTrainingItemDataCtrl:InstantiateCardPasterPieceBox(cardPasterPieceModel)
    local avatarBoxObj, avatarBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/Part/CardPiece.prefab")
    avatarBoxObj.transform:SetParent(self.parentTrans, false)
    avatarBoxView:InitViewWithTrainingModel(cardPasterPieceModel, self.isShowName, self.isShowCount, self.isShowDetail, self.cardTrainingMainModel)
    if self.itemParams ~= nil then
        if self.itemParams.nameColor ~= nil and self.itemParams.nameShadowColor ~= nil then
            avatarBoxView:SetNameColor(self.itemParams.nameColor, self.itemParams.nameShadowColor)
        end
        if self.itemParams.numFont ~= nil then 
            avatarBoxView:SetNumFont(self.itemParams.numFont)
        end
    end
end

function CardTrainingItemDataCtrl:BuildMedalReward()
    if type(self.rewardData.medal) == "table" then
        local medalListData = self.rewardData.medal
        if medalListData.defualt then
            self:InstantiateMedalBox(nil)
            return
        end
        for i, medalData in ipairs(medalListData) do
            local medalModel = PlayerMedalModel.new()
            local newMedalData = {medalId = medalData.id, add = medalData.num}
            medalModel:InitWithCache(newMedalData)
            self:InstantiateMedalBox(medalModel)
        end
    end
end
--- 实例化勋章
function CardTrainingItemDataCtrl:InstantiateMedalBox(medalModel)
    local medalBoxObj, medalBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/Part/MedalBox.prefab")
    medalBoxObj.transform:SetParent(self.parentTrans, false)
    medalBoxView:InitView(medalModel, self.isShowName, self.isShowCount, self.isShowDetail, self.cardTrainingMainModel)
end


return CardTrainingItemDataCtrl
