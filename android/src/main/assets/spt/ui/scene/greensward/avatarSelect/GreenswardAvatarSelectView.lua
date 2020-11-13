local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local GreenswardAccessType = require("ui.models.greensward.item.configType.GreenswardAccessType")
local GreenswardStoreType = require("ui.models.greensward.store.GreenswardStoreType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")
local GreenswardStoreItemModel = require("ui.models.greensward.store.GreenswardStoreItemModel")

local GreenswardAvatarSelectView = class(unity.base, "GreenswardAvatarSelectView")

local AvatarPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Avatar/GreenswardAvatar.prefab"

function GreenswardAvatarSelectView:ctor()
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
    -- 购买按钮
    self.btnBuy = self.___ex.btnBuy
    self.imgCurrencyIcon = self.___ex.imgCurrencyIcon
    self.txtPrice = self.___ex.txtPrice
    self.txtAccessDesc = self.___ex.txtAccessDesc
    -- 更换按钮
    self.btnSwitch = self.___ex.btnSwitch
    self.txtUsed = self.___ex.txtUsed

    -- 不同面板
    self.objBoards = self.___ex.objBoards
    -- 不同滑动列表
    self.scrollViews = self.___ex.scrollViews

    self.detailItemSpt = nil -- 右侧详情的物品的控制脚本
end

function GreenswardAvatarSelectView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self:ShowDisplayArea(false)
end

function GreenswardAvatarSelectView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.rctBoard.gameObject, isShow)
end

function GreenswardAvatarSelectView:InitView(greenswardStoreModel)
    self.model = greenswardStoreModel
    if not self.model then return end

    -- 绑定页签按钮事件
    for k, storeType in pairs(self.model.AvatarType) do
        storeType = tostring(storeType)
        self.tabs:BindMenuItem(storeType, function()
            self:OnTabClick(storeType)
        end)
    end
    -- 滑动列表
    for storeType, scroll in pairs(self.scrollViews) do
        scroll:RegOnItemButtonClick("btnClick", function(itemModel)
            self:OnItemClick(itemModel)
        end)
    end
end

function GreenswardAvatarSelectView:RefreshView()
    if not self.model then return end
    self:ShowDisplayArea(true)

    local currAvatarType = self.model:GetCurrTab()
    self.tabs:selectMenuItem(currAvatarType)
    self:SwtichToBoard(currAvatarType)
end

-- 切换到某一面板
function GreenswardAvatarSelectView:SwtichToBoard(currAvatarType)
    for storeType, objBoard in pairs(self.objBoards or {}) do
        GameObjectHelper.FastSetActive(objBoard.gameObject, storeType == currAvatarType)
    end
    self:RefreshBoardView(currAvatarType)
    self:RefreshDetailView()
end

-- 刷新某一面板显示
function GreenswardAvatarSelectView:RefreshBoardView(currAvatarType)
    if self.scrollViews[currAvatarType] then
        self.scrollViews[currAvatarType]:InitView(self.model:GetCurrItemModels())
    end
end

function GreenswardAvatarSelectView:UpdateItemView(idx, itemModel)
    local currAvatarType = self.model:GetCurrTab()
    if self.scrollViews[currAvatarType] then
        self.scrollViews[currAvatarType]:UpdateItem(idx, itemModel)
    end
end

function GreenswardAvatarSelectView:RefreshDetailView()
    local currAvatarType = self.model:GetCurrTab()

    local itemModel = self.model:GetSelectedItemModel() -- GreenswardItemModel
    local hasModel = tobool(itemModel ~= nil)
    GameObjectHelper.FastSetActive(self.objDetail.gameObject, hasModel)
    if not hasModel then return end

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
    local currLogo = self.model:GetCurrBadgeId()
    local currFrame = self.model:GetCurrFrameId()
    local currId = nil
    if currAvatarType == self.model.AvatarType.Logo then
        logoPic = itemModel:GetPicIndex()
        framePic = currFramePic
        currId = currLogo
    elseif currAvatarType == self.model.AvatarType.Frame then
        logoPic = currLogoPic
        framePic = itemModel:GetPicIndex()
        currId = currFrame
    end
    self.detailItemSpt:InitView(logoPic, framePic)
    self.txtDetailName.text = itemModel:GetName()

    if itemModel:GetOwnNum() <= 0 then -- 未拥有
        self:RefreshBtnSwitch(false)
        self:RefreshTxtUsed(false)
        local access = itemModel:GetAccessType()
        if access == GreenswardAccessType.Initial then -- 初始给的
            GameObjectHelper.FastSetActive(self.btnBuy.gameObject, false)
            self:RefreshAccessDesc(true, itemModel)
            self:RefreshBtnBuy(false)
        elseif access == GreenswardAccessType.Purchase then -- 通过商店购买获得
            self:RefreshAccessDesc(false)
            self:RefreshBtnBuy(true, itemModel)
        else
            self:RefreshAccessDesc(true, itemModel)
            self:RefreshBtnBuy(false)
        end
    else -- 已拥有
        self:RefreshBtnBuy(false)
        self:RefreshAccessDesc(false)
        local itemId = itemModel:GetId()
        self:RefreshBtnSwitch(itemId ~= currId, itemModel)
        self:RefreshTxtUsed(itemId == currId, itemModel)
    end
