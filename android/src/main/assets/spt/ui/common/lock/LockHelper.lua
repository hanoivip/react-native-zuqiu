local SpecificMatchBase = require("data.SpecificMatchBase")
local LockType = require("ui.common.lock.LockType")
local lang = lang
local floor = math.floor
local tonumber = tonumber
local fmod = math.fmod
local modf = math.modf
local ldexp = math.ldexp
local LockHelper = class()

local LockGroupMax = 50
local NoLock = 0

local function GetSpecialEventsIdByLockType(lockType)
    lockType = tonumber(lockType)
    return LockType.SpecialEvents_Lock[lockType] or LockType.SpecialEvents_RepLock[lockType]
end

local function GetSpecialEventsDescByLockType(lockType)
    local eventsId = GetSpecialEventsIdByLockType(lockType)
    local des = SpecificMatchBase[tostring(tonumber(eventsId) * 100 + 1)].title
    if LockType.SpecialEvents_Lock[lockType] then
        des = des .. lang.transstr("in_match")
    else
        des = des .. lang.transstr("bench_desc")
    end
    return des
end

-- 增加getKey数据用来延迟获取LockType中的值，因为LockType值动态改变（根据默认阵容的id动态改变）
local LockDetail = {
    -- 当前阵容
    { desc = lang.trans("court_lock"), stringDesc = lang.transstr("court_lock"), getKey = function() return LockType.CourtLock end },
    { desc = lang.trans("bench_lock"), stringDesc = lang.transstr("bench_lock"), getKey = function() return LockType.BenchLock end },
    -- 玩家自锁
    { desc = lang.trans("player_lock"), stringDesc = lang.transstr("player_lock"), getKey = function() return LockType.PlayerLock end },
    -- 竞技场阵容
    { desc = lang.trans("arena_lock"), stringDesc = lang.transstr("arena_lock"), getKey = function() return LockType.ArenaLock end },
    { desc = lang.trans("arena_bench_lock"), stringDesc = lang.transstr("arena_bench_lock"), getKey = function() return LockType.ArenaBench_Lock end },
    -- 白银/黄金/黑金/白金/红金/周年庆/巅峰竞技场
    { desc = lang.trans("silver_lock"), stringDesc = lang.transstr("silver_lock"), getKey = function() return LockType.Arena_Silver_Lock end },
    { desc = lang.trans("silver_rep_lock"), stringDesc = lang.transstr("silver_rep_lock"), getKey = function() return LockType.Arena_Silver_Rep_Lock end },
    { desc = lang.trans("gold_lock"), stringDesc = lang.transstr("gold_lock"), getKey = function() return LockType.Arena_Gold_Lock end },
    { desc = lang.trans("gold_rep_lock"), stringDesc = lang.transstr("gold_rep_lock"), getKey = function() return LockType.Arena_Gold_Rep_Lock end },
    { desc = lang.trans("black_lock"), stringDesc = lang.transstr("black_lock"), getKey = function() return LockType.Arena_Black_Lock end },
    { desc = lang.trans("black_rep_lock"), stringDesc = lang.transstr("black_rep_lock"), getKey = function() return LockType.Arena_Black_Rep_Lock end },
    { desc = lang.trans("platinum_lock"), stringDesc = lang.transstr("platinum_lock"), getKey = function() return LockType.Arena_Platinum_Lock end },
    { desc = lang.trans("platinum_rep_lock"), stringDesc = lang.transstr("platinum_rep_lock"), getKey = function() return LockType.Arena_Platinum_Rep_Lock end },
    { desc = lang.trans("arena_redGold_lock"), stringDesc = lang.transstr("arena_redGold_lock"),getKey = function() return LockType.Arena_RedGold_Lock end  },
    { desc = lang.trans("arena_anniversary_lock"), stringDesc = lang.transstr("arena_anniversary_lock"), getKey = function() return LockType.Arena_Anniversary_Lock end  },
    { desc = lang.trans("arena_peak_lock"), stringDesc = lang.transstr("arena_peak_lock"), getKey = function() return LockType.Arena_Peak_Lock end  },
    -- 巅峰对决
    { desc = lang.trans("peak_order_Lock"), stringDesc = lang.transstr("peak_order_1_lock"), getKey = function() return LockType.Peak_Order1_Lock end },
    { desc = lang.trans("peak_order_rep_Lock"), stringDesc = lang.transstr("peak_order_1_rep_lock"), getKey = function() return LockType.Peak_Order1_Rep_Lock end },
    { desc = lang.trans("peak_order_Lock"), stringDesc = lang.transstr("peak_order_2_lock"), getKey = function() return LockType.Peak_Order2_Lock end },
    { desc = lang.trans("peak_order_rep_Lock"), stringDesc = lang.transstr("peak_order_2_rep_lock"), getKey = function() return LockType.Peak_Order2_Rep_Lock end },
    { desc = lang.trans("peak_order_Lock"), stringDesc = lang.transstr("peak_order_3_lock"), getKey = function() return LockType.Peak_Order3_Lock end },
    { desc = lang.trans("peak_order_rep_Lock"), stringDesc = lang.transstr("peak_order_3_rep_lock"), getKey = function() return LockType.Peak_Order3_Rep_Lock end },
    -- 争霸赛
    { desc = lang.trans("compete_lock"), stringDesc = lang.transstr("compete_lock"), getKey = function() return LockType.Compete_Lock end  },
    { desc = lang.trans("compete_rep_lock"), stringDesc = lang.transstr("compete_rep_lock"), getKey = function() return LockType.Compete_Rep_Lock end  },
    -- 传奇记忆/教练任务
    { desc = lang.trans("card_lock_coach"), stringDesc = lang.transstr("card_lock_coach"), getKey = function() return LockType.CoachMission_Lock end  },
    { desc = lang.trans("card_memory_lock"), stringDesc = lang.transstr("card_memory_lock"), getKey = function() return LockType.CardMemory_Lock end  },
    -- 球员助阵
    { desc = lang.trans("supporter_lock"), stringDesc = lang.transstr("supporter_lock"), getKey = function() return LockType.Supporter_Lock end  },
    { desc = lang.trans("supported_lock"), stringDesc = lang.transstr("supported_lock"), getKey = function() return LockType.Supported_Lock end  },
    -- 特殊赛事（上场）
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_01), getKey = function() return LockType.SpecialEvents_Lock_01 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_02), getKey = function() return LockType.SpecialEvents_Lock_02 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_03), getKey = function() return LockType.SpecialEvents_Lock_03 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_04), getKey = function() return LockType.SpecialEvents_Lock_04 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_05), getKey = function() return LockType.SpecialEvents_Lock_05 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_06), getKey = function() return LockType.SpecialEvents_Lock_06 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_07), getKey = function() return LockType.SpecialEvents_Lock_07 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_08), getKey = function() return LockType.SpecialEvents_Lock_08 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_09), getKey = function() return LockType.SpecialEvents_Lock_09 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_10), getKey = function() return LockType.SpecialEvents_Lock_10 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_11), getKey = function() return LockType.SpecialEvents_Lock_11 end  },
    { desc = lang.trans("special_events_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_Lock_12), getKey = function() return LockType.SpecialEvents_Lock_12 end  },
    -- 特殊赛事（替补）
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_01), getKey = function() return LockType.SpecialEvents_RepLock_01 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_02), getKey = function() return LockType.SpecialEvents_RepLock_02 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_03), getKey = function() return LockType.SpecialEvents_RepLock_03 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_04), getKey = function() return LockType.SpecialEvents_RepLock_04 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_05), getKey = function() return LockType.SpecialEvents_RepLock_05 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_06), getKey = function() return LockType.SpecialEvents_RepLock_06 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_07), getKey = function() return LockType.SpecialEvents_RepLock_07 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_08), getKey = function() return LockType.SpecialEvents_RepLock_08 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_09), getKey = function() return LockType.SpecialEvents_RepLock_09 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_10), getKey = function() return LockType.SpecialEvents_RepLock_10 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_11), getKey = function() return LockType.SpecialEvents_RepLock_11 end  },
    { desc = lang.trans("special_events_rep_lock"), stringDesc = GetSpecialEventsDescByLockType(LockType.SpecialEvents_RepLock_12), getKey = function() return LockType.SpecialEvents_RepLock_12 end  },
    -- 替补阵容
    { desc = lang.trans("bench_team_lock"), stringDesc = lang.transstr("bench_team_lock"), getKey = function() return LockType.FirstBenchFormation_CourtLock end },
    { desc = lang.trans("bench_team_lock"), stringDesc = lang.transstr("bench_team_lock"), getKey = function() return LockType.FirstBenchFormation_BenchLock end },
    { desc = lang.trans("bench_team_lock"), stringDesc = lang.transstr("bench_team_lock"), getKey = function() return LockType.SecondBenchFormation_CourtLock end },
    { desc = lang.trans("bench_team_lock"), stringDesc = lang.transstr("bench_team_lock"), getKey = function() return LockType.SecondBenchFormation_BenchLock end },
}

function LockHelper:ctor(lockList)
    self.isLock = false
    self.lockData = nil
    self:InitLockNum(lockList)
end 

function LockHelper:GetLockState()
    return self.isLock
end

function LockHelper:GetLockData()
    return self.lockData
end

function LockHelper:InitLockNum(lockList, currTid)
    if not lockList then return end
    self:ChangeLockTypeByTeamId(currTid)
    local isLock = false
    local lockData = nil
    for i, data in ipairs(LockDetail) do
        local lockType = data.getKey()
        local lockNum = self:GetLockNum(lockList, lockType)
        local keyValue = self:GetLockValue(lockType)
        if floor(lockNum / (2 * keyValue)) ~= floor((lockNum + keyValue) / (2 * keyValue)) then
            isLock = true 
            lockData = data
            break
        end
    end
    self.isLock = isLock
    self.lockData = lockData
end

function LockHelper:GetLockValue(lockType)
    lockType = tonumber(lockType)
    local lockSqr = fmod(lockType, LockGroupMax)
    return ldexp(1, lockSqr)
end

function LockHelper:GetLockGroupIndexByLockType(lockType)
    lockType = tonumber(lockType)
    local index = modf(lockType / LockGroupMax)
    index = index + 1
    return index
end

-- 替补阵容信息
local function SetBenchFormationInfo(firstBenchId, secondBenchId)
    local index = {}
    for i, v in pairs(LockDetail) do
        if v.getKey() == LockType.FirstBenchFormation_CourtLock then
            index[LockType.FirstBenchFormation_CourtLock] = i
        elseif v.getKey() == LockType.FirstBenchFormation_BenchLock then
            index[LockType.FirstBenchFormation_BenchLock] = i
        elseif v.getKey() == LockType.SecondBenchFormation_CourtLock then
            index[LockType.SecondBenchFormation_CourtLock] = i
        elseif v.getKey() == LockType.SecondBenchFormation_BenchLock then
            index[LockType.SecondBenchFormation_BenchLock] = i
        end
    end
    LockDetail[index[LockType.FirstBenchFormation_CourtLock]].stringDesc = lang.transstr("formation_lock", lang.transstr("number_" .. firstBenchId))
    LockDetail[index[LockType.FirstBenchFormation_BenchLock]].stringDesc = lang.transstr("formation_rep_lock", lang.transstr("number_" .. firstBenchId))
    LockDetail[index[LockType.SecondBenchFormation_CourtLock]].stringDesc = lang.transstr("formation_lock", lang.transstr("number_" .. secondBenchId))
    LockDetail[index[LockType.SecondBenchFormation_BenchLock]].stringDesc = lang.transstr("formation_rep_lock", lang.transstr("number_" .. secondBenchId))
end

function LockHelper:ChangeLockTypeByTeamId(currTid)
    if currTid then
        if currTid == 0 then
            LockType.CourtLock = 1
            LockType.BenchLock = 3
            LockType.FirstBenchFormation_CourtLock = 37
            LockType.FirstBenchFormation_BenchLock = 38
            LockType.SecondBenchFormation_CourtLock = 39
            LockType.SecondBenchFormation_BenchLock = 40
            SetBenchFormationInfo(2, 3)
        elseif currTid == 1 then
            LockType.CourtLock = 37
            LockType.BenchLock = 38
            LockType.FirstBenchFormation_CourtLock = 1
            LockType.FirstBenchFormation_BenchLock = 3
            LockType.SecondBenchFormation_CourtLock = 39
            LockType.SecondBenchFormation_BenchLock = 40
            SetBenchFormationInfo(1, 3)
        elseif currTid == 2 then
            LockType.CourtLock = 39
            LockType.BenchLock = 40
            LockType.FirstBenchFormation_CourtLock = 1
            LockType.FirstBenchFormation_BenchLock = 3
            LockType.SecondBenchFormation_CourtLock = 37
            LockType.SecondBenchFormation_BenchLock = 38
            SetBenchFormationInfo(1, 2)
        end
    end
end

function LockHelper:IsNoLock(lockList)
    if not lockList then return true end
    local isNoLock = true
    for lockIndex, lockNum in ipairs(lockList) do
        if lockNum > NoLock then
            return false
        end
    end
    return isNoLock
end

-- lockList lock值
-- lockTypeFilter 需要筛选的lockType
-- filterType LockType和lockTypeFilter 补集(false)或并集(true)
function LockHelper:GetLockTypeList(lockList, lockTypeFilterInfo)
    local lockTypeList = {}
    lockTypeFilterInfo = lockTypeFilterInfo or {}
    local lockTypeFilter = lockTypeFilterInfo.lockTypeFilter or {}
    local filterType = tobool(lockTypeFilterInfo.filterType)
    for i, lockType in pairs(LockType) do
        if type(lockType) == "number" then
            local isInFilter = false
            if filterType then
                isInFilter = lockTypeFilter[lockType]
            else
                isInFilter = not lockTypeFilter[lockType]
            end
            if isInFilter then
                local lockNum = self:GetLockNum(lockList, lockType)
                local lockValue = self:GetLockValue(lockType)
                if floor(lockNum / (2 * lockValue)) ~= floor((lockNum + lockValue) / (2 * lockValue)) then
                    lockTypeList[lockType] = true
                end
            end
        end
    end
    return lockTypeList
end

-- 减少计算 这个判断出一个锁之后直接返回  逻辑同GetLockTypeList
-- lockList lock值
-- lockTypeFilter 需要筛选的lockType
-- filterType LockType和lockTypeFilter 补集(false)或并集(true)
function LockHelper:IsLockByLockTypes(lockList, lockTypeFilterInfo)
    lockTypeFilterInfo = lockTypeFilterInfo or {}
    local lockTypeFilter = lockTypeFilterInfo.lockTypeFilter or {}
    local filterType = tobool(lockTypeFilterInfo.filterType)
    for i, lockType in pairs(LockType) do
        if type(lockType) == "number" then
            local isInFilter = false
            if filterType then
                isInFilter = lockTypeFilter[lockType]
            else
                isInFilter = not lockTypeFilter[lockType]
            end
            if isInFilter then
                local lockNum = self:GetLockNum(lockList, lockType)
                local lockValue = self:GetLockValue(lockType)
                if floor(lockNum / (2 * lockValue)) ~= floor((lockNum + lockValue) / (2 * lockValue)) then
                    return true
                end
            end
        end
    end
    return false
end

function LockHelper:GetLockNum(lockList, lockType)
    if not lockList then return 0 end
    local lockGroupIndex = self:GetLockGroupIndexByLockType(lockType)
    local lockNum = lockList[lockGroupIndex]
    return lockNum or 0
end

function LockHelper:GetDetailDesByLockNum(lockList, lockTypeFilterInfo)
    if not lockList then return end
    local lockDataList = {}
    local lockTypeList = self:GetLockTypeList(lockList, lockTypeFilterInfo)
    for i, lockData in ipairs(LockDetail) do
        local lockType = lockData.getKey()
        if lockTypeList[lockType] then
            table.insert(lockDataList, lockData)
        end
    end
    return lockDataList
end

return LockHelper