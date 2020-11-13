local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")

local LeagueSchedulePageView = class(unity.base)

function LeagueSchedulePageView:ctor()
    -- 滚动视图
    self.scrollerView = self.___ex.scrollerView
    -- model
    self.leagueInfoModel = nil
end

function LeagueSchedulePageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.scrollerView:InitView(self.leagueInfoModel)
end

return LeagueSchedulePageView