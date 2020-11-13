local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local MenuBarCtrl = require("ui.controllers.common.MenuBarCtrl")
local SpecialEventsMainModel = require("ui.models.specialEvents.SpecialEventsMainModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")
local SpecialEventsMainCtrl = class(BaseCtrl)

SpecialEventsMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/SpecialEventsMain.prefab"

function SpecialEventsMainCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(
        function(child)
            self.infoBarCtrl = InfoBarCtrl.new(child, self)
            self.infoBarCtrl:RegOnBtnBack(
                function()
                    res.PopScene()
                end
            )
        end
    )

    self.view.scrollView:RegOnItemButtonClick(
        "itemButton",
        function(model)
            self:OnFlagClick(model)
        end
    )

    self.view.helpBtn:regOnButtonClick(
        function()
            self:OnHelpButtonClick()
        end
    )
end

function SpecialEventsMainCtrl:Refresh(scrollNormalizedPosition)
    if self.model then
        self.view:InitView(self.model)
        if scrollNormalizedPosition then
            self.view.scrollView:SetScrollNormalizedPosition(scrollNormalizedPosition)
        end
    end
end

function SpecialEventsMainCtrl:AheadRequest()
        local respone = req.specificIndex()
        if api.success(respone) then
            local data = respone.val
            self.model = SpecialEventsMainModel.new()
            self.model:InitWithProtocol(data)
            cache.setSpecialEvents(self.model, true)
        end
end

function SpecialEventsMainCtrl:OnEnterScene()
end

function SpecialEventsMainCtrl:OnExitScene()
end

function SpecialEventsMainCtrl:OnFlagClick(model)
    res.PushScene("ui.controllers.specialEvents.SpecialEventsDifficultyCtrl", model.id)
end

function SpecialEventsMainCtrl:OnHelpButtonClick()
    res.ShowDialog(
        "Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/SpecialEventsRuleBoard.prefab",
        "camera",
        true,
        true
    )
end

function SpecialEventsMainCtrl:GetStatusData()
    return self.view.scrollView:GetScrollNormalizedPosition()
end

return SpecialEventsMainCtrl
