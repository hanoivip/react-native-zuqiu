local ArenaOutTitle = class(unity.base)

function ArenaOutTitle:ctor()
    self.round = self.___ex.round
    self.time = self.___ex.time
end

function ArenaOutTitle:InitView(matchScheduleType, arenaScheduleTeamModel)
    self.round.text = lang.trans(matchScheduleType)
    local firstMatchTime = arenaScheduleTeamModel:GetMatchTime(matchScheduleType, 1)
    local secondMatchTime = arenaScheduleTeamModel:GetMatchTime(matchScheduleType, 2)
    local monthAndDayTime = os.date(lang.transstr("calendar_time5"), firstMatchTime) 
    local hourAndMinute = os.date("%H:%M", firstMatchTime) 
    local time = monthAndDayTime .. "   " .. hourAndMinute
    if secondMatchTime and secondMatchTime ~= "" then 
        local nextHourAndMinute = os.date("%H:%M", secondMatchTime) 
        time = time .. "   " .. nextHourAndMinute
    end
    self.time.text = time
end

return ArenaOutTitle
