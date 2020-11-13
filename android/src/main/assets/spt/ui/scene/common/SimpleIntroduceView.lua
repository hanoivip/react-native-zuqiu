local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local SimpleIntroduceView = class(unity.base, "SimpleIntroduceView")

function SimpleIntroduceView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 介绍文本
    self.txtIntro = self.___ex.txtIntro
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
end

function SimpleIntroduceView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function SimpleIntroduceView:InitView(simpleIntroduceModel)
    self.model = simpleIntroduceModel
    -- 设置面板大小
    local width, height = self.model:GetBoardSize()
    self.rctBoard.sizeDelta = Vector2(width, height)
    -- 设置面板位置
    local x, y = self.model:GetBoardPos()
    self.rctBoard.anchoredPosition = Vector2(x, y)
    -- 设置面板是否显示关闭按钮
    GameObjectHelper.FastSetActive(self.btnClose.gameObject, self.model:IsShowBtnClose())
    -- 设置标题
    self.txtTitle.text = self.model:GetTitle()
    -- 设置内容
    self.txtIntro.text = self.model:GetIntro()
end

function SimpleIntroduceView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function SimpleIntroduceView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return SimpleIntroduceView
