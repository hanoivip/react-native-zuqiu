local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local DataProvider = clr.ActionLayer.DataProvider

local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CommonConstants = require("ui.common.CommonConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local Timer = require("ui.common.Timer")
local EnumType = require("coregame.EnumType")
local PenaltyShootOutScore = EnumType.PenaltyShootOutScore

local PenaltyShootOutBar = class(unity.base)

function PenaltyShootOutBar:ctor()
    self.playerShots = {}
    self.opponentShots = {}
    self.playerRound = {}
    self.opponentRound = {}
    for i = 1, 5 do
        self.playerShots[i] = self.___ex["playerShot" .. i]
        self.opponentShots[i] = self.___ex["opponentShot" .. i]
        self.playerRound[i] = self.___ex["playerRound" .. i]
        self.opponentRound[i] = self.___ex["opponentRound" .. i]
    end

    self.homeTeamNameText = self.___ex.homeTeamNameText
    self.awayTeamNameText = self.___ex.awayTeamNameText
    self.homeTeamImage = self.___ex.homeTeamImage
    self.awayTeamImage = self.___ex.awayTeamImage
    self.scoreText = self.___ex.scoreText

    self.GoalButtonPath = "Assets/CapstonesRes/Game/UI/Match/Overlay/Images/Common/Btn_Goal.png"
    self.MissButtonPath = "Assets/CapstonesRes/Game/UI/Match/Overlay/Images/Common/Btn_Miss.png"
    self.IdleButtonPath = "Assets/CapstonesRes/Game/UI/Match/Overlay/Images/Common/Btn_Idle.png"
    self.preScore = {}
end

function PenaltyShootOutBar:start()
    local matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    self:InitPenaltyShootOutData(playerTeamData, opponentTeamData)
end

function PenaltyShootOutBar:InitPenaltyShootOutData(playerTeamData, opponentTeamData)
    self:SetTeamName(self.homeTeamNameText, tostring(playerTeamData.teamName))
    self:SetTeamName(self.awayTeamNameText, tostring(opponentTeamData.teamName))
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamImage, playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.awayTeamImage, opponentTeamData.logo)
end

function PenaltyShootOutBar:SetTeamName(teamNameText, teamName)
    teamNameText.text = teamName
end

function PenaltyShootOutBar:SetPenaltyShootOutData(matchInfo)
    local scoreTxt = matchInfo.playerShootOutScore .. " - " .. matchInfo.opponentShootOutScore
    self.scoreText.text = scoreTxt

    local endRound = math.max(matchInfo.penaltyShootOutRound, 5)
    for i = 1, 5 do
        local round = tostring(endRound - 5 + i)
        self.playerRound[i].text = round
        self.opponentRound[i].text = round
    end

    endRound = math.min(matchInfo.penaltyShootOutRound, 5)
    for i = 1, endRound do
        if matchInfo.penaltyShootOutScore[i] ~= self.preScore[i] then
            self:ChangeShotButton(self.playerShots[i], matchInfo.penaltyShootOutScore[i])
        end
        if matchInfo.penaltyShootOutScore[i + 5] ~= self.preScore[i + 5] then
            self:ChangeShotButton(self.opponentShots[i], matchInfo.penaltyShootOutScore[i + 5])
        end
    end

    for i = 1, 10 do
        self.preScore[i] = matchInfo.penaltyShootOutScore[i]
    end
end

function PenaltyShootOutBar:ChangeShotButton(shotButton, result)
    if result == PenaltyShootOutScore.Goal then
        shotButton.Path = self.GoalButtonPath
    elseif result == PenaltyShootOutScore.Miss then
        shotButton.Path = self.MissButtonPath
    elseif result == PenaltyShootOutScore.Idle then
        shotButton.Path = self.IdleButtonPath
    end
    shotButton:ApplySource()
end

return PenaltyShootOutBar
