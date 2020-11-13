local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GrassDevelopView = class(unity.base)

function GrassDevelopView:ctor()
    self.mixed = self.___ex.mixed
    self.natureShort = self.___ex.natureShort
    self.natureLong = self.___ex.natureLong
    self.artificialShort = self.___ex.artificialShort
    self.artificialLong = self.___ex.artificialLong
end

function GrassDevelopView:start()
    self.mixed.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.natureShort.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.natureLong.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.artificialShort.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end
    self.artificialLong.clickBuild = function(courtBuildType) self:ClickBuild(courtBuildType) end

    EventSystem.AddEvent("RefreshBuild", self, self.RefreshBuild)
end

function GrassDevelopView:onDestroy()
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
end

function GrassDevelopView:RefreshBuild(buildType, courtBuildModel)
    if buildType == CourtBuildType.MixedBuild  
        or buildType == CourtBuildType.NatureShortBuild 
        or buildType == CourtBuildType.NatureLongBuild
        or buildType == CourtBuildType.ArtificialShortBuild
        or buildType == CourtBuildType.ArtificialLongBuild then 
        if self.refreshBuild then 
            self.refreshBuild()
        end
    end
end

function GrassDevelopView:ClickBuild(courtBuildType)
    if self.clickBuild then 
        self.clickBuild(courtBuildType)
    end
end

function GrassDevelopView:InitView(courtBuildModel)
    self.mixed:InitView(courtBuildModel, CourtBuildType.MixedBuild)
    self.natureShort:InitView(courtBuildModel, CourtBuildType.NatureShortBuild)
    self.natureLong:InitView(courtBuildModel, CourtBuildType.NatureLongBuild)
    self.artificialShort:InitView(courtBuildModel, CourtBuildType.ArtificialShortBuild)
    self.artificialLong:InitView(courtBuildModel, CourtBuildType.ArtificialLongBuild)
end

function GrassDevelopView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

return GrassDevelopView