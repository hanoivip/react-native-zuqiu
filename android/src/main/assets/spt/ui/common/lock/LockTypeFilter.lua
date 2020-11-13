local LockType = require("ui.common.lock.LockType")

local LockTypeFilter = {
    -- 所有上阵/替补锁
    AllTeam = {
        lockTypeFilter =
        {
            [LockType.PlayerLock] = true,
            [LockType.CoachMission_Lock] = true,
            [LockType.CardMemory_Lock] = true,
            [LockType.Supporter_Lock] = true,
            [LockType.Supported_Lock] = true,
        },
        filterType = false,
    },
    -- 可出售的阵容
    CanSell = {
        lockTypeFilter =
        {
            [LockType.Arena_Silver_Rep_Lock] = true,
            [LockType.Arena_Gold_Rep_Lock] = true,
            [LockType.Arena_Black_Rep_Lock] = true,
            [LockType.Arena_Platinum_Rep_Lock] = true,
            [LockType.SpecialEvents_RepLock_01] = true,
            [LockType.SpecialEvents_RepLock_02] = true,
            [LockType.SpecialEvents_RepLock_03] = true,
            [LockType.SpecialEvents_RepLock_04] = true,
            [LockType.SpecialEvents_RepLock_05] = true,
            [LockType.SpecialEvents_RepLock_06] = true,
            [LockType.SpecialEvents_RepLock_07] = true,
            [LockType.SpecialEvents_RepLock_08] = true,
            [LockType.SpecialEvents_RepLock_09] = true,
            [LockType.SpecialEvents_RepLock_10] = true,
            [LockType.SpecialEvents_RepLock_11] = true,
            [LockType.SpecialEvents_RepLock_12] = true,
        },
        filterType = false,
    },
}

return LockTypeFilter

