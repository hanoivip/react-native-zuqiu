local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local MemoryItemView = class(unity.base, "MemoryItemView")

local CircleCardPath = "Assets/CapstonesRes/Game/UI/Common/Card/Prefab/CircleCard.prefab"

local InactiveCircleCardPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChimicalCard.prefab"

function MemoryItemView:ctor()
    -- 激活&未激活
    self.objInactive = self.___ex.objInactive
    self.objActive = self.___ex.objActive
    -- 页签
    self.tabs = self.___ex.tabs
    -- 底部指示点儿
    self.indicators = self.___ex.indicators
    self.objTriLeft = self.___ex.objTriLeft
    self.objTriRight = self.___ex.objTriRight
    -- 各项加成描述
    self.detailScroll = self.___ex.detailScroll
    self.detailScrollRect = self.___ex.detailScrollRect
    self.rctContent = self.___ex.rctContent
    -- 没有选择球员
    self.txtNone = self.___ex.txtNone
    -- 左侧面板root
    self.objLeft = self.___ex.objLeft
    -- 按钮
    self.btnSwitch = self.___ex.btnSwitch
    self.txtSwitch = self.___ex.txtSwitch
    -- 右侧卡牌
    self.rctCard = self.___ex.rctCard
    -- 锁头
    self.imgLock = self.___ex.imgLock
    self.animLock = self.___ex.animLock

    self.datas = {} -- 每个页签下滑动数据
    self.cardSpt = nil
end

function MemoryItemView:start()
    self.btnSwitch:regOnButtonClick(function()
        self:OnSwitchCard()
    end)
end

function MemoryItemView:InitView(memoryItemModel)
    self.model = memoryItemModel
    local isFilledCard = self.model:IsFilledCard()
    local canUnlock = self.model:IsExistCardID()
    GameObjectHelper.FastSetActive(self.imgLock.gameObject, not isFilledCard)
    if not isFilledCard and self.model:HasImprove() then
        self.animLock:SetBool("CanUnlock", canUnlock)
    end
    GameObjectHelper.FastSetActive(self.txtNone.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnSwitch.gameObject, not self.model:IsOther())
    -- 页签显示
    local tabData = self.model:GetTabData()
    for tag, hasTab in pairs(tabData) do
        self.tabs:SetActive(tag, hasTab)
        self.tabs:BindMenuItem(tag, function()
            self:OnTabClick(tag)
        end)
    end
    self.tabs:selectMenuItem(self.model:GetCurrTab())
    -- 属性滑动区域
    self.detailScroll:regOnItemIndexChanged(function(idx)
        self:OnScrollItemIndexChanged(idx)
    end)
    self:RefreshScrollView()
    -- 实例化右侧卡牌
    res.ClearChildren(self.rctCard.transform)
    local obj, spt = res.Instantiate(isFilledCard and CircleCardPath or InactiveCircleCardPath)
    obj.transform:SetParent(self.rctCard.transform, false)
    self.cardSpt = spt
    self.cardSpt:InitView(self.model:GetFilledCard(), isFilledCard) -- CircleCardItem.lua or ChemicalCard.lua
    self.txtSwitch.text = lang.trans(isFilledCard and "guildwar_change2" or "activate") -- 更换 or 激活
end

-- 指示器和滑动列表一起初始化
function MemoryItemView:RefreshScrollView()
    self.datas = self.model:GetCurrTabDatas()
    local dataNum = #self.datas
    self.detailScrollRect.enabled = dataNum > 1
    -- 滑动页面至属性加成最大的一项
    local selectedIdx = 1
    for i = dataNum, 1, -1 do
        if self.datas[i] ~= nil and self.datas[i].isActive then
            selectedIdx = i
            break
        end
    end
    GameObjectHelper.FastSetActive(self.objTriLeft.gameObject, dataNum > 1)
    GameObjectHelper.FastSetActive(self.objTriRight.gameObject, dataNum > 1)
    self.indicators:InitView(dataNum, selectedIdx)
    self.detailScroll:InitView(self.datas)
    self.detailScroll:scrollToCellImmediate(selectedIdx)
end

function MemoryItemView:OnScrollItemIndexChanged(idx)
    local currData = self.datas[idx]
    GameObjectHelper.FastSetActive(self.objActive.gameObject, currData.isActive)
    GameObjectHelper.FastSetActive(self.objInactive.gameObject, not currData.isActive)
    self.indicators:GotoIndex(idx)
end

-- 点击某个页签
function MemoryItemView:OnTabClick(tab)
    if self.onTabClick and type(self.onTabClick) == "function" then
        self.onTabClick(tab)
    end
    self.model:SetCurrTab(tab)
    self:RefreshScrollView()
end

-- 点击按钮
function MemoryItemView:OnSwitchCard()
    res.PushDialog("ui.controllers.cardDetail.memory.CardMemorySelectCtrl", self.model)
end

return MemoryItemView
