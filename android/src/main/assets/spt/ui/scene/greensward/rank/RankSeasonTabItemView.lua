local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RankSeasonTabItemView = class(LuaButton)

function RankSeasonTabItemView:ctor()
    RankSeasonTabItemView.super.ctor(self)
--------Start_Auto_Generate--------
    self.seasonName1Txt = self.___ex.seasonName1Txt
    self.seasonName2Txt = self.___ex.seasonName2Txt
--------End_Auto_Generate----------
end

function RankSeasonTabItemView:InitView(seasonData)
    local nameStr = ""
    if seasonData.isCurrent then
        nameStr = lang.transstr("ladder_curSeasonRank")
    else
        nameStr = lang.trans("ladder_reward_seasonName", seasonData.seasonID)
    end
    self.seasonName1Txt.text = nameStr
    self.seasonName2Txt.text = nameStr
end

return RankSeasonTabItemView
