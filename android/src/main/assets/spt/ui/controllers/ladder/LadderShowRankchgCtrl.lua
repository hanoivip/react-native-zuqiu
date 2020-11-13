local DialogManager = require("ui.control.manager.DialogManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local MatchConstants = require("ui.scene.match.MatchConstants")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")

local LadderShowRankchgCtrl = class()

function LadderShowRankchgCtrl:ctor(matchResult)
    self.matchResult = matchResult
    self:Init()
end

function LadderShowRankchgCtrl:Init()
    if GuideManager.GuideIsOnGoing("main") then
        return
    end

    local matchResultData = cache.getMatchResult()
    
    if matchResultData and matchResultData.settlement and matchResultData.matchType == MatchConstants.MatchType.LADDER then
        NewYearCongratulationsPageCtrl.new(matchResultData.settlement, NewYearOutPutPosType.LADDER)
    end
    --如果比赛没有胜利or比赛结果为空or不是天梯比赛
    if self.matchResult ~= 1 or matchResultData == nil or matchResultData.matchType ~= MatchConstants.MatchType.LADDER then
        return
    end

    if not matchResultData.settlement or matchResultData.settlement.rankchg == nil or matchResultData.settlement.rankchg then
        return
    end 

    clr.coroutine(function()
        local respone = req.ladderInfo()
        if api.success(respone) then
            local data = respone.val
            if tonumber(data.rank) ~= 1 then
                local title = lang.trans("tips")
                local content = lang.trans("ladder_rankNoChange")
                DialogManager.ShowAlertPop(title, content, function() return end)  
            end
        end
    end)
end

return LadderShowRankchgCtrl