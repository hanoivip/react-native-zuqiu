local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local MemoryPageView = class(unity.base, "MemoryPageView")

local Scroll_Enable_Threshold = 3 -- 超过两个开启滑动

-- 根据item个数调整背景高度
local Bg_Height = {
    ["0"] = 655,
    ["1"] = 256,
    ["2"] = 480,
    ["3"] = 655
}

function MemoryPageView:ctor()
    self.bg = self.___ex.bg
    self.rctBg = self.___ex.rctBg
    self.scroll = self.___ex.scroll
    self.scrollRect = self.___ex.scrollRect
    self.scrollBar = self.___ex.scrollBar
    self.txtNone = self.___ex.txtNone
end

function MemoryPageView:start()
end

function MemoryPageView:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.cardModel = cardDetailModel:GetCardModel()
    self.bg.overrideSprite = cardDetailModel:GetImageRes("bottomChemical")
    self:RefreshView()
end

function MemoryPageView:RefreshView()
    local memoryItemModels = self.cardModel:GetMemoryItemModels(true)
    local itemNum = math.clamp(#memoryItemModels, 0, Scroll_Enable_Threshold)
    local isScrollEnable = itemNum >= Scroll_Enable_Threshold

    -- 设置背景高度
    self.rctBg.sizeDelta = Vector2(self.rctBg.sizeDelta.x, Bg_Height[tostring(itemNum)])
    -- 设置是否开启滑动
    self.scrollRect.enabled = isScrollEnable
    GameObjectHelper.FastSetActive(self.scrollBar.gameObject, isScrollEnable)
    -- 是否有相关球员数据
    GameObjectHelper.FastSetActive(self.txtNone.gameObject, itemNum <= 0)
    self.scroll:InitView(memoryItemModels)
end

function MemoryPageView:EnterScene()
    EventSystem.AddEvent("CardMemory_OnChangeMemoryCard", self, self.OnChangeMemoryCard)
end

function MemoryPageView:ExitScene()
    EventSystem.RemoveEvent("CardMemory_OnChangeMemoryCard", self, self.OnChangeMemoryCard)
end

function MemoryPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function MemoryPageView:OnChangeMemoryCard()
    self:RefreshView()
end

return MemoryPageView
