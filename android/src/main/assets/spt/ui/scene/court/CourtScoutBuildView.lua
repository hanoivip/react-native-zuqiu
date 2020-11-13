local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildBaseView = require("ui.scene.court.CourtBuildBaseView")
local CourtScoutBuildView = class(CourtBuildBaseView)

function CourtScoutBuildView:ctor()
    CourtScoutBuildView.super.ctor(self)
    self.btnPlayer = self.___ex.btnPlayer
end

function CourtScoutBuildView:start()
    CourtScoutBuildView.super.start(self)
    self.btnPlayer:regOnButtonClick(function()
        self:OnBtnPlayer()
    end)
end

function CourtScoutBuildView:OnBtnPlayer()
    if self.clickPlayer then 
        self.clickPlayer(self.courtBuildModel)
    end
end

function CourtScoutBuildView:onDestroy()
    CourtScoutBuildView.super.onDestroy(self)
    -- *新手引导结束后得还原移动事件
    EventSystem.SendEvent("CourtMobileTouchEventSwitch", true)
end

function CourtScoutBuildView:InitView()
    self.courtBuildModel = CourtBuildModel.new()
    self:InitInfo(CourtBuildType.ScoutBuild, self.courtBuildModel)
end

return CourtScoutBuildView