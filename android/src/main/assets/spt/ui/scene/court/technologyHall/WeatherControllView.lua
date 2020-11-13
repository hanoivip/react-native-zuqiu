local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local WeatherControllView = class(unity.base)

function WeatherControllView:ctor()
    self.rain = self.___ex.rain
    self.snow = self.___ex.snow
    self.wind = self.___ex.wind
    self.fog = self.___ex.fog
    self.sand = self.___ex.sand
    self.heat = self.___ex.heat
end

function WeatherControllView:start()
    self.rain.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.snow.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.wind.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.fog.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.sand.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.heat.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end

    EventSystem.AddEvent("RefreshBuild", self, self.RefreshBuild)
end

function WeatherControllView:onDestroy()
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
end

function WeatherControllView:RefreshBuild(buildType, courtBuildModel)
    if buildType == CourtBuildType.RainBuild  
        or buildType == CourtBuildType.SnowBuild 
        or buildType == CourtBuildType.WindBuild
        or buildType == CourtBuildType.FogBuild
        or buildType == CourtBuildType.SandBuild
        or buildType == CourtBuildType.HeatBuild then  
        if self.refreshBuild then 
            self.refreshBuild()
        end
    end
end

function WeatherControllView:ClickBuild(courtBuildType)
    if self.clickBuild then 
        self.clickBuild(courtBuildType)
    end
end

function WeatherControllView:InitView(courtBuildModel)
    self.rain:InitView(courtBuildModel, CourtBuildType.RainBuild)
    self.snow:InitView(courtBuildModel, CourtBuildType.SnowBuild)
    self.wind:InitView(courtBuildModel, CourtBuildType.WindBuild)
    self.fog:InitView(courtBuildModel, CourtBuildType.FogBuild)
    self.sand:InitView(courtBuildModel, CourtBuildType.SandBuild)
    self.heat:InitView(courtBuildModel, CourtBuildType.HeatBuild)
end

function WeatherControllView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

return WeatherControllView