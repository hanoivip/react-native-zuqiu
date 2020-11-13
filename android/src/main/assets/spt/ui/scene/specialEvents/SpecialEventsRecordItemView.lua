local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local SpecialEventsRecordItemView = class(unity.base)

function SpecialEventsRecordItemView:ctor()
    self.teamLogo = self.___ex.teamLogo
    self.nameTxt = self.___ex.name
    self.formationButton = self.___ex.formationButton
    self.videoButton = self.___ex.videoButton
end

function SpecialEventsRecordItemView:InitView(model)
    self.nameTxt.text = model.name
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, model.logo)
end

return SpecialEventsRecordItemView
