local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local HomeCourtTechnologyView = class(unity.base)

function HomeCourtTechnologyView:ctor()
    self.btnClose = self.___ex.btnClose
    self.desc = self.___ex.desc
    self.grassInfo = self.___ex.grassInfo
    self.weatherInfo = self.___ex.weatherInfo
end

function HomeCourtTechnologyView:InitView(settingType, courtBuildModel, isMyHomeCourt, isNeutral)
    self.grassInfo:InitView(settingType, courtBuildModel, isMyHomeCourt)
    self.weatherInfo:InitView(settingType, courtBuildModel)
    local descText
    if isNeutral then 
        descText = lang.trans("owner_neutral_court")
    else
        descText = isMyHomeCourt and lang.trans("owner_home_court") or lang.trans("owner_visit_court") 
    end
    
    self.desc.text = descText
end

function HomeCourtTechnologyView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function HomeCourtTechnologyView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return HomeCourtTechnologyView
