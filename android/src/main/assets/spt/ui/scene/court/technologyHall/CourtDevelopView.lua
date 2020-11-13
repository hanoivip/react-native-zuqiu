local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtDevelopView = class(unity.base)

function CourtDevelopView:ctor()
    self.scroll = self.___ex.scroll
    self.scroll.clickGrass = function(settingType) self:OnClickGrass(settingType) end
    self.scroll.clickWeather = function(settingType) self:OnClickWeather(settingType) end
end

function CourtDevelopView:InitView(courtBuildModel, technologySettingConfig)
    self.scroll:InitView(technologySettingConfig, courtBuildModel)
end

function CourtDevelopView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function CourtDevelopView:OnClickGrass(settingType)
    if self.clickGrass then 
        self.clickGrass(settingType)
    end
end

function CourtDevelopView:OnClickWeather(settingType)
    if self.clickWeather then 
        self.clickWeather(settingType)
    end
end

return CourtDevelopView