local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CardMemorySelectView = class(unity.base, "CardMemorySelectView")

function CardMemorySelectView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
    -- 滑动列表
    self.scroll = self.___ex.scroll
    -- 确认
    self.btnConfirm = self.___ex.btnConfirm
    self.buttonConfirm = self.___ex.buttonConfirm
    -- 排序
    self.sortView = self.___ex.sortView
    self.txtNone = self.___ex.txtNone
end

function CardMemorySelectView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CardMemorySelectView:InitView(cardMemorySelectModel)
    self.model = cardMemorySelectModel
    self:InitSortView()
    local cardModels = self.model:GetCardModels()
    if #cardModels > 0 then
        GameObjectHelper.FastSetActive(self.txtNone.gameObject, false)
        -- 列表
        self.scroll:RegOnItemButtonClick("btnClick", function(cardModel)
            self:OnScrollItemClick(cardModel)
        end)
        self:RefreshScrollView()
    else
        GameObjectHelper.FastSetActive(self.txtNone.gameObject, true)
        self.txtNone.text = lang.trans("memory_select_none", self.model:GetQualityStr()) -- 暂无符合条件的A品质卡牌
    end
    self:UpdateBtnConfirm()
end

function CardMemorySelectView:InitSortView()
    self.sortView:InitView(self.model)
    self.sortView:selectMenuItem(self.model:GetCurrSortType())
    -- 注册点击回调
    for k, sortType in pairs(self.model.SortType) do
        self.sortView:BindMenuItem(sortType, function()
            self:OnSortClick(sortType)
        end)
    end
end

function CardMemorySelectView:RefreshScrollView()
    self.scroll:InitView(self.model:GetCardModels(), self.model)
end

function CardMemorySelectView:UpdateScrollItem(idx, cardModel)
    self.scroll:UpdateItem(idx, cardModel)
end

function CardMemorySelectView:UpdateBtnConfirm()
    self.buttonConfirm.interactable = self.model:GetSelectedCard() ~= nil
end

function CardMemorySelectView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function CardMemorySelectView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 点击排序按钮
function CardMemorySelectView:OnSortClick(sortType)
    if self.onSortClick and type(self.onSortClick) == "function" then
        self.onSortClick(sortType)
    end
end

-- 点击列表中球员
function CardMemorySelectView:OnScrollItemClick(cardModel)
    if self.onScrollItemClick and type(self.onScrollItemClick) == "function" then
        self.onScrollItemClick(cardModel)
    end
end

-- 点击确定
function CardMemorySelectView:OnBtnConfirm()
    if self.onBtnConfirm and type(self.onBtnConfirm) == "function" then
        self.onBtnConfirm()
    end
end

-- 确认选择后更新
function CardMemorySelectView:UpdateAfterConfirm()
    EventSystem.SendEvent("CardMemory_OnChangeMemoryCard")
end

return CardMemorySelectView
