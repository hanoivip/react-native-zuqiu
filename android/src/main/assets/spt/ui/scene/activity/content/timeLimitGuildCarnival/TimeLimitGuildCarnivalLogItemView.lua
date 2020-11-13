local GameObjectHelper = require("ui.common.GameObjectHelper")

local TimeLimitGuildCarnivalLogItemView = class(unity.base, "TimeLimitGuildCarnivalLogItemView")

function TimeLimitGuildCarnivalLogItemView:ctor()
    self.log = self.___ex.log
    self.time = self.___ex.time
end

function TimeLimitGuildCarnivalLogItemView:InitView(data)
    self.log.text = lang.trans("time_limit_guild_carnival_log_item", data.itemName .. "X" .. data.itemNum, data.score)
    self.time.text = string.formatTimestampNoYear(data.buy_t)
end

return TimeLimitGuildCarnivalLogItemView