local GameObjectHelper = require("ui.common.GameObjectHelper")
local PersonScheduleBarView = class(unity.base)

function PersonScheduleBarView:ctor()
    self.round = self.___ex.round
    self.time = self.___ex.time
    self.team = self.___ex.team
    self.team.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
end

function PersonScheduleBarView:OnClickVideo(vid, version)
    if self.clickVideo then
        self.clickVideo(vid, version)
    end
end

function PersonScheduleBarView:InitView(personScheduleData, arenaScheduleTeamModel, playerId)
    local matchScheduleType = personScheduleData.gameStage
    local stageOrder = tonumber(personScheduleData.stageOrder) + 1
    if matchScheduleType == "final" then
        -- 决赛不需要场次
        self.round.text = lang.transstr(matchScheduleType)
    else
        self.round.text = lang.transstr(matchScheduleType) .. lang.transstr("round_num", stageOrder)
    end
    local time = arenaScheduleTeamModel:GetMatchTime(matchScheduleType, stageOrder) or 0
    local convertTime = os.date(lang.transstr("calendar_time4"), tonumber(time))
    self.time.text = tostring(convertTime)
    self.team:InitView(personScheduleData, arenaScheduleTeamModel, playerId)
end

return PersonScheduleBarView