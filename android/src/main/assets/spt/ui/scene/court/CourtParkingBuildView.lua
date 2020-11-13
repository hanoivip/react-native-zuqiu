local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildBaseView = require("ui.scene.court.CourtBuildBaseView")
local CourtParkingBuildView = class(CourtBuildBaseView)

function CourtParkingBuildView:ctor()
    CourtParkingBuildView.super.ctor(self)
    self.currentEffect = self.___ex.currentEffect
    self.nextEffect = self.___ex.nextEffect
end

function CourtParkingBuildView:start()
    CourtParkingBuildView.super.start(self)
end


function CourtParkingBuildView:onDestroy()
    CourtParkingBuildView.super.onDestroy(self)
end

function CourtParkingBuildView:InitView()
    self.courtBuildModel = CourtBuildModel.new()
    self:InitInfo(CourtBuildType.ParkingBuild, self.courtBuildModel)
    local level = self.courtBuildModel:GetBuildLevel(CourtBuildType.ParkingBuild)
    local nextLvl = level + 1
    local isMax = self.courtBuildModel:IsBuildMaxLvl(CourtBuildType.ParkingBuild, nextLvl)
    if isMax then
        self.currentEffect.text = lang.trans("parking_effect", self.courtBuildModel:GetBuildIndex(CourtBuildType.ParkingBuild, level))
        self.nextEffect.text = lang.trans("maxLevel")
    else
        self.currentEffect.text = lang.trans("parking_effect", self.courtBuildModel:GetBuildIndex(CourtBuildType.ParkingBuild, level))
        self.nextEffect.text = lang.trans("parking_effect", self.courtBuildModel:GetBuildIndex(CourtBuildType.ParkingBuild, nextLvl))
    end
end

return CourtParkingBuildView