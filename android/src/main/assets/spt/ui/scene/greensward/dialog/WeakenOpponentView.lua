local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local WeakenOpponentView = class(unity.base, "WeakenOpponentView")

function WeakenOpponentView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
    -- 滑动框
    self.scroll = self.___ex.scroll
    -- 使用
    self.btnUse = self.___ex.btnUse
    self.buttonUse = self.___ex.buttonUse
end

function WeakenOpponentView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function WeakenOpponentView:InitView(WeakenOpponentModel)
    self.model = WeakenOpponentModel
    self.scroll:RegOnItemButtonClick("click", function(itemModel)
        self:OnItemClick(itemModel)
    end)
end

function WeakenOpponentView:UpdateItemView(idx, itemModel)
    self.scroll:UpdateItem(idx, itemModel)
end

function WeakenOpponentView:RefreshView()
    if not self.model then return end

    self.scroll:InitView(self.model:GetDatas())
    self:RefreshButtonState()
end

function WeakenOpponentView:RefreshButtonState()
    self.buttonUse.interactable = (self.model:GetSelectedItemModel() ~= nil)
end

function WeakenOpponentView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnUse:regOnButtonClick(function()
        self:OnBtnUse()
    end)
end

function WeakenOpponentView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function WeakenOpponentView:OnBtnUse()
    if self.onBtnUse ~= nil and type(self.onBtnUse) == "function" then
        self.onBtnUse()
    end
end

function WeakenOpponentView:OnItemClick(itemModel)
    if self.onItemClick and type(self.onItemClick) == "function" then
        self.onItemClick(itemModel)
    end
end

return WeakenOpponentView
