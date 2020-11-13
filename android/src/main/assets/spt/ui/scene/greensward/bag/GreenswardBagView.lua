local UnityEngine = clr.UnityEngine
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")
local GreenswardItemUseAfterType = require("ui.models.greensward.item.configType.GreenswardItemUseAfterType")
local GreenswardItemUseConType = require("ui.models.greensward.item.configType.GreenswardItemUseConType")
local GreenswardItemUseType = require("ui.models.greensward.item.configType.GreenswardItemUseType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GreenswardBagView = class(unity.base, "GreenswardBagView")

local itemPath = "Assets/CapstonesRes/Game/UI/Common/Part/AdventureItemBox.prefab"

function GreenswardBagView:ctor()
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
    -- 滑动列表
    self.scrollView = self.___ex.scrollView
    -- 详情面板
    self.txtTitleDetail = self.___ex.txtTitleDetail
    self.objDetail = self.___ex.objDetail
    self.rctIcon = self.___ex.rctIcon
    self.txtName = self.___ex.txtName
    self.txtNum = self.___ex.txtNum
    self.txtDesc = self.___ex.txtDesc
    self.objUseTip = self.___ex.objUseTip
    self.txtUseTip = self.___ex.txtUseTip
    self.btnUse = self.___ex.btnUse
    self.txtUse = self.___ex.txtUse

    self.detailItemSpt = nil -- 右侧详情的物品的控制脚本
end

function GreenswardBagView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function GreenswardBagView:InitView(greenswardBagModel)
    self.model = greenswardBagModel
    -- 页签
    self.tabs:BindMenuItem(tostring(GreenswardItemType.Comsumables), function()
        self:OnTabClick(GreenswardItemType.Comsumables)
    end)
    self.tabs:BindMenuItem(tostring(GreenswardItemType.Preserve), function()
        self:OnTabClick(GreenswardItemType.Preserve)
    end)
    -- 滑动列表
    self.scrollView:RegOnItemButtonClick("click", function(itemModel)
        self:OnItemClick(itemModel)
    end)
    -- 详情面板
    self.txtTitleDetail.text = lang.transstr("pd_title_me")
end

function GreenswardBagView:RefreshView()
    if not self.model then return end

    self.tabs:selectMenuItem(self.model:GetCurrTab())
    self:RefreshScrollView()
    self:RefreshDetailView()
end

-- 列表
function GreenswardBagView:RefreshScrollView()
    self.scrollView:InitView(self.model:GetCurrItemModels())
end

-- 右侧详情
function GreenswardBagView:RefreshDetailView()
    local currItemModel = self.model:GetSelectedItemModel()
    local hasModel = tobool(currItemModel ~= nil)
    GameObjectHelper.FastSetActive(self.objDetail.gameObject, hasModel)
    if not hasModel then return end

    -- 图标
    if not self.detailItemSpt then
        res.ClearChildren(self.rctIcon.transform)
        local obj, spt = res.Instantiate(itemPath)
        if obj and spt then
            obj.transform:SetParent(self.rctIcon.transform, false)
            self.detailItemSpt = spt
        end
    end
    self.detailItemSpt:InitView(currItemModel, currItemModel:GetId())
    -- 名称
    self.txtName.text = tostring(currItemModel:GetName())
    -- 数量
    self.txtNum.text = lang.trans("has_piece_num", currItemModel:GetOwnNum())
    -- 描述
    self.txtDesc.text = tostring(currItemModel:GetDesc())
    -- 使用类型
    local useType = currItemModel:GetUseType()
    if useType == GreenswardItemUseType.Direct then -- 直接可以使用
        GameObjectHelper.FastSetActive(self.objUseTip.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnUse.gameObject, true)
    elseif useType == GreenswardItemUseType.Conditional then -- 满足条件后在背包中使用
        -- 判断条件
        local useConditionType = currItemModel:GetUseConditionType()
        local useCondition = currItemModel:GetUseCondition()
        local canUse = false
        if useConditionType == GreenswardItemUseConType.Floor then
            local currFloor = tostring(self.model:GetCurrFloor())
            for k, v in pairs(useCondition) do
                if currFloor == v then
                    canUse = true
                    break
                end
            end
        end
        local isUsed = self.model:IsItemUsed(currItemModel)
        GameObjectHelper.FastSetActive(self.objUseTip.gameObject, not canUse or isUsed)
        GameObjectHelper.FastSetActive(self.btnUse.gameObject, canUse and not isUsed)
        self.txtUseTip.text = isUsed and tostring(currItemModel:GetUsedDesc()) or tostring(currItemModel:GetUseConditionTip())
    elseif useType == GreenswardItemUseType.Event then -- 事件处使用
        GameObjectHelper.FastSetActive(self.objUseTip.gameObject, true)
        GameObjectHelper.FastSetActive(self.btnUse.gameObject, false)
        self.txtUseTip.text = tostring(currItemModel:GetUseConditionTip())
    end
    -- 使用or查看
    local afterUseType = currItemModel:GetAfterUseType()
    if afterUseType == GreenswardItemUseAfterType.Usable then
        self.txtUse.text = lang.trans("use")
    elseif afterUseType == GreenswardItemUseAfterType.Viewonly then
        self.txtUse.text = lang.trans("check_formation")
    end
end

function GreenswardBagView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnUse:regOnButtonClick(function()
        self:OnUseItemClick()
    end)
end

function GreenswardBagView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function GreenswardBagView:OnEnterScene()
    EventSystem.AddEvent("Greensward_OnItemUsed", self, self.OnItemUsed)
    EventSystem.AddEvent("Greensward_Item_Reward", self, self.OnItemReward)
end

function GreenswardBagView:OnExitScene()
    EventSystem.RemoveEvent("Greensward_OnItemUsed", self, self.OnItemUsed)
    EventSystem.RemoveEvent("Greensward_Item_Reward", self, self.OnItemReward)
end

function GreenswardBagView:UpdateItemView(idx, itemModel)
    self.scrollView:UpdateItem(idx, itemModel)
end

-- 页签点击事件
function GreenswardBagView:OnTabClick(itemType)
    if self.onTabClick ~= nil and type(self.onTabClick) == "function" then
        self.onTabClick(itemType)
    end
end

-- 道具点击事件
function GreenswardBagView:OnItemClick(itemModel)
    if self.onItemClick and type(self.onItemClick) == "function" then
        self.onItemClick(itemModel)
    end
end

-- 使用道具
function GreenswardBagView:OnUseItemClick()
    local currItemModel = self.model:GetSelectedItemModel()
    if currItemModel == nil then return end

    if self.onUseItemClick ~= nil and type(self.onUseItemClick) == "function" then
        self.onUseItemClick(currItemModel)
    end
end

-- 使用道具后
function GreenswardBagView:OnItemUsed()
    if self.onItemUsed ~= nil and type(self.onItemUsed) == "function" then
        self.onItemUsed()
    end
    self:RefreshView()
end

-- 获得道具后
function GreenswardBagView:OnItemReward()
    if self.onItemReward ~= nil and type(self.onItemReward) == "function" then
        self.onItemReward()
    end
    self:RefreshView()
end

return GreenswardBagView
