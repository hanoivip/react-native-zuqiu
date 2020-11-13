local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local WaitForSeconds = UnityEngine.WaitForSeconds

local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local CommonConstants = require("ui.common.CommonConstants")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchConstants = require("ui.scene.match.MatchConstants")
local QuestTeam = require("data.QuestTeam")

local TeamScore = class(unity.base)

local DisplaySpecialTime = {
    15,
    30,
    46,
    60,
    75,    
}
local DisplayBoardWidth = 683
local DisplayScrollWidth = 623
function TeamScore:ctor()
    self.rectTrans = self.___ex.rectTrans
    -- 主队名称
    self.homeName = self.___ex.homeName
    -- 客队名称
    self.awayName = self.___ex.awayName
    -- 比赛时间
    self.time = self.___ex.time
    -- 比赛分数
    self.score = self.___ex.score
    -- 加时条
    self.addTimeBar = self.___ex.addTimeBar
    -- 加时时间
    self.addTimeText = self.___ex.addTimeText
    self.stayTime = 2
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 光效
    self.lightEffect = self.___ex.lightEffect
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamLogo = self.___ex.awayTeamLogo
    self.specialObj = self.___ex.specialObj
    self.specialInfo = self.___ex.specialInfo
    self.specialRect = self.___ex.specialRect
    self.matchType = nil
    self.isDisplaySpecialInfo = false
end

function TeamScore:start()
    local matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    self:BuildTeam(self.homeTeamLogo, playerTeamData)
    self:BuildTeam(self.awayTeamLogo, opponentTeamData)
    self:InitSpecialInfo(matchInfoModel:GetMatchType())
end

function TeamScore:InitChildren(leftTeam, rightTeam, score, gameTime)
    self:InitTeamScore(leftTeam, rightTeam, score)
    self:InitTime(gameTime)
end

function TeamScore:BuildTeam(teamLogo, teamData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, teamData.logo)
end

function TeamScore:InitTeamScore(leftTeam, rightTeam, score)
    if leftTeam then
        self.homeName.text = leftTeam
    end

    if rightTeam then
        self.awayName.text = rightTeam
    end

    self.score.text = score
end

function TeamScore:InitTime(gameTime)
    self.time.text = gameTime or "00:00"
end

function TeamScore:SetMatchAddTime(overtime, deltaTime)
    if overtime then
        self.addTimeBar:SetActive(true)
        self.addTimeText.text = "+" .. overtime
    end
end

function TeamScore:HideMatchAddTime()
    self.addTimeBar:SetActive(false)
end

function TeamScore:UpdateMatchTime(gameTime)
    local minute = string.sub(gameTime, 1, 2)
    if minute == "87" then
        EventSystem.SendEvent("CommentaryManager.InEndThreeMinute", true)
    end
    self.time.text = gameTime
    -- display special information
    for i, disTime in ipairs(DisplaySpecialTime) do
        if not self.isDisplaySpecialInfo and minute == tostring(disTime) then
            self:DisplaySpecialInfo()
            self.isDisplaySpecialInfo = true
        end
    end
end

function TeamScore:InitSpecialInfo(matchType)
    self.matchType = matchType
    if self.matchType == MatchConstants.MatchType.QUEST then
        self.specialObj:SetActive(true)
		local questData = QuestTeam[cache.getQuestId()] or {}
        self.specialInfo.text = questData.showInfo or ""
        self:coroutine(function ()
            coroutine.yield(UnityEngine.WaitForEndOfFrame())
            if self.specialRect.rect.width > DisplayScrollWidth then
                self.initRectPosition = self.specialRect.localPosition + Vector3(60, 0, 0)
            else
                self.specialRect.localPosition = Vector3(self.specialRect.localPosition.x + (DisplayBoardWidth - self.specialRect.rect.width) / 2, 0, 0)                
            end
            self:DisplaySpecialInfo()
        end)
    end
end

function TeamScore:DisplaySpecialInfo()
    if self.matchType == MatchConstants.MatchType.QUEST then
        self.specialObj:SetActive(true)
        if self.specialRect.rect.width > DisplayScrollWidth then
            local tweener = ShortcutExtensions.DOAnchorPosX(self.specialRect, DisplayScrollWidth - self.specialRect.rect.width, 5, false)
            TweenSettingsExtensions.SetEase(tweener, Ease.Linear)
            TweenSettingsExtensions.OnComplete(tweener, function ()
                self.specialRect.localPosition = self.initRectPosition
                self.specialObj:SetActive(false)
                self.isDisplaySpecialInfo = false
            end)
        else
            self:coroutine(function ()
                coroutine.yield(WaitForSeconds(2))
                self.specialObj:SetActive(false)
                self.isDisplaySpecialInfo = false
            end)
        end
    end
end

function TeamScore:MoveOutIn()
    self.animator:Play("MoveOut")
    self.lightEffect:SetActive(false)
end

function TeamScore:PlayMoveInAnim()
    self.animator:Play("MoveIn")
    self.lightEffect:SetActive(true)
end

function TeamScore:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:coroutine(function ()
            coroutine.yield(WaitForSeconds(self.stayTime))
            self:PlayMoveInAnim()
        end)
    end
end

return TeamScore
