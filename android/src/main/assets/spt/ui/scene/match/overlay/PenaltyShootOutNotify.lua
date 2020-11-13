local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local DataProvider = clr.ActionLayer.DataProvider

local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CommonConstants = require("ui.common.CommonConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local Timer = require("ui.common.Timer")

local PenaltyShootOutNotify = class(unity.base)

function PenaltyShootOutNotify:ctor()
    self.players = {}
    self.opponents = {}
    for i = 1, 11 do
        self.players[i] = self.___ex["player" .. i]
    end
    for i = 1, 11 do
        self.opponents[i] = self.___ex["opponent" .. i]
    end

    self.homeTeamNameText = self.___ex.homeTeamNameText
    self.awayTeamNameText = self.___ex.awayTeamNameText
    self.homeTeamImage = self.___ex.homeTeamImage
    self.awayTeamImage = self.___ex.awayTeamImage
    self.continueBtn = self.___ex.continueBtn
    self.animator = self.___ex.animator
    self.tipTimer = nil
end

function PenaltyShootOutNotify:start()
    EventSystem.SendEvent("FightMenuManager.CloseViewsOnCertainTime")
    local matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    self:SetPenaltyShootOutData(playerTeamData, opponentTeamData)
    self:BindAll()
    self:PlayCountdown()
end

function PenaltyShootOutNotify:BindAll()
    self.continueBtn:regOnButtonClick(function ()
        self:DestroyTimer()
        self:PlayOn()
    end)
end

function PenaltyShootOutNotify:SetPenaltyShootOutData(playerTeamData, opponentTeamData)
    self:SetTeamName(self.homeTeamNameText, tostring(playerTeamData.teamName))
    self:SetTeamName(self.awayTeamNameText, tostring(opponentTeamData.teamName))
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamImage, playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.awayTeamImage, opponentTeamData.logo)

    local playerPenaltyShootOutIds = DataProvider.playerPenaltyShootOutIds
    local opponentPenaltyShootOutIds = DataProvider.opponentPenaltyShootOutIds

    for i = 0, 10 do
        local playerId = playerPenaltyShootOutIds[i]
        local athlete = ___matchUI:getAthlete(playerId)
        self.players[i + 1].text = athlete.name

        local opponentId = opponentPenaltyShootOutIds[i]
        athlete = ___matchUI:getAthlete(opponentId)
        self.opponents[i + 1].text = athlete.name
    end
end

function PenaltyShootOutNotify:SetTeamName(teamNameText, teamName)
    teamNameText.text = teamName
    local teamNameLen = string.len(teamName)
    if teamNameLen > 20 then
        local scaleX = 20 / teamNameLen
        teamNameText.transform.localScale = Vector3(scaleX < 0.8 and 0.8 or scaleX, 1, 1)
    end
end

function PenaltyShootOutNotify:PlayOn()
    if type(self.closeDialog) == 'function' then
        ___deadBallTimeManager:TryToSkipDeadBallTimeScene(0)
        ___matchUI:onPenaltyShootOutStart()
        GameHubWrap.SetSkipSignal(0)
        self.closeDialog()
        if TimeLineWrap.IsInFastForward() and ___matchUI.isFastForwardBeforeHalfTime == true then
            TimeLineWrap.StartFastForward(___matchUI.timeScaleMultipleBeforeHalfTime)
        end
    end
end

--- 播放5秒倒计时
function PenaltyShootOutNotify:PlayCountdown()
    self:DestroyTimer()
    self.tipTimer = Timer.new(5, function (lastSeconds)
        lastSeconds = math.round(lastSeconds)
        if lastSeconds == 0 then
            self:DestroyTimer()
            self:PlayOn()
        end
    end)
end

--- 销毁计时器
function PenaltyShootOutNotify:DestroyTimer()
    if self.tipTimer ~= nil then
        self.tipTimer:Destroy()
        self.tipTimer = nil
    end
end

return PenaltyShootOutNotify