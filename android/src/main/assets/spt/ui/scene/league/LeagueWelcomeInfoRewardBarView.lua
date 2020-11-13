local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LeagueWelcomeInfoRewardBarView = class(unity.base)

function LeagueWelcomeInfoRewardBarView:ctor()
    -- 排名文本
    self.rankText = self.___ex.rankText
    -- 奖金数量文本
    self.numText = self.___ex.numText
    -- 高亮
    self.lightGroup = self.___ex.lightGroup
    -- 排名
    self.rank = nil
    -- 奖金数量
    self.rewardNum = nil
    -- 自身排名
    self.myRank = nil
end

function LeagueWelcomeInfoRewardBarView:InitView(rank, rewardNum, myRank)
    self.rank = rank
    self.rewardNum = rewardNum
    self.myRank = myRank
    
    self:BuildPage()
end

function LeagueWelcomeInfoRewardBarView:start()
end

function LeagueWelcomeInfoRewardBarView:BuildPage()
    self.rankText.text = lang.trans("league_rank", self.rank)
    self.numText.text = string.formatNumWithUnit(self.rewardNum)
    GameObjectHelper.FastSetActive(self.lightGroup, self.rank == self.myRank)
end

return LeagueWelcomeInfoRewardBarView