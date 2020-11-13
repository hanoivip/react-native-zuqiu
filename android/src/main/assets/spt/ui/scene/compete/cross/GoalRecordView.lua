local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local GoalRecordView = class(unity.base)

function GoalRecordView:ctor()
    self.logo = self.___ex.logo
    self.nameTxt = self.___ex.name
    self.server = self.___ex.server
    self.penaltyScore = self.___ex.penaltyScore
    self.totalScore = self.___ex.totalScore
    self.score1 = self.___ex.score1
    self.score2 = self.___ex.score2
    self.pContent = self.___ex.pContent
    self.oContent = self.___ex.oContent
    self.video = self.___ex.video
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign
    self.rctName = self.___ex.rctName
end

function GoalRecordView:start()
    if self.video then
        self.video:regOnButtonClick(function()
            self:OnBtnVideo()
        end)
    end
end

function GoalRecordView:InitView(pid, homeData, visitData, teamList, score, penaltyScore, isHome, vid)
    local teamInfo = teamList[pid] or { }
    local logoData = teamInfo.logo
    TeamLogoCtrl.BuildTeamLogo(self.logo, logoData)
    local name = teamInfo.name or ""
    local sid = teamInfo.sid or ""
    self.nameTxt.text = name
    self.server.text = sid .. lang.transstr("server")
    self.penaltyScore.text = tostring(penaltyScore)
    self.totalScore.text = tostring(score)
    
    local h_shooter, h_assister, v_shooter, v_assister
    if isHome then
        h_shooter = homeData.shooter or { }
        h_assister = homeData.assister or { }
        v_shooter = visitData.shooter or { }
        v_assister = visitData.assister or { }
    else
        h_shooter = visitData.shooter or { }
        h_assister = visitData.assister or { }
        v_shooter = homeData.shooter or { }
        v_assister = homeData.assister or { }
    end

    local h_score = homeData.score or "-"
    local v_score = visitData.score or "-"
    self.score1.text = tostring(h_score)
    self.score2.text = tostring(v_score)

    for i, shootName in ipairs(h_shooter) do
        local pGoal = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/PGoal.prefab")
        local pGoalSpt = res.GetLuaScript(pGoal)
        pGoalSpt:InitView(shootName, h_assister[i], isHome)
        pGoal.transform:SetParent(self.pContent, false)
    end

    for i, shootName in ipairs(v_shooter) do
        local pGoal = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/OGoal.prefab")
        local pGoalSpt = res.GetLuaScript(pGoal)
        pGoalSpt:InitView(shootName, v_assister[i], isHome)
        pGoal.transform:SetParent(self.oContent, false)
    end
    GameObjectHelper.FastSetActive(self.video.gameObject, vid ~= nil)
    self.vid = vid

    self:InitCompeteSign(teamInfo, isHome)
end

function GoalRecordView:OnBtnVideo()
    clr.coroutine(function()
        local respone = req.worldTournamentVideo(self.vid)
        if api.success(respone) then
            local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
            ReplayCheckHelper.StartReplay(respone.val.video, self.vid)
        end
    end)
end

function GoalRecordView:InitCompeteSign(data, isHome)
    local worldTournamentLevel = data.worldTournamentLevel
    local posX
    if isHome then
        posX = -30
    else
        posX = 30
    end
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, true)
            self.competeSign.overrideSprite = AssetFinder.GetCompeteSign(signData.path)
            if isHome then
                posX = 4
            else
                posX = -4
            end
        else
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    end
    self.rctName.anchoredPosition = Vector2(posX, self.rctName.anchoredPosition.y)
end

return GoalRecordView