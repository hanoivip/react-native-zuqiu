local InitializerFilter = {}

-- Used to filter external Initializer input, to avoid internal parameter being overwritten

function InitializerFilter.getInitializerSkills(athlete)
    local ret = {}
    -- Treat feature as skill in Initializer
    if athlete.feature then
        for id, level in pairs(athlete.feature) do
            ret[id] = level
        end
    end
    if athlete.skills then
        for id, level in pairs(athlete.skills) do
            ret[id] = level
        end
    end
    return ret
end

function InitializerFilter.getInitializerAthletes(athletes)
    local ret = {}
    for i, athlete in ipairs(athletes) do
        local obj = {}
        obj.id = athlete.id
        obj.role = athlete.role
        obj.abilities = athlete.abilities
        obj.adeptRole = athlete.adeptRole
        obj.foot = athlete.foot

        obj.skills = InitializerFilter.getInitializerSkills(athlete)

        table.insert(ret, obj)
    end
    return ret
end

function InitializerFilter.getInitializerTeam(team)
    local ret = {}
    ret.name = team.name
    ret.role = team.role
    ret.field = team.field
    ret.formation = team.formation
    ret.captain = team.captain
    ret.cornerKicker = team.corner or team.cornerKicker
    ret.penaltyKicker = team.spotKick or team.penaltyKicker
    ret.freeKickShooter = team.freeKickShoot or team.freeKickShooter
    ret.freeKickPasser = team.freeKickPass or team.freeKickPasser
    ret.tactics = team.tactics
    ret.athletes = InitializerFilter.getInitializerAthletes(team.athletes)
    ret.coachBonus = team.coachBonus
    ret.coachPic = team.coachPic and tostring(team.coachPic)
    ret.coachSkill = team.coachSkill
    ret.coachId = team.coachId and tostring(team.coachId)
    ret.trainerBonus = team.trainerBonus
    ret.power = team.power

    assert(ret.captain)
    assert(ret.cornerKicker)
    assert(ret.penaltyKicker)
    assert(ret.freeKickShooter)
    assert(ret.freeKickPasser)

    return ret
end

function InitializerFilter.getOperations(operations)
    local ret = {}
    if operations then
        for key, operation in pairs(operations) do
            ret[tonumber(key)] = operation
        end
    end
    return ret
end

-- Hard code rand seed of the second match for newbies
function InitializerFilter.modifyRandSeed(data)
    if data.baseInfo.matchType == "quest" and data.opponent.npcID == "Q102" then
        data.baseInfo.randSeed = 9888018
    end
end

function InitializerFilter.getInitializer(data)
    InitializerFilter.modifyRandSeed(data)

    local ret = {}
    ret.baseInfo = data.baseInfo
    ret.player = InitializerFilter.getInitializerTeam(data.player)
    ret.opponent = InitializerFilter.getInitializerTeam(data.opponent)
    ret.ops = InitializerFilter.getOperations(data.ops)
    return ret
end

return InitializerFilter