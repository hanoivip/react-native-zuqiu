local GameObjectHelper = require("ui.common.GameObjectHelper")

local PeakRuleView = class(unity.base)

function PeakRuleView:ctor()
    self.scrollView = self.___ex.scrollView
    self.menuGroup = self.___ex.menuGroup
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.contentTitle = self.___ex.contentTitle
    self.dailyScrollView = self.___ex.dailyScrollView
    self.seasonScrollView = self.___ex.seasonScrollView
    self.descContent = self.___ex.descContent
    self.dailyContent = self.___ex.dailyContent
    self.seasonContent = self.___ex.seasonContent
    self.scoreContent = self.___ex.scoreContent
    self.scoreScrollView = self.___ex.scoreScrollView
end

function PeakRuleView:start()
end

function PeakRuleView:InitView(model)
    self.model = model
end

function PeakRuleView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function PeakRuleView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function PeakRuleView:InitDescView()
    self.menuGroup:selectMenuItem("desc")
    GameObjectHelper.FastSetActive(self.descContent, true)
    GameObjectHelper.FastSetActive(self.dailyContent, false)
    GameObjectHelper.FastSetActive(self.seasonContent, false)
    GameObjectHelper.FastSetActive(self.scoreContent, false)
end

function PeakRuleView:InitDailyRewardView()
    self.menuGroup:selectMenuItem("daily")
    self.dailyScrollView:InitView(self.model:GetPeakRewardData())
    GameObjectHelper.FastSetActive(self.descContent, false)
    GameObjectHelper.FastSetActive(self.dailyContent, true)
    GameObjectHelper.FastSetActive(self.seasonContent, false)
     GameObjectHelper.FastSetActive(self.scoreContent, false)
end

function PeakRuleView:InitSeasonRewardView()
    self.menuGroup:selectMenuItem("season")
    self.seasonScrollView:InitView(self.model:GetPeakRankRewardData())
    GameObjectHelper.FastSetActive(self.descContent, false)
    GameObjectHelper.FastSetActive(self.dailyContent, false)
    GameObjectHelper.FastSetActive(self.seasonContent, true)
    GameObjectHelper.FastSetActive(self.scoreContent, false)
end

function PeakRuleView:InitScoreView()
    self.menuGroup:selectMenuItem("score")
    self.scoreScrollView:InitView(self.model:GetPeakScoreData())
    GameObjectHelper.FastSetActive(self.descContent, false)
    GameObjectHelper.FastSetActive(self.dailyContent, false)
    GameObjectHelper.FastSetActive(self.seasonContent, false)
    GameObjectHelper.FastSetActive(self.scoreContent, true)
end

return PeakRuleView