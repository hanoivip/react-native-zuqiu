local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local SpecialEventsRecordView = class(unity.base)

function SpecialEventsRecordView:ctor()
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    self.latestArea = self.___ex.latestArea
    self.itemRes = self.___ex.itemRes
end

function SpecialEventsRecordView:InitView(model)
    self.model = model
    if self.model and self.model.minPower and #self.model.minPower == 1 then
        self.itemRes:SetActive(true)
        local script = res.GetLuaScript(self.itemRes)
        script:InitView(self.model.minPower[1])
        self:BindItemButtons(script, self.model.minPower[1])
    else
        self.itemRes:SetActive(false)
    end

    res.ClearChildren(self.latestArea)
    if self.model and self.model.latest then
        for k, v in pairs(self.model.latest) do
            local item = Object.Instantiate(self.itemRes)
            item:SetActive(true)
            item.transform:SetParent(self.latestArea, false)
            local script = res.GetLuaScript(item)
            script:InitView(v)
            self:BindItemButtons(script, v)
        end
    end
end

function SpecialEventsRecordView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function SpecialEventsRecordView:BindButtonHandler()
    self.btnClose:regOnButtonClick(
        function()
            self:Close()
        end
    )
end

function SpecialEventsRecordView:BindItemButtons(itemScript, itemModel)
    itemScript.formationButton:regOnButtonClick(
        function()
            self.onFormationButtonClick(itemModel)
        end
    )
    itemScript.videoButton:regOnButtonClick(
        function()
            self.onVideoButtonClick(itemModel)
        end
    )
end

function SpecialEventsRecordView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function SpecialEventsRecordView:PlayOutAnimator()
    DialogAnimation.Disappear(
        self.transform,
        self.canvasGroup,
        function()
            self:CloseView()
        end
    )
end

function SpecialEventsRecordView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function SpecialEventsRecordView:Close()
    self:PlayOutAnimator()
end

return SpecialEventsRecordView
