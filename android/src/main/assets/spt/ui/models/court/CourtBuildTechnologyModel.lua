local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildTechnologyModel = class(CourtBuildModel, "CourtBuildTechnologyModel")

function CourtBuildTechnologyModel:ctor()
    CourtBuildTechnologyModel.super.ctor(self)
end

function CourtBuildTechnologyModel:InitWithProtocol(data)
    self.data = data
    self.set = self.data and self.data.matchSet or {}
end

local function BuildInitData(buildType, buildLvl)
    local data = {}
    data.type = buildType
    data.lvl = buildLvl
    return data
end

-- 中立场地设置默认数据
function CourtBuildTechnologyModel:UseDefaultData(settingType)
    self.set = {}
    self.set[settingType] = {}
    self.set[settingType][TechnologyDevelopType.GrassType] = BuildInitData(CourtBuildType.GrassBuild, 1)
    self.set[settingType][TechnologyDevelopType.WeatherType] = BuildInitData(CourtBuildType.SunShineBuild, 1)
end

return CourtBuildTechnologyModel
