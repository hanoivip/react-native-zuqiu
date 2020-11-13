local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local MysticHintRcvDialogView = class(unity.base, "MysticHintRcvDialogView")

function MysticHintRcvDialogView:ctor()
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
end

function MysticHintRcvDialogView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function MysticHintRcvDialogView:InitView(greenswardBuildModel, contents)
    self.buildModel = greenswardBuildModel
    self.contents = contents
end

function MysticHintRcvDialogView:RefreshView()
    local advItem = self.contents.advItem or {}
    if table.isEmpty(advItem) then
        self:Close()
        return
    end
end

function MysticHintRcvDialogView:RegBtnEvent()
end

function MysticHintRcvDialogView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
    self:ShowGuide()
end

function MysticHintRcvDialogView:ShowGuide()
    local currentFloor = self.buildModel:GetCurrentFloor()
    GuideManager.InitCurModule("adventureF" .. currentFloor)
    GuideManager.Show(self)
end

return MysticHintRcvDialogView
