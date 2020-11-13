local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MysticHintDialogView = class(unity.base, "MysticHintDialogView")

function MysticHintDialogView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    self.txtContent = self.___ex.txtContent
    self.btnIntro = self.___ex.btnIntro
end

function MysticHintDialogView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function MysticHintDialogView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.txtContent.gameObject, isShow)
end

function MysticHintDialogView:InitView(mysticHintDialogModel)
    self.model = mysticHintDialogModel
end

function MysticHintDialogView:RefreshView()
    if not self.model then
        self:ShowDisplayArea(false)
        return
    end

    local itemModle = self.model:GetItemModel()
    self.txtTitle.text = itemModle:GetName()
    local data = self.model:GetData()
    local content = ""
    for k, v in ipairs(data) do
        content = content .. lang.transstr("question_order", k) .. v .. "\n\n"
    end
    self.txtContent.text = content
end

function MysticHintDialogView:RegBtnEvent()
    self.btnIntro:regOnButtonClick(function()
        if self.onBtnIntroClick ~= nil and type(self.onBtnIntroClick) == "function" then
            self.onBtnIntroClick()
        end
    end)
end

function MysticHintDialogView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return MysticHintDialogView
