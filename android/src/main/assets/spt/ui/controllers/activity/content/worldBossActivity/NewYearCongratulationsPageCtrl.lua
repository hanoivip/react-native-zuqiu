local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local NewYearCongratulationsPageCtrl = class()

function NewYearCongratulationsPageCtrl:ctor(data, matchType)
    self:Process(data, matchType)
end

function NewYearCongratulationsPageCtrl:Process(data, matchType)
    if not (data and next(data)) then
        return
    end
    if GuideManager.HasGuideOnGoing() then
        return
    end
    if matchType == NewYearOutPutPosType.PEAK or matchType == NewYearOutPutPosType.LADDER or matchType == NewYearOutPutPosType.LEAGUE
        or matchType == NewYearOutPutPosType.SPECIFIC or matchType == NewYearOutPutPosType.QUEST or matchType == NewYearOutPutPosType.TRANSPORT then
        self:Congratulations(data.exchangeReward)
    elseif matchType == NewYearOutPutPosType.CARD then
        self:Congratulations({exchangeItem = data})
    end
end

function NewYearCongratulationsPageCtrl:Congratulations(contents)
    if contents and next(contents) then
        CongratulationsPageCtrl.new(contents)
    end
end

return NewYearCongratulationsPageCtrl
