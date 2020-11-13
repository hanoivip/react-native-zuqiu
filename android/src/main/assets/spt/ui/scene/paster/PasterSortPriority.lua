local PasterMainType = require("ui.scene.paster.PasterMainType")

-- Key与PasterMainType的value保持一致
-- Value决定显示的顺序 荣耀 > 周年 > 月 > 周 > 争霸赛
local PasterSortPriority =
{
    2,  -- Week
    3,  -- Month
    10, -- Honor
    1, -- Compete
    5   -- Annual
}

return PasterSortPriority