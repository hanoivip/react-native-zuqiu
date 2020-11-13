local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildHelper = {}

local StadiumPos = 
{
    ['0'] = {x = 0, y = 0 },
    ['1'] = {x = 14.6, y = 3.1 },
    ['2'] = {x = 13, y = 0 },
    ['3'] = {x = 21, y = 11 },
    ['4'] = {x = 17, y = 9 },
    ['5'] = {x = 17, y = 9 },
    ['6'] = {x = 17, y = 9 },
    ['7'] = {x = 17, y = 9 },
    ['8'] = {x = 17, y = 9 },
    ['9'] = {x = 17, y = 9 },
    ['10'] = {x = 8.87, y = 9 },
}

local ScoutingPos = 
{
    ['0'] = {x = 0, y = 0 },
    ['1'] = {x = 11, y = 14 },
    ['2'] = {x = 0, y = 0 },
    ['3'] = {x = 0, y = 0 },
    ['4'] = {x = -6.87, y = 44.15 },
    ['5'] = {x = -6.87, y = 44.15 },
    ['6'] = {x = -6.87, y = 44.15 },
    ['7'] = {x = 12, y = 41 },
    ['8'] = {x = 12, y = 41 },
    ['9'] = {x = 12, y = 41 },
    ['10'] = {x = 12, y = 41 },
}

local ParkingPos = 
{
    ['0'] = {x = 0, y = 0 },
    ['1'] = {x = 118, y = -30 },
    ['2'] = {x = 78, y = 100 },
    ['3'] = {x = 78, y = 100 },
    ['4'] = {x = 78, y = 120 },
    ['5'] = {x = 78, y = 120 },
    ['6'] = {x = 78, y = 120 },
    ['7'] = {x = 78, y = 120 },
    ['8'] = {x = 78, y = 120 },
    ['9'] = {x = 78, y = 120 },
    ['10'] = {x = 78, y = 120 },
}

function CourtBuildHelper.GetPos(pos, lvl)
    return pos[tostring(lvl)] or { x = 0, y = 0 }
end

function CourtBuildHelper.GetBuildPos(courtBuildType, lvl)
    if courtBuildType == CourtBuildType.StadiumBuild then 
        return CourtBuildHelper.GetPos(StadiumPos, lvl)
    elseif courtBuildType == CourtBuildType.ScoutBuild then 
        return CourtBuildHelper.GetPos(ScoutingPos, lvl)
    elseif courtBuildType == CourtBuildType.ParkingBuild then 
        return CourtBuildHelper.GetPos(ParkingPos, lvl)
    end
end

return CourtBuildHelper
