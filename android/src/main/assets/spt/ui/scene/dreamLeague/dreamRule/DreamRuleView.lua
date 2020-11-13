local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamRuleView = class(unity.base, "DreamRuleView")

function DreamRuleView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.menuRct = self.___ex.menuRct

    self.mainDescContent = self.___ex.mainDescContent
    self.cardsContent = self.___ex.cardsContent
    self.hallContent = self.___ex.hallContent
    self.mvpGuessContent = self.___ex.mvpGuessContent
    self.dailyRewardContent = self.___ex.dailyRewardContent
    self.rankRewardContent = self.___ex.rankRewardContent

    self.txtMainDesc = self.___ex.txtMainDesc
    self.txtCards = self.___ex.txtCards
    self.txtHall = self.___ex.txtHall
    self.txtMVPGuess = self.___ex.txtMVPGuess

    self.dailyRewardScroll = self.___ex.dailyRewardScroll
    self.rankRewardScroll = self.___ex.rankRewardScroll
end

function DreamRuleView:start()
end

function DreamRuleView:InitView(model)
    self.model = model
end

function DreamRuleView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function DreamRuleView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function DreamRuleView:InitMainDescView()
    self.menuGroup:selectMenuItem("MainDesc")
    GameObjectHelper.FastSetActive(self.mainDescContent, true)
    GameObjectHelper.FastSetActive(self.cardsContent, false)
    GameObjectHelper.FastSetActive(self.hallContent, false)
    GameObjectHelper.FastSetActive(self.mvpGuessContent, false)
    GameObjectHelper.FastSetActive(self.dailyRewardContent, false)
    GameObjectHelper.FastSetActive(self.rankRewardContent, false)

    self.txtMainDesc.text = self.model:GetDescByTag("MainDesc")
end

function DreamRuleView:InitCardsView()
    self.menuGroup:selectMenuItem("Cards")
    GameObjectHelper.FastSetActive(self.mainDescContent, false)
    GameObjectHelper.FastSetActive(self.cardsContent, true)
    GameObjectHelper.FastSetActive(self.hallContent, false)
    GameObjectHelper.FastSetActive(self.mvpGuessContent, false)
    GameObjectHelper.FastSetActive(self.dailyRewardContent, false)
    GameObjectHelper.FastSetActive(self.rankRewardContent, false)

    self.txtCards.text = self.model:GetDescByTag("Cards")
end

function DreamRuleView:InitHallView()
    self.menuGroup:selectMenuItem("Hall")
    GameObjectHelper.FastSetActive(self.mainDescContent, false)
    GameObjectHelper.FastSetActive(self.cardsContent, false)
    GameObjectHelper.FastSetActive(self.hallContent, true)
    GameObjectHelper.FastSetActive(self.mvpGuessContent, false)
    GameObjectHelper.FastSetActive(self.dailyRewardContent, false)
    GameObjectHelper.FastSetActive(self.rankRewardContent, false)

    self.txtHall.text = self.model:GetDescByTag("Hall")
end

function DreamRuleView:InitMVPGuessView()
    self.menuGroup:selectMenuItem("MVPGuess")
    GameObjectHelper.FastSetActive(self.mainDescContent, false)
    GameObjectHelper.FastSetActive(self.cardsContent, false)
    GameObjectHelper.FastSetActive(self.hallContent, false)
    GameObjectHelper.FastSetActive(self.mvpGuessContent, true)
    GameObjectHelper.FastSetActive(self.dailyRewardContent, false)
    GameObjectHelper.FastSetActive(self.rankRewardContent, false)

    self.txtMVPGuess.text = self.model:GetDescByTag("MVPGuess")
end

function DreamRuleView:InitDailyRewardView()
    self.menuGroup:selectMenuItem("DailyReward")
    GameObjectHelper.FastSetActive(self.mainDescContent, false)
    GameObjectHelper.FastSetActive(self.cardsContent, false)
    GameObjectHelper.FastSetActive(self.hallContent, false)
    GameObjectHelper.FastSetActive(self.mvpGuessContent, false)
    GameObjectHelper.FastSetActive(self.dailyRewardContent, true)
    GameObjectHelper.FastSetActive(self.rankRewardContent, false)
    
    self.dailyRewardScroll:InitView(self.model:GetDailyRewardData())
end

function DreamRuleView:InitRankRewardView()
    self.menuGroup:selectMenuItem("RankReward")
    GameObjectHelper.FastSetActive(self.mainDescContent, false)
    GameObjectHelper.FastSetActive(self.cardsContent, false)
    GameObjectHelper.FastSetActive(self.hallContent, false)
    GameObjectHelper.FastSetActive(self.mvpGuessContent, false)
    GameObjectHelper.FastSetActive(self.dailyRewardContent, false)
    GameObjectHelper.FastSetActive(self.rankRewardContent, true)

    self.rankRewardScroll:InitView(self.model:GetRankRewardData())
end

return DreamRuleView
