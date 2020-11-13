local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local ArenaScheduleTeamModel = require("ui.models.arena.schedule.ArenaScheduleTeamModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaOutPageView = class(unity.base)
local Image = UnityEngine.UI.Image

function ArenaOutPageView:ctor()
    self.scrollView = self.___ex.scrollView
    self.sixteenIntoEightTitle = self.___ex.sixteenIntoEightTitle
    self.eightIntoFourTitle = self.___ex.eightIntoFourTitle
    self.semiTitle = self.___ex.semiTitle
    self.finalTitle = self.___ex.finalTitle
end

function ArenaOutPageView:InitView(arenaKnockoutModel, arenaType)

    local arenaIndex = ArenaIndexType[arenaType]

    local cup = self.scrollView.stages[#self.scrollView.stages].cup:GetComponent(Image)

    cup.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Details/Bytes/Cup" .. arenaIndex .. ".png")
    cup:SetNativeSize()

    self.arenaKnockoutModel = arenaKnockoutModel
    local arenaScheduleTeamModel = ArenaScheduleTeamModel.GetInstance()
    local playerInfoModel = PlayerInfoModel.new()
    local playerId = playerInfoModel:GetID()
    self:ShowSchedule(MatchScheduleType.SixteenIntoEight, self.scrollView.stages[1].teams, arenaKnockoutModel, arenaScheduleTeamModel, playerId)
    self:ShowSchedule(MatchScheduleType.EightIntoFour, self.scrollView.stages[2].teams, arenaKnockoutModel, arenaScheduleTeamModel, playerId)
    self:ShowSchedule(MatchScheduleType.Semi, self.scrollView.stages[3].teams, arenaKnockoutModel, arenaScheduleTeamModel, playerId)
    self:ShowSchedule(MatchScheduleType.Final, self.scrollView.stages[4].teams, arenaKnockoutModel, arenaScheduleTeamModel, playerId)

    self:ShowTitle(MatchScheduleType.SixteenIntoEight, self.sixteenIntoEightTitle, arenaScheduleTeamModel)
    self:ShowTitle(MatchScheduleType.EightIntoFour, self.eightIntoFourTitle, arenaScheduleTeamModel)
    self:ShowTitle(MatchScheduleType.Semi, self.semiTitle, arenaScheduleTeamModel)
    self:ShowTitle(MatchScheduleType.Final, self.finalTitle, arenaScheduleTeamModel)
end

function ArenaOutPageView:ShowTitle(matchScheduleType, titleView, arenaScheduleTeamModel)
    titleView:InitView(matchScheduleType, arenaScheduleTeamModel)
end

function ArenaOutPageView:ShowSchedule(matchScheduleType, scheduleMap, arenaKnockoutModel, arenaScheduleTeamModel, playerId)
    local scheduleData = arenaKnockoutModel:GetMatchScheduleData(matchScheduleType) or {}
    for index, view in pairs(scheduleMap) do
        local teamData = scheduleData and scheduleData[index] or {}
        view:InitView(teamData, arenaScheduleTeamModel, playerId, matchScheduleType, index)
    end
end

function ArenaOutPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function ArenaOutPageView:EnterScene()

end

function ArenaOutPageView:ExitScene()

end

return ArenaOutPageView
