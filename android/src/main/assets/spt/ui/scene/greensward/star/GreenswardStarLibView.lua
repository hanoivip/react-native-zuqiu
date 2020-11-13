local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GreenswardStarLibView = class(unity.base, "GreenswardStarLibView")

function GreenswardStarLibView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
    -- 滑动
    self.scrollView = self.___ex.scrollView
end

function GreenswardStarLibView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function GreenswardStarLibView:InitView(greenswardStarLibModel)
    self.model = greenswardStarLibModel
end

function GreenswardStarLibView:RefreshView()
    self.scrollView:InitView(self.model:GetStarModels())
end

function GreenswardStarLibView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function GreenswardStarLibView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return GreenswardStarLibView
