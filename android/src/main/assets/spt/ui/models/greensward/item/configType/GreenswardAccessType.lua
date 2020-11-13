-- local GreenswardAccessType = require("ui.models.greensward.item.configType.GreenswardAccessType")

local GreenswardAccessType = {
    Initial = 1, -- 初始给的，accessAdvId为空
    Purchase = 2 -- 通过商店购买，对应accessAdvID为AdventureStore中id
}

return GreenswardAccessType
