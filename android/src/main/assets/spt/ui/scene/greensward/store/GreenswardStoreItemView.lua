local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ItemType = require("ui.scene.itemList.ItemType")

local GreenswardStoreItemView = class(unity.base, "GreenswardStoreItemView")

local avatarPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Avatar/GreenswardAvatar.prefab"

function GreenswardStoreItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtDesc = self.___ex.txtDesc
    self.txtPrice = self.___ex.txtPrice
    self.btnPrice = self.___ex.btnPrice
    self.imgCurrencyIcon = self.___ex.imgCurrencyIcon
    self.rctIcon = self.___ex.rctIcon
end

function GreenswardStoreItemView:start()
end

function GreenswardStoreItemView:InitView(greenswardStoreItemModel)
    self.storeItemModel = greenswardStoreItemModel or {}
    local contents = self.storeItemModel:GetContents()
    if table.isEmpty(contents) then return end

    res.ClearChildren(self.rctIcon.transform)
    local rewardParams = {
        parentObj = self.rctIcon,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isSavedItemModel = true,
    }
    local rewardDataCtrl = RewardDataCtrl.new(rewardParams)
    local savedItemModels = rewardDataCtrl:GetSavedItemModels()
    local itemType = self.storeItemModel:GetItemType()
    if CurrencyImagePath[itemType] ~= nil then
        self.storeItemModel:SetCorrelationItemModel(savedItemModels[itemType])
    else
        self.storeItemModel:SetCorrelationItemModel(savedItemModels[itemType][1])
    end

    self.txtName.text = tostring(self.storeItemModel:GetName())
    self.txtDesc.text = self.storeItemModel:GetLimitDesc()
    self.txtPrice.text = "X" .. tostring(self.storeItemModel:GetPrice())
    self.imgCurrencyIcon.overrideSprite = res.LoadRes(CurrencyImagePath[self.storeItemModel:GetCurrencyType()])
end

function GreenswardStoreItemView:SetPurchased(flag)
    self.isPurchased = flag
end

function GreenswardStoreItemView:SetSelected(flag)
    self.isSelected = flag
end

return GreenswardStoreItemView
