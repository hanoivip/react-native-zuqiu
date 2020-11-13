local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local ArenaMatchBarView = require("ui.scene.arena.schedule.MatchBarView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local MatchBarView = class(ArenaMatchBarView)

function MatchBarView:ctor()
	MatchBarView.super.ctor(self)
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign
end

function MatchBarView:InitView(data, playerId, scheduleModel)
    local win = tonumber(data.win)
    local fail = tonumber(data.fail)
    local flat = tonumber(data.equal)
    local goal = tonumber(data.goal)
    local lose = tonumber(data.lost)
    local gwin = tonumber(data.victoryScore)
    local score = tonumber(data.score)
    
    self.num.text = tostring( win + flat + fail)
    self.win.text = tostring(win)
    self.flat.text = tostring(flat)
    self.fail.text = tostring(fail)
    self.goal.text = tostring(goal)
    self.lose.text = tostring(lose)
    self.gWin.text = tostring(gwin)
    self.score.text = tostring(score)

    local name = ""
    local id = data.pid
    if id then 
        name = scheduleModel:GetTeamInfo(id).name
    end
    self.nameTxt.text = name
    self.nameTxt.color = id == playerId and Color.yellow or Color.white
    self:InitCompeteSign(data.worldTournamentLevel)
end

function MatchBarView:InitCompeteSign(worldTournamentLevel)
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

return MatchBarView