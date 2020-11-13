local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local DigEventModel = class(GeneralEventModel, "DigEventModel")

function DigEventModel:ctor()
    DigEventModel.super.ctor(self)
    self:SetTip("unDig_tip")
    self:SetUIParam({icon_pos = {x = 0, y = 20, z = 0}, icon_scale = {x = 1.2, y = 1.2, z = 1.2}})
    self:SetContentText(lang.trans("adventure_dig_tips"))
    self:SetMoraleButtonDesc(lang.trans("adventure_dig_desc"))
    self:SetLeaveButtonDesc(lang.trans("adventure_dig_leave_tip"))
    self:SetBottomBoardName("Dig_Dlog")
    self:SetTweenExtension(true)
    self:SetCtrlPath("ui.controllers.greensward.dialog.GeneralDialogCtrl")
end

return DigEventModel