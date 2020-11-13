local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local GuideView = class(unity.base)

function GuideView:ctor()
    self.btnContinue = self.___ex.btnContinue
    self.txtDialog = self.___ex.txtDialog
end

function GuideView:start()
    if self.btnContinue then
        self.btnContinue:regOnButtonClick(function()
            self:OnContinue()
        end)
    end
end

function GuideView:InitView(callBack)
    local playerInfoModel = PlayerInfoModel.new()
    self.callBack = callBack
    if self.txtDialog then
        self.txtDialog.text = lang.trans(GuideManager.guideModel:GetDialogText(GuideManager.guideModel:GetCurStep()), playerInfoModel:GetName())
    end
end

function GuideView:OnContinue()
    if self.callBack then
        self.callBack()
    end
    GuideManager.Show(GuideManager.moduleInstance)
end

return GuideView