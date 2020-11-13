local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildIncludeType = {}

local BuildChild = 
{
    [CourtBuildType.StadiumBuild] = 
    {
        CourtBuildType.AudienceBuild,
        CourtBuildType.LightingBuild,
        CourtBuildType.ScoreBoardBuild,
        CourtBuildType.StoreBuild,
    },
    [CourtBuildType.TechnologyHallBuild] = 
    {
        CourtBuildType.MixedBuild,
        CourtBuildType.NatureShortBuild,
        CourtBuildType.NatureLongBuild,
        CourtBuildType.ArtificialShortBuild,
        CourtBuildType.ArtificialLongBuild,
        CourtBuildType.RainBuild,
        CourtBuildType.SnowBuild,
        CourtBuildType.WindBuild,
        CourtBuildType.FogBuild,
        CourtBuildType.SandBuild,
        CourtBuildType.HeatBuild,
    }
}

function CourtBuildIncludeType.GetBuildChild(courtBuildType)
    return BuildChild[courtBuildType]
end

return CourtBuildIncludeType
