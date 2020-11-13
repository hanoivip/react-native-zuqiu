local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector3 = UnityEngine.Vector3

local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local Formation = require("data.Formation")
local Helper = require("ui.scene.formation.Helper")

local TeamInfoPanel = class(unity.base)

function TeamInfoPanel:ctor()
    self.homeTeamName = self.___ex.homeTeamName
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamName = self.___ex.awayTeamName
    self.awayTeamLogo = self.___ex.awayTeamLogo
    self.homeFormationNameText = self.___ex.homeFormationNameText
    self.awayFormationNameText = self.___ex.awayFormationNameText
    self.homeCourtTrans = self.___ex.homeCourtTrans
    self.awayCourtTrans = self.___ex.awayCourtTrans
    -- 动画延迟时间
    self.waitTime = 3
    self.matchInfoModel = nil
    self.playerTeamData = nil
    self.opponentTeamData = nil
end

function TeamInfoPanel:start()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    self.opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    self:BuildTeam(self.homeTeamLogo, self.homeTeamName, self.playerTeamData)
    self:BuildTeam(self.awayTeamLogo, self.awayTeamName, self.opponentTeamData)
    self:BuildFormation(self.homeCourtTrans, self.homeFormationNameText, true)
    self:BuildFormation(self.awayCourtTrans, self.awayFormationNameText, false)
    clr.coroutine(function ()
        self:StartMatch()
    end)
end

function TeamInfoPanel:BuildTeam(teamLogo, teamName, teamData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, teamData.logo)
    teamName.text = teamData.teamName
end

function TeamInfoPanel:BuildFormation(courtTrans, formationNameText, isHome)
    local initTeamData = nil
    local teamData = nil
    if isHome then
        teamData = self.playerTeamData
        initTeamData = self.matchInfoModel:GetPlayerInitTeamData()
    else
        teamData = self.opponentTeamData
        initTeamData = self.matchInfoModel:GetOpponentInitTeamData()
    end
    for i, athleteData in ipairs(initTeamData) do
        local playerShirtGameObject = Object.Instantiate(PrefabCache.playerShirtObj)
        local rectTrans = playerShirtGameObject.transform
        rectTrans.eulerAngles = Vector3(0, 0, isHome and 0 or 180)
        rectTrans:SetParent(courtTrans, false)
        local playerShirtScript = res.GetLuaScript(playerShirtGameObject)
        playerShirtScript:InitView(athleteData, teamData)
        local posCoords = Helper.GetTrapezoidFormationCoord(athleteData.role, teamData.formation, 512, 450, 12, false)
        rectTrans.localPosition = Vector3(posCoords.x, posCoords.y, 0)
        rectTrans.localScale = Vector3(posCoords.scale * 1.4, posCoords.scale * 1.4, 1)
    end

    formationNameText.text = Formation[tostring(teamData.formation)].name
end

function TeamInfoPanel:StartMatch()
    coroutine.yield(WaitForSeconds(self.waitTime))
    EventSystem.SendEvent("PreMatchManager.StartMatch")
end

return TeamInfoPanel