end

function GreenswardAvatarSelectView:RefreshBtnBuy(isShow, itemModel)
    local flag = itemModel ~= nil and isShow
    GameObjectHelper.FastSetActive(self.btnBuy.gameObject, flag)
    if flag then
        local storeItemMoel = self.model:GetAccessStoreItemModel(itemModel)
        if storeItemMoel ~= nil then
            self.imgCurrencyIcon.overrideSprite = res.LoadRes(CurrencyImagePath[storeItemMoel:GetCurrencyType()])
            self.txtPrice.text = "X" .. tostring(storeItemMoel:GetPrice())
        else
            GameObjectHelper.FastSetActive(self.btnBuy.gameObject, false)
        end
    end
end

function GreenswardAvatarSelectView:RefreshAccessDesc(isShow, itemModel)
    local flag = itemModel ~= nil and isShow
    GameObjectHelper.FastSetActive(self.txtAccessDesc.gameObject, flag)
    if flag then
        self.txtAccessDesc.text = tostring(itemModel:GetAccessDesc())
    end
end

function GreenswardAvatarSelectView:RefreshBtnSwitch(isShow, itemModel)
    GameObjectHelper.FastSetActive(self.btnSwitch.gameObject, itemModel ~= nil and isShow)
end

function GreenswardAvatarSelectView:RefreshTxtUsed(isShow, itemModel)
    GameObjectHelper.FastSetActive(self.txtUsed.gameObject, itemModel ~= nil and isShow)
end

-- 注册按钮事件
function GreenswardAvatarSelectView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnBuy:regOnButtonClick(function()
        self:OnBtnBuyClick()
    end)
    self.btnSwitch:regOnButtonClick(function()
        self:OnBtnSwitchClick()
    end)
end

function GreenswardAvatarSelectView:OnEnterScene()
end

function GreenswardAvatarSelectView:OnExitScene()
end

function GreenswardAvatarSelectView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 页签点击事件
function GreenswardAvatarSelectView:OnTabClick(storeType)
    if self.onTabClick ~= nil and type(self.onTabClick) == "function" then
        self.onTabClick(storeType)
    end
end

-- 徽章&边框item点击事件
function GreenswardAvatarSelectView:OnItemClick(storeItemModel)
    if self.onItemClick and type(self.onItemClick) == "function" then
        self.onItemClick(storeItemModel)
    end
end

-- 购买
function GreenswardAvatarSelectView:OnBtnBuyClick()
    if self.onBtnBuyClick and type(self.onBtnBuyClick) == "function" then
        self.onBtnBuyClick()
    end
end

-- 更换
function GreenswardAvatarSelectView:OnBtnSwitchClick()
    if self.onBtnSwitchClick and type(self.onBtnSwitchClick) == "function" then
        self.onBtnSwitchClick()
    end
end

-- 购买徽章&边框后更新
function GreenswardAvatarSelectView:UpdateAfterPurchased()
    self:RefreshBoardView(self.model:GetCurrTab())
    self:RefreshDetailView()
end

-- 更换
function GreenswardAvatarSelectView:UpdateAfterSwitch()
    self:RefreshBoardView(self.model:GetCurrTab())
    self:RefreshDetailView()
    EventSystem.SendEvent("Greensward_AvatarChange")
end

return GreenswardAvatarSelectView
