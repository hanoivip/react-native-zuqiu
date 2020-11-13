local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildBaseView = require("ui.scene.court.CourtBuildBaseView")
local CourtStadiumBuildView = class(CourtBuildBaseView)

function CourtStadiumBuildView:ctor()
    CourtStadiumBuildView.super.ctor(self)
    -- button
    self.btnAudience = self.___ex.btnAudience
    self.btnLight = self.___ex.btnLight
    self.btnScore = self.___ex.btnScore
    self.btnStore = self.___ex.btnStore

    -- level
    self.audienceLevel = self.___ex.audienceLevel
    self.lightLevel = self.___ex.lightLevel
    self.scoreLevel = self.___ex.scoreLevel
    self.storeLevel = self.___ex.storeLevel

    -- building
    self.audienceBuilding = self.___ex.audienceBuilding
    self.lightBuilding = self.___ex.lightBuilding
    self.scoreBuilding = self.___ex.scoreBuilding
    self.storeBuilding = self.___ex.storeBuilding
end

function CourtStadiumBuildView:start()
    CourtStadiumBuildView.super.start(self)
    self.btnAudience:regOnButtonClick(function()
        self:OnBtnAudience(self.courtBuildModel)
    end)
    self.btnLight:regOnButtonClick(function()
        self:OnBtnLighting(self.courtBuildModel)
    end)
    self.btnScore:regOnButtonClick(function()
        self:OnBtnScore(self.courtBuildModel)
    end)
    self.btnStore:regOnButtonClick(function()
        self:OnBtnStore(self.courtBuildModel)
    end)
end

function CourtStadiumBuildView:onDestroy()
    CourtStadiumBuildView.super.onDestroy(self)
end

function CourtStadiumBuildView:OnBtnAudience(courtBuildModel)
    if self.clickAudience then 
        self.clickAudience(courtBuildModel)
    end
end

function CourtStadiumBuildView:OnBtnLighting(courtBuildModel)
    if self.clickLighting then 
        self.clickLighting(courtBuildModel)
    end
end

function CourtStadiumBuildView:OnBtnScore(courtBuildModel)
    if self.clickScore then 
        self.clickScore(courtBuildModel)
    end
end

function CourtStadiumBuildView:OnBtnStore(courtBuildModel)
    if self.clickStore then 
        self.clickStore(courtBuildModel)
    end
end

function CourtStadiumBuildView:InitView()
    self.courtBuildModel = CourtBuildModel.new()
    self:InitInfo(CourtBuildType.StadiumBuild, self.courtBuildModel)

    self.audienceLevel.text = "Lv." .. self.courtBuildModel:GetBuildLevel(CourtBuildType.AudienceBuild)
    self.lightLevel.text = "Lv." .. self.courtBuildModel:GetBuildLevel(CourtBuildType.LightingBuild)
    self.scoreLevel.text = "Lv." .. self.courtBuildModel:GetBuildLevel(CourtBuildType.ScoreBoardBuild)
    self.storeLevel.text = "Lv." .. self.courtBuildModel:GetBuildLevel(CourtBuildType.StoreBuild)

    local currentUpgradingType = self.courtBuildModel:HasBuildUpgrading() and self.courtBuildModel:GetBuildUpgradingType() or ""
    GameObjectHelper.FastSetActive(self.audienceBuilding, currentUpgradingType == CourtBuildType.AudienceBuild)
    GameObjectHelper.FastSetActive(self.lightBuilding, currentUpgradingType == CourtBuildType.LightingBuild)
    GameObjectHelper.FastSetActive(self.scoreBuilding, currentUpgradingType == CourtBuildType.ScoreBoardBuild)
    GameObjectHelper.FastSetActive(self.storeBuilding, currentUpgradingType == CourtBuildType.StoreBuild)
end

return CourtStadiumBuildView