local LockType = {
    PlayerLock = 0,-- 玩家自锁 - 强制锁
    CourtLock = 1,-- 当前阵容上场锁（上场球员） - 强制锁
    ArenaLock = 2,-- 竞技场上场锁（上场球员） - 强制锁(暂时废弃)

    BenchLock= 3,-- 当前阵容 替补 - 提示锁
    ArenaBench_Lock = 4,-- 竞技场阵容 替补 - 提示锁(暂时废弃)

    Arena_Silver_Lock = 5, -- 白银竞技场阵容上场锁（上场球员） - 强制锁
    Arena_Silver_Rep_Lock = 6, -- 白银竞技场阵容 替补 - 提示锁
    Arena_Gold_Lock = 7, -- 黄金竞技场阵容上场锁（上场球员） - 强制锁
    Arena_Gold_Rep_Lock = 8, -- 黄金竞技场阵容 替补 - 提示锁
    Arena_Black_Lock = 9, -- 黑金竞技场阵容上场锁（上场球员） - 强制锁
    Arena_Black_Rep_Lock = 10, -- 黑金竞技场阵容 替补 - 提示锁
    Arena_Platinum_Lock = 11, -- 白金竞技场阵容上场锁（上场球员） - 强制锁
    Arena_Platinum_Rep_Lock = 12, -- 白金竞技场阵容 替补 - 提示锁

    -- 特殊赛事 上场
    SpecialEvents_Lock_01 = 13,
    SpecialEvents_Lock_02 = 15,
    SpecialEvents_Lock_03 = 17,
    SpecialEvents_Lock_04 = 19,
    SpecialEvents_Lock_05 = 21,
    SpecialEvents_Lock_06 = 23,
    SpecialEvents_Lock_07 = 25,
    SpecialEvents_Lock_08 = 27,
    SpecialEvents_Lock_09 = 29,
    SpecialEvents_Lock_10 = 31,
    SpecialEvents_Lock_11 = 33,
    SpecialEvents_Lock_12 = 35,
    -- lockType = SpecialEventId
    SpecialEvents_Lock = {[13] = 1, [15] = 2, [17] = 3, [19] = 4, [21] = 5, [23] = 6, [25] = 7, [27] = 8, [29] = 9, [31] = 10, [33] = 11, [35] = 12},

    -- 特殊赛事 替补
    SpecialEvents_RepLock_01 = 14,
    SpecialEvents_RepLock_02 = 16,
    SpecialEvents_RepLock_03 = 18,
    SpecialEvents_RepLock_04 = 20,
    SpecialEvents_RepLock_05 = 22,
    SpecialEvents_RepLock_06 = 24,
    SpecialEvents_RepLock_07 = 26,
    SpecialEvents_RepLock_08 = 28,
    SpecialEvents_RepLock_09 = 30,
    SpecialEvents_RepLock_10 = 32,
    SpecialEvents_RepLock_11 = 34,
    SpecialEvents_RepLock_12 = 36,
    -- lockType = SpecialEventId
    SpecialEvents_RepLock = {[14] = 1, [16] = 2, [18] = 3, [20] = 4, [22] = 5, [24] = 6, [26] = 7, [28] = 8, [30] = 9, [32] = 10, [34] = 11, [36] = 12},

    FirstBenchFormation_CourtLock = 37,  -- 第一套替补阵容上场球员锁
    FirstBenchFormation_BenchLock = 38,  -- 第一套替补阵容替补球员锁
    SecondBenchFormation_CourtLock = 39, -- 第二套替补阵容上场球员锁
    SecondBenchFormation_BenchLock = 40,  -- 第二套替补阵容替补球员锁

    Peak_Order1_Lock = 41, --巅峰对决队伍1 阵容上场锁（上场球员） - 强制锁
    Peak_Order1_Rep_Lock = 42,  --巅峰对决队伍 替补 - 提示锁
    Peak_Order2_Lock = 43, --巅峰对决队伍2 阵容上场锁（上场球员） - 强制锁
    Peak_Order2_Rep_Lock = 44, --巅峰对决队伍 替补 - 提示锁
    Peak_Order3_Lock = 45, --巅峰对决队伍3 阵容上场锁（上场球员） - 强制锁
    Peak_Order3_Rep_Lock = 46, --巅峰对决队伍 替补 - 提示锁
    Peak_Lock = {[41] = 41, [43] = 43, [45] = 45},
    Peak_RepLock = {[42] = 42, [44] = 44, [46] = 46},

    Compete_Lock = 47, --争霸赛上锁 --强制锁
    Compete_Rep_Lock = 48, --争霸赛上锁 替补 --强制锁

    CoachMission_Lock = 49, --教练任务上锁 --强制锁

    CardMemory_Lock = 50, --传奇记忆上锁 --强制锁

    Arena_RedGold_Lock = 51, --红金竞技场上锁 --强制锁
    Arena_Anniversary_Lock = 52, --周年庆竞技场上锁 --强制锁
    Arena_Peak_Lock = 53, --巅峰竞技场上锁 --强制锁

    Supporter_Lock = 54, --球员助力（助阵其他球员中） --强制锁
    Supported_Lock = 55, --球员助力（接受助阵中）--强制锁
}

return LockType

