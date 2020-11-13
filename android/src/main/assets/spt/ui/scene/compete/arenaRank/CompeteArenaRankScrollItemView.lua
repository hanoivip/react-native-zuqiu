local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local CompeteArenaRankScrollItemView = class(unity.base, "CompeteArenaRankScrollItemView")

function CompeteArenaRankScrollItemView:ctor()
    self.rank = self.___ex.rank
    self.nameTxt = self.___ex.name
    self.score = self.___ex.score
    self.turns = self.___ex.turns
    self.win = self.___ex.win
    self.lose = self.___ex.lose
    self.draw = self.___ex.draw
    self.loseBall = self.___ex.loseBall
    self.goal = self.___ex.goal
    self.goalDifference = self.___ex.goalDifference
    self.bg = self.___ex.bg
    self.up = self.___ex.up
    self.down = self.___ex.down
    -- 争霸赛标识
    self.competeSign = self.___ex.sign
end

function CompeteArenaRankScrollItemView:start()
end

function CompeteArenaRankScrollItemView:InitView(data)
    self:ClearScrollItemData()

    self.data = data
    self.rank.text = tostring(data.pos or "-")
    self.nameTxt.text = data.name or "-"
    self.score.text = tostring(data.score or "0")
    self.turns.text = tostring(tonumber(data.win or 0) + tonumber(data.equal or 0) + tonumber(data.fail or 0))
    self.win.text = tostring(data.win or "0")
    self.lose.text = tostring(data.fail or "0")
    self.draw.text = tostring(data.equal or "0")
    self.loseBall.text = tostring(data.lost or "0")
    self.goal.text = tostring(data.goal or "0")
    self.goalDifference.text = tostring(data.victoryGoal or "0")
    self:InitCompeteSign(data)

    GameObjectHelper.FastSetActive(self.bg, data.index % 2 == 0)

    GameObjectHelper.FastSetActive(self.up, data.isUpgrade)
    GameObjectHelper.FastSetActive(self.down, data.isReduce)
end

function CompeteArenaRankScrollItemView:ClearScrollItemData()
    self.rank.text = "-"
    self.nameTxt.text = "-"
    self.score.text = "-"
    self.turns.text = "-"
    self.win.text = "-"
    self.lose.text = "-"
    self.draw.text = "-"
    self.loseBall.text = "-"
    self.goal.text = "-"
    self.goalDifference.text = "-"

    GameObjectHelper.FastSetActive(self.up, false)
    GameObjectHelper.FastSetActive(self.down, false)
end

function CompeteArenaRankScrollItemView:GetItemData()
    return self.data
end

function CompeteArenaRankScrollItemView:InitCompeteSign(data)
    local worldTournamentLevel = data.worldTournamentLevel
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, true)
            self.competeSign.overrideSprite = AssetFinder.GetCompeteSign(signData.path)
        else
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    end
end

return CompeteArenaRankScrollItemView