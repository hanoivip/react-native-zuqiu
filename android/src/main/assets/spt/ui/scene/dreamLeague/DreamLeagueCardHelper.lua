local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local DreamLeagueCardHelper = class(unity.base)

local pos1 = lang.trans("training_titleForward")
local pos2 = lang.trans("training_titleMidfielder")
local pos3 = lang.trans("training_titleDefender")
local pos4 = lang.trans("training_titleGoalkeeper")
DreamLeagueCardHelper.CardPositionType = {pos1, pos2, pos3, pos4}

local colorB = Color(53/255, 53/255, 53/255, 1)
local colorA = Color(230/255, 230/255, 230/255, 1)
local colorS = Color(230/255, 230/255, 230/255, 1)
DreamLeagueCardHelper.CardColorSign = {colorB, colorA, colorS}

DreamLeagueCardHelper.CardQualitySign = {"B", "A", "S"}

DreamLeagueCardHelper.CardSelectMode = {}
DreamLeagueCardHelper.CardSelectMode.BASE = 1
DreamLeagueCardHelper.CardSelectMode.REWARD = 2
DreamLeagueCardHelper.CardSelectMode.SELECT = 3

function DreamLeagueCardHelper:GetQualityByQualityIndex(cardQualityIndex)
    return self.CardQualitySign[cardQualityIndex] or "None"
end

function DreamLeagueCardHelper:GetQualityByDreamCardID(dreamCardId)
    local length = string.len(dreamCardId)
    local cardQualityIndex = string.sub(length, 1)
    cardQualityIndex = tostring(cardQualityIndex)
    return self.CardQualitySign[cardQualityIndex] or "None"
end

return DreamLeagueCardHelper
