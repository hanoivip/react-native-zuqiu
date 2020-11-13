local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildTechnologyHallView = class(unity.base)

function CourtBuildTechnologyHallView:ctor()
    self.building = self.___ex.building
    self.time = self.___ex.time
    self.timeBar = self.___ex.timeBar
    self.levelSign = self.___ex.levelSign
end

function CourtBuildTechnologyHallView:start()
    EventSystem.AddEvent("RefreshBuild", self, self.RefreshBuild)
end

function CourtBuildTechnologyHallView:onDestroy()
    EventSystem.SendEvent("CourtTimeDie", self)
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
end

function CourtBuildTechnologyHallView:RefreshBuild(buildType, courtBuildModel)
    if buildType == self.courtBuildType  then 
        self:InitView(courtBuildModel, buildType)
    elseif courtBuildModel:IsBuildChild(self.courtBuildType, buildType) then 
        self:IsChildCooling(courtBuildModel, buildType)
    end
end

function CourtBuildTechnologyHallView:IsChildCooling(courtBuildModel, childBuild)
    local childTime = courtBuildModel:GetBuildTime(childBuild)
    self:ShowCooling(childTime)
end

function CourtBuildTechnologyHallView:InitView(courtBuildModel, courtBuildType)
    self.courtBuildModel = courtBuildModel
    self.courtBuildType = courtBuildType
    local isOpen = false
    local isChildCooling, childBuildTime = courtBuildModel:HasBuildChildIsBuilding(courtBuildType)
    if not isChildCooling then
        isOpen = not courtBuildModel:HasBuildUpgrading() and courtBuildModel:HasBuildChildCanUp(courtBuildType)
    end
    self:ShowCooling(childBuildTime)
    GameObjectHelper.FastSetActive(self.levelSign, isOpen)
end

function CourtBuildTechnologyHallView:ShowCooling(childTime)
    local isChildCooling = tobool(childTime > 0)
    GameObjectHelper.FastSetActive(self.building, isChildCooling)
    if isChildCooling then 
        EventSystem.SendEvent("CourtTimer", self, childTime, self.courtBuildType)
    end
end

function CourtBuildTechnologyHallView:ShowProgress(courtBuildType, time)
    self.time.text = string.formatTimeClock(time, 3600)
    local level = self.courtBuildModel:GetBuildLevel(courtBuildType)
    local totalTime = self.courtBuildModel:GetBuildUpgradeTime(courtBuildType, level + 1) * 60
    local progress = time / totalTime
    local percent = 1 - progress
    self.timeBar.value = percent
end

function CourtBuildTechnologyHallView:UpdateTime(time)
    self:ShowProgress(self.courtBuildType, time)
end

function CourtBuildTechnologyHallView:UpdateChildTime(time, childBuildType)
    self:ShowProgress(childBuildType, time)
end

return CourtBuildTechnologyHallView
