local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildHelper = require("ui.scene.court.CourtBuildHelper")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtMainBuildBaseView = class(unity.base)

function CourtMainBuildBaseView:ctor()
    self.level = self.___ex.level
    self.levelSign = self.___ex.levelSign
    self.building = self.___ex.building
    self.time = self.___ex.time
    self.timeBar = self.___ex.timeBar
    self.isFinish = false
end

function CourtMainBuildBaseView:start()
    EventSystem.AddEvent("RefreshBuild", self, self.RefreshBuild)
    EventSystem.AddEvent("CourtComplete", self, self.CourtComplete)
end

function CourtMainBuildBaseView:OnClick()
    if self.click then
        self.click(self.courtBuildType)
    end
end

function CourtMainBuildBaseView:onDestroy()
    EventSystem.SendEvent("CourtTimeDie", self)
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
    EventSystem.RemoveEvent("CourtComplete", self, self.CourtComplete)
end

function CourtMainBuildBaseView:RefreshBuild(buildType, courtBuildModel)
    if buildType == self.courtBuildType  then 
        self:InitView(courtBuildModel, self.court3DManager, buildType)
    elseif courtBuildModel:IsBuildChild(self.courtBuildType, buildType) then 
        self:IsChildCooling(courtBuildModel, buildType)
    end
end

function CourtMainBuildBaseView:CourtComplete(buildType)
    if buildType == self.courtBuildType  then 
       self.court3DManager:BuildUpgradComplete(buildType)
    end
end

function CourtMainBuildBaseView:OnEnterScene()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function CourtMainBuildBaseView:OnExitScene()
end

function CourtMainBuildBaseView:IsChildCooling(courtBuildModel, childBuild)
    local time = courtBuildModel:GetBuildTime(self.courtBuildType)
    local childTime = courtBuildModel:GetBuildTime(childBuild)
    self:ShowCooling(time, childTime)
end

function CourtMainBuildBaseView:ShowCooling(time, childTime)
    local isCooling = tobool(time > 0)
    local isChildCooling = tobool(childTime > 0)
    local isShow = isCooling or isChildCooling
    GameObjectHelper.FastSetActive(self.building, isShow)
    if isShow then 
        local coolTime = isCooling and time or childTime
        EventSystem.SendEvent("CourtTimer", self, coolTime, self.courtBuildType)
    end
end

function CourtMainBuildBaseView:InitView(courtBuildModel, court3DManager, courtBuildType)
    GameObjectHelper.FastSetActive(self.gameObject, true)
    self.court3DManager = court3DManager
    self.courtBuildModel = courtBuildModel
    self.courtBuildType = courtBuildType
    local lvl = courtBuildModel:GetBuildLevel(courtBuildType)
    self.level.text = tostring(lvl)
    court3DManager:Show3DResByType(courtBuildType, lvl)

    local isOpenLevel = false
    local time = courtBuildModel:GetBuildTime(courtBuildType)
    local isCooling = false
    if time > 0 then
        isCooling = true
        self.court3DManager:BuildUpgrading(courtBuildType, lvl)
    else
        local nextLvl = lvl + 1
        isOpenLevel = courtBuildModel:IsBuildOpen(courtBuildType, nextLvl) 
    end
    local isChildCooling, childBuildTime = courtBuildModel:HasBuildChildIsBuilding(courtBuildType)
    self:ShowCooling(time, childBuildTime)

    GameObjectHelper.FastSetActive(self.levelSign, isOpenLevel)
end

function CourtMainBuildBaseView:ShowProgress(courtBuildType, time)
    self.time.text = string.formatTimeClock(time, 3600)
    local level = self.courtBuildModel:GetBuildLevel(courtBuildType)
    local totalTime = self.courtBuildModel:GetBuildUpgradeTime(courtBuildType, level + 1) * 60
    local progress = time / totalTime
    local percent = 1 - progress
    self.timeBar.value = percent
end

function CourtMainBuildBaseView:UpdateTime(time)
    self:ShowProgress(self.courtBuildType, time)
end

function CourtMainBuildBaseView:UpdateChildTime(time, childBuildType)
    self:ShowProgress(childBuildType, time)
end

return CourtMainBuildBaseView