local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local MatchBarView = class(unity.base)

function MatchBarView:ctor()
    self.nameTxt = self.___ex.name
    self.num = self.___ex.num
    self.win = self.___ex.win
    self.flat = self.___ex.flat
    self.fail = self.___ex.fail
    self.goal = self.___ex.goal
    self.lose = self.___ex.lose
    self.gWin = self.___ex.gWin
    self.score = self.___ex.score
    self.btnCheck = self.___ex.btnCheck
end

function MatchBarView:InitView(data, playerId, arenaScheduleTeamModel)
    local win = tonumber(data.win)
    local fail = tonumber(data.fail)
    local flat = tonumber(data.equal)
    local goal = tonumber(data.goal)
    local lose = tonumber(data.lose)
    local gwin = tonumber(data.pwin)
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
    local id = data.id
    if id then 
        name = arenaScheduleTeamModel:GetPlayerName(id)
    end
    self.nameTxt.text = name

    self.nameTxt.color = id == playerId and Color.yellow or Color.white
end

return MatchBarView