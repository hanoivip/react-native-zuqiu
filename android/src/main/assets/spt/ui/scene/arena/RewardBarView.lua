local ArenaScore = require("data.ArenaScore")
local ArenaReward = require("data.ArenaReward")
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardBarView = class(unity.base)

local RankType = { Champion = 1, Runner_up = 2}
function RewardBarView:ctor()
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.normal = self.___ex.normal
    self.normalText = self.___ex.normalText
    self.medalIcon = self.___ex.medalIcon
    self.medalText = self.___ex.medalText
    self.score = self.___ex.score
end

function RewardBarView:InitView(arenaModel, index, standardStage, arenaType)
    local arenaScoreData = ArenaScore[tostring(index)]
    self.normalText.text = arenaScoreData.rankName
    self.score.text = tostring(arenaScoreData.score)
    local arenaIndex = ArenaIndexType[arenaType]
    arenaIndex = arenaIndex > 5 and 5 or arenaIndex
    self.medalIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Medal" .. arenaIndex .. ".png")
    local arenaReward = ArenaReward[tostring(standardStage)]
    local reward = arenaReward[tostring(index)]
    self.medalText.text = "x" .. reward

    GameObjectHelper.FastSetActive(self.first.gameObject, index == RankType.Champion)
    GameObjectHelper.FastSetActive(self.second.gameObject, index == RankType.Runner_up)
    GameObjectHelper.FastSetActive(self.normal.gameObject, index ~= RankType.Runner_up and index ~= RankType.Champion)
end

return RewardBarView
