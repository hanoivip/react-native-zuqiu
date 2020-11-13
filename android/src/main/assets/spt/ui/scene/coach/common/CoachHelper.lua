local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachHelper = {}

CoachHelper.CoachNameColor = {
    ["1"] = {
            { percent = 0, color = Color(0.816, 0.816, 0.765, 1) } ,
            { percent = 1, color = Color(0.502, 0.502, 0.502, 1) } 
          },
    ["2"] = { 
            { percent = 0, color = Color(0.961, 0.732, 0.530, 1) } ,
            { percent = 1, color = Color(0.588, 0.451, 0.325, 1) } 
          },
    ["3"] = { 
            { percent = 0, color = Color(0.956, 0.988, 0.988, 1) } ,
            { percent = 1, color = Color(0.678, 0.678, 0.678, 1) } 
          },
    ["4"] = {
            { percent = 0, color = Color(1, 1, 0.702, 1) } ,
            { percent = 1, color = Color(1, 0.914, 0.537, 1) } 
          },
    ["5"] = { 
            { percent = 0, color = Color(1, 1, 1, 1) } ,
            { percent = 1, color = Color(0.902, 0.878, 0.82, 1) } 
          },
    ["6"] = {
            { percent = 0, color = Color(1, 1, 0.459, 1) } ,
            { percent = 1, color = Color(0.867, 0.655, 0.282, 1) } 
          },
    ["7"] = {
            { percent = 0, color = Color(0.973, 0.859, 0.557, 1) } ,
            { percent = 1, color = Color(0.843, 0.234, 0.153, 1) } 
          },
    ["8"] = {
            { percent = 0, color = Color(1, 1, 0.702, 1) } ,
            { percent = 1, color = Color(0.167, 0.369, 0.624, 1) } 
          }
}

function CoachHelper.GetCredentialLevel(coachLvl)
    coachLvl = tostring(coachLvl)
    return CoachBaseLevel[coachLvl].coachCredentialLevel
end

function CoachHelper.GetStarLevel(coachLvl)
    coachLvl = tostring(coachLvl)
    return CoachBaseLevel[coachLvl].coachLevel
end

-- 说明
CoachHelper.Explain = {
    CaochMainPage = {
        id = 4,
        descID = "CaochMainPage"
    },
    CoachMission = {
        id = 5,
        descID = "CoachMission"
    },
    CoachBaseInfo = {
        id = 6,
        descID = "CoachBaseInfo"
    },
    CoachTalentSkill = {
        id = 7,
        descID = "CoachTalentSkill"
    },
    CoachGuide = {
        id = 9,
        descID = "CoachGuide"
    }
}

return CoachHelper
