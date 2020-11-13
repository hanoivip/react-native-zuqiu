local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local GreenswardItemUseAfterType = require("ui.models.greensward.item.configType.GreenswardItemUseAfterType")
local GreenswardItemUseConType = require("ui.models.greensward.item.configType.GreenswardItemUseConType")
local GreenswardItemUseType = require("ui.models.greensward.item.configType.GreenswardItemUseType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")

local GreenswardStoreView = class(unity.base, "GreenswardStoreView")

local AvatarPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Avatar/GreenswardAvatar.prefab"

function GreenswardStoreView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
    -- 页签按钮
    self.tabs = self.___ex.tabs

    -- 详情面板
    self.objDetailView = self.___ex.objDetailView
    self.objDetail = self.___ex.objDetail
    self.rctDetailAvatar = self.___ex.rctDetailAvatar
    self.txtDetailName = self.___ex.txtDetailName
    self.btnBuy = self.___ex.btnBuy
    self.txtPurchased = self.___ex.txtPurchased
    self.imgCurrencyIcon = self.___ex.imgCurrencyIcon
    self.txtPrice = self.___ex.txtPrice

    -- 不同售卖面板
    self.objBoards = self.___ex.objBoards
    -- 不同滑动列表
    self.scrollViews = self.___ex.scrollViews

    self.detailItemSpt = nil -- 右侧详情的物品的控制脚本
end

function GreenswardStoreView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self:ShowDisplayArea(false)
end

function GreenswardStoreView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.rctBoard.gameObject, isShow)
end

function GreenswardStoreView:InitView(greenswardStoreModel)
    self.model = greenswardStoreModel
    if not self.model then return end

    -- 绑定页签按钮事件
    for k, storeType in pairs(self.model.StoreType) do
        storeType = tostring(storeType)
        self.tabs:BindMenuItem(storeType, function()
            self:OnTabClick(storeType)
        end)
        self.tabs:SetActive(storeType, self.model.StoreOpen[k])
    end
    -- 滑动列表
    for storeType, scroll in pairs(self.scrollViews) do
        if storeType ~= self.model.StoreType.ItemStore then
            scroll:RegOnItemButtonClick("btnClick", function(itemModel)
                self:OnItemClick(itemModel)
            end)
        else
            scroll:RegOnItemButtonClick("btnPrice", function(itemModel)
                self:OnBtnItemBuyClick(itemModel)
            end)
        end
    end
end

function GreenswardStoreView:RefreshView()
    if not self.model then return end
    self:ShowDisplayArea(true)

    local currStoreType = self.model:GetCurrTab()
    self.tabs:selectMenuItem(currStoreType)
    self:SwtichToBoard(currStoreType)
end

-- 切换到某一面板
function GreenswardStoreView:SwtichToBoard(currStoreType)
    for storeType, objBoard in pairs(self.objBoards or {}) do
        GameObjectHelper.FastSetActive(objBoard.gameObject, storeType == currStoreType)
    end
    self:RefreshBoardView(currStoreType)
    self:RefreshDetailView()
end

-- 刷新某一面板显示
function GreenswardStoreView:RefreshBoardView(currStoreType)
    if self.scrollViews[currStoreType] then
        self.scrollViews[currStoreType]:InitView(self.model:GetCurrItemModels())
    end
end

function GreenswardStoreView:UpdateItemView(idx, itemModel)
    local currStoreType = self.model:GetCurrTab()
    if self.scrollViews[currStoreType] then
        self.scrollViews[currStoreType]:UpdateItem(idx, itemModel)
    end
end

function GreenswardStoreView:RefreshDetailView()
    local currStoreType = self.model:GetCurrTab()
    local isShow = (currStoreType == self.model.StoreType.Logo or currStoreType == self.model.StoreType.Frame)
    GameObjectHelper.FastSetActive(self.objDetailView.gameObject, isShow)
    if not isShow then return end

    local storeItemModel = self.model:GetSelectedItemModel() -- GreenswardStoreItemModel
    local hasModel = tobool(storeItemModel ~= nil)
    GameObjectHelper.FastSetActive(self.objDetail.gameObject, hasModel)
    if not hasModel then return end

    local contents = storeItemModel:GetContents()
    local hasContents = not table.isEmpty(contents) or not table.isEmpty(contents.advItem)
    GameObjectHelper.FastSetActive(self.objDetail.gameObject, hasContents)
    if not hasContents then return end

    local advItem = contents.advItem
    for k, v in ipairs(advItem) do
        local greenswardItemModel = GreenswardItemModel.new(v.id, v.num)
        -- 徽章or边框
        if not self.detailItemSpt then
            res.ClearChildren(self.rctDetailAvatar.transform)
            local obj, spt = res.Instantiate(AvatarPath)
            if obj and spt then
                obj.transform:SetParent(self.rctDetailAvatar.transform, false)
                self.detailItemSpt = spt
            end
        end
        local logoPic = nil
        local framePic = nil
        local currLogoPic, currFramePic = self.model:GetCurrAvatarPicIndex()
        if currStoreType == self.model.StoreType.Logo then
            logoPic = greenswardItemModel:GetPicIndex()
            framePic = currFramePic
        elseif currStoreType == self.model.StoreType.Frame then
            logoPic = currLogoPic
            framePic = greenswardItemModel:GetPicIndex()
        end
        self.detailItemSpt:InitView(logoPic, framePic)
        self.txtDetailName.text = greenswardItemModel:GetName()
    end
    self.imgCurrencyIcon.overrideSprite = res.LoadRes(CurrencyImagePath[storeItemModel:GetCurrencyType()])
    self.txtPrice.text = "X" .. tostring(storeItemModel:GetPrice())
    -- 已购情况
    local hasBought = storeItemModel:GetBought() > 0
    GameObjectHelper.FastSetActive(self.btnBuy.gameObject, not hasBought)
    GameObjectHelper.FastSetActive(self.txtPurchased.gameObject, hasBought)
end

function GreenswardStoreView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnBuy:regOnButtonClick(function()
        self:OnBtnBuyClick()
    end)
end

function GreenswardStoreView:OnEnterScene()
end

function GreenswardStoreView:OnExitScene()
end

function GreenswardStoreView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 页签点击事件
function GreenswardStoreView:OnTabClick(storeType)
    if self.onTabClick ~= nil and type(self.onTabClick) == "function" then
        self.onTabClick(storeType)
    end
end

-- 商品点击事件
function GreenswardStoreView:OnItemClick(storeItemModel)
    if self.onItemClick and type(self.onItemClick) == "function" then
        self.onItemClick(storeItemModel)
    end
end

-- 购买
function GreenswardStoreView:OnBtnBuyClick()
    if self.onBtnBuyClick and type(self.onBtnBuyClick) == "function" then
        self.onBtnBuyClick()
    end
end

function GreenswardStoreView:OnBtnItemBuyClick(storeItemModel)
    if self.onBtnItemBuyClick and type(self.onBtnItemBuyClick) == "function" then
        self.onBtnItemBuyClick(storeItemModel)
    end
end

-- 购买徽章&边框后更新
function GreenswardStoreView:UpdateAfterPurchased()
    self:UpdateItemView(self.model:GetSelectedIdx(), self.model:GetSelectedItemModel())
    self:RefreshDetailView()
end

function GreenswardStoreView:UpdateAfterPurchasedItem(storeItemModel)
    self:UpdateItemView(storeItemModel:GetIdx(), storeItemModel)
end

return GreenswardStoreView
