local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SettingDisplayView = class(unity.base)

function SettingDisplayView:ctor()
    self.title = self.___ex.title
    self.btnClose = self.___ex.btnClose
    self.scroll = self.___ex.scroll
    self.scroll.clickUse = function(settingType, typeName) self:OnClickUse(settingType, typeName) end
end

function SettingDisplayView:InitView(courtBuildModel, courtTechnologyDetailModel, settingType, technologyDevelopType, types)
    self.scroll:InitView(courtBuildModel, courtTechnologyDetailModel, settingType, technologyDevelopType, types)
    local titleStr = courtTechnologyDetailModel:GetTechnologyTitle()
    self.title.text = lang.trans(titleStr)
end

function SettingDisplayView:OnClickUse(settingType, typeName)
    if self.clickUse then 
        self.clickUse(settingType, typeName)
    end
end

function SettingDisplayView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function SettingDisplayView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function SettingDisplayView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

return SettingDisplayView