local TimeFormater = {}

function TimeFormater.formatLoginTime(loginSeconds)
    local secondsPerDay = 24 * 60 * 60
    local secondsPerHour = 60 * 60
    local secondsPerMinute = 60
    local day1, day2 = math.modf(loginSeconds / secondsPerDay)
    if day1 > 0 then
        return lang.trans("friends_loginTime_day_2", tostring(day1))
    else
        local hour1, hour2 = math.modf(loginSeconds / secondsPerHour)
        if hour1 > 0 then
            return lang.trans("friends_loginTime_hour_2", tostring(hour1))
        else
            local minute1, minute2 = math.modf(loginSeconds / secondsPerMinute)
            if minute1 > 0 then
                return lang.trans("friends_loginTime_minute_2", tostring(minute1))
            else
                local second = loginSeconds % secondsPerMinute
                return lang.trans("friends_loginTime_second_2", tostring(second))
            end
        end
    end
end

return TimeFormater