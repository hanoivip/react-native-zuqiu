local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local WorldBossActivityMainView = class(ActivityParentView)

function WorldBossActivityMainView:ctor()
    self.residualTime = self.___ex.residualTime
    self.infoText = self.___ex.infoText
    self.residualCount = self.___ex.residualCount
    self.addChallengeCount = self.___ex.addChallengeCount
    self.joinBtns = self.___ex.joinBtns
    self.rankText = self.___ex.rankText
    self.viewSingleBtn = self.___ex.viewSingleBtn
    self.viewWorldBtn = self.___ex.viewWorldBtn
    self.singleNames = self.___ex.singleNames
    self.singleScores = self.___ex.singleScores
    self.worldNames = self.___ex.worldNames
    self.worldScores = self.___ex.worldScores
    self.bossName = self.___ex.bossName
    self.redPackSpt = self.___ex.redPackSpt
    self.rankWindowSpt = self.___ex.rankWindowSpt
    self.mName = self.___ex.mName
end

function WorldBossActivityMainView:start()
    self:RegOnBtn()
end

function WorldBossActivityMainView:RegOnBtn()
    for k,v in pairs(self.joinBtns) do
        v:regOnButtonClick(function()
            if self.onJoinMatchClick then
                self.onJoinMatchClick(k)
            end
        end)
    end
    self.addChallengeCount:regOnButtonClick(function()
        if self.onAddChllengeCountClick then
            self.onAddChllengeCountClick(k)
        end
    end)
end

function WorldBossActivityMainView:InitView(worldBossActivityModel)
    self.worldBossActivityModel = worldBossActivityModel
    self.infoText.text = worldBossActivityModel:GetActivityDesc()
    self.mName["1"].text = worldBossActivityModel:GetName()
    self.mName["2"].text = worldBossActivityModel:GetName()
    self.residualCount.text = lang.trans("challenge_leftCount", worldBossActivityModel:GetFreeTime())
    self.residualTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.worldBossActivityModel:GetBeginTime()), 
                            string.convertSecondToMonth(self.worldBossActivityModel:GetEndTime()))
    local bossNameVlaues = worldBossActivityModel:GetTeamNames()
    for k,v in pairs(self.bossName) do
        v.text = bossNameVlaues[tonumber(k)]
    end
    self.redPackSpt.onGrab = function(reqCallBack, reqCallBackFail) self.onGrab(reqCallBack, reqCallBackFail) end
    self.redPackSpt:InitView(worldBossActivityModel:GetRedPackData())
    self.rankWindowSpt:InitView(worldBossActivityModel:GetRankData())
end

function WorldBossActivityMainView:onDestroy()
end

return WorldBossActivityMainView