local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local TeamInfoView = class(unity.base)

function TeamInfoView:ctor()
    self.teamLogo = self.___ex.teamLogo
    self.teamName = self.___ex.teamName
    self.stageIcon = self.___ex.stageIcon
    self.starMap = self.___ex.starMap
    self.gradeText = self.___ex.gradeText
    self.power = self.___ex.power
end

function TeamInfoView:InitView(arenaModel, arenaNextMatchModel, arenaType, isHome)
    local teamId
    if isHome then
        teamId = arenaNextMatchModel:GetHomeId()
    else
        teamId = arenaNextMatchModel:GetVisitId()
    end
    local teamData = arenaNextMatchModel:GetTeamData(teamId)
    local stageData = arenaNextMatchModel:GetTeamStageData(teamId)
    self.teamName.text = tostring(teamData.name)
    self.power.text = tostring(arenaNextMatchModel:GetTeamPower(teamId))
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, teamData.logo)
    GameObjectHelper.FastSetActive(self.teamLogo.gameObject, true);
    local stage, star, openStar, minStage = arenaModel:GetAreaState(stageData.score)
    for k, v in pairs(self.starMap) do
        local index = tonumber(string.sub(k, 2))
        local starData = ArenaHelper.GetStarPos[tostring(openStar)]
        local isOpen = starData and tobool(index <= openStar)
        if isOpen then
            local pos = starData[index]
            v.gameObject.transform.anchoredPosition = Vector2(pos.x, pos.y)
            local isShow = tobool(index <= star)
            v.interactable = isShow
        end
        GameObjectHelper.FastSetActive(v.gameObject, isOpen)
    end
    local minStageNum, minStageDesc = "", ""
    if stage then
        self.stageIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Mid_Team" .. stage .. ".png")
        self.stageIcon:SetNativeSize()
        local minStagePos = ArenaHelper.GetMinStagePos[tostring(stage)]
        if minStagePos then
            if stage < ArenaHelper.StageType.StoryStage then 
                minStageDesc = lang.transstr("reduce_num", minStage) 
            else
                minStageDesc = lang.transstr("star_num", minStage) 
            end
        end
    end
    self.gradeText.text = "(" .. arenaModel:GetGradeName(stage) .. minStageDesc .. ")"
end

return TeamInfoView
