local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LotteryMatchResult = require("ui.models.activity.LotteryMatchResult")
local LotteryMatchStatus = require("ui.models.activity.LotteryMatchStatus")
local LotteryStakeStatus = require("ui.models.activity.LotteryStakeStatus")
local LotteryModel = require("ui.models.activity.LotteryModel")

local LotteryBarView = class(unity.base)

function LotteryBarView:ctor()
    self.enabledVs = self.___ex.enabledVs
    self.enabledScores = self.___ex.enabledScores
    self.disabledVs = self.___ex.disabledVs
    self.disabledScores = self.___ex.disabledScores
    self.enabledLabel = self.___ex.enabledLabel
    self.enabledHomeScore = self.___ex.enabledHomeScore
    self.enabledAwayScore = self.___ex.enabledAwayScore
    self.disabledHomeScore = self.___ex.disabledHomeScore
    self.disabledAwayScore = self.___ex.disabledAwayScore
    self.badgeHomeLetter = self.___ex.badgeHomeLetter
    self.badgeHomeText = self.___ex.badgeHomeText
    self.badgeAwayLetter = self.___ex.badgeAwayLetter
    self.badgeAwayText = self.___ex.badgeAwayText
    self.desc = self.___ex.desc
    self.winRate = self.___ex.winRate
    self.winOdds = self.___ex.winOdds
    self.drawRate = self.___ex.drawRate
    self.drawOdds = self.___ex.drawOdds
    self.loseRate = self.___ex.loseRate
    self.enabledWinPercentage = self.___ex.enabledWinPercentage
    self.disabledWinPercentage = self.___ex.disabledWinPercentage
    self.losePercentage = self.___ex.losePercentage
    self.enabledPanel = self.___ex.enabledPanel
    self.disabledPanel = self.___ex.disabledPanel
    self.disabledMatchName = self.___ex.disabledMatchName
    self.winButton = self.___ex.winButton
    self.loseButton = self.___ex.loseButton
    self.badgeHomeIcon = self.___ex.badgeHomeIcon
    self.badgeAwayIcon = self.___ex.badgeAwayIcon
    self.loseOdds = self.___ex.loseOdds
    self.winOddsText = self.___ex.winOddsText
    self.drawOddsText = self.___ex.drawOddsText
    self.loseOddsText = self.___ex.loseOddsText
    self.drawButton = self.___ex.drawButton
    self.drawButtonText = self.___ex.drawButtonText
    self.winButtonText = self.___ex.winButtonText
    self.loseButtonText = self.___ex.loseButtonText
    self.drawPercentage = self.___ex.drawPercentage
    self.enabledMatchName = self.___ex.enabledMatchName
    self.canceled = self.___ex.canceled
end

function LotteryBarView:InitView(model)
    self.model = model
    local serverTime = model.serverTime

    local enabled = (model.matchStatus == LotteryMatchStatus.BeforeMatch)
    self.enabledLabel:SetActive(enabled)
    self.enabledPanel:SetActive(enabled)
    self.disabledPanel:SetActive(not enabled)
    self.enabledWinPercentage.gameObject:SetActive(enabled)
    self.disabledWinPercentage.gameObject:SetActive(not enabled)

    local enabledColor = Color(1, 232 / 255, 69 / 255, 1)
    local disabledColor = Color(215 / 255, 215 / 255, 215 / 255, 1)
    local color = enabled and enabledColor or disabledColor

    self.winOdds.color = color
    self.drawOdds.color = color
    self.loseOdds.color = color

    self.winOddsText.color = color
    self.drawOddsText.color = color
    self.loseOddsText.color = color

    enabled = (model.matchStatus ~= LotteryMatchStatus.Finished)
    self.enabledVs:SetActive(enabled)
    self.disabledVs:SetActive(enabled)
    self.enabledScores:SetActive(not enabled)
    self.disabledScores:SetActive(not enabled)

    -- name and badge
    self.badgeHomeText.text = model.homeTeam
    self.badgeAwayText.text = model.guestTeam
    self.enabledMatchName.text = model.cupName
    self.disabledMatchName.text = model.cupName

    local showCanceled = false
    if model.matchStatus == LotteryMatchStatus.BeforeMatch then
        local seconds = (model.stakeEndTime or 0) - serverTime
        local timeTable = string.convertSecondToTimeTable(seconds)
        if timeTable.hour > 0 then
            self.desc.text = lang.trans("lottery_hours_to_stake_end", timeTable.hour)
        else
            self.desc.text = lang.trans("lottery_minutes_to_stake_end", math.max(1, timeTable.minute))
        end
    elseif model.matchStatus == LotteryMatchStatus.InMatch then
        self.desc.text = lang.trans("lottery_in_match")
    elseif model.matchStatus == LotteryMatchStatus.Finished then
        -- assume a match takes 105 minutes
        local seconds = serverTime - model.beginTime - 105 * 60
        local timeTable = string.convertSecondToTimeTable(seconds)
        if timeTable.day > 0 then
            self.desc.text = lang.trans("lottery_days_after_match_end", timeTable.day)
        else
            self.desc.text = lang.trans("lottery_hours_after_match_end", timeTable.hour)
        end
    else
        self.desc.text = lang.trans("lottery_canceled")
        showCanceled = true
    end

    self.canceled:SetActive(showCanceled)

    -- score
    self.enabledHomeScore.text = tostring(model.homeScore or 0)
    self.enabledAwayScore.text = tostring(model.guestScore or 0)
    self.disabledHomeScore.text = tostring(model.homeScore or 0)
    self.disabledAwayScore.text = tostring(model.guestScore or 0)

    -- odds
    self.winOdds.text = string.format("%.2f", model.globalStakeInfo.odds[tostring(LotteryMatchResult.Win)])
    self.drawOdds.text = string.format("%.2f", model.globalStakeInfo.odds[tostring(LotteryMatchResult.Draw)])
    self.loseOdds.text = string.format("%.2f", model.globalStakeInfo.odds[tostring(LotteryMatchResult.Lose)])

    -- stake
    -- plus one to avoid 0%
    local winStake = model.globalStakeInfo.stake[tostring(LotteryMatchResult.Win)] + 1
    local drawStake = model.globalStakeInfo.stake[tostring(LotteryMatchResult.Draw)] + 1
    local loseStake = model.globalStakeInfo.stake[tostring(LotteryMatchResult.Lose)] + 1
    local totalStake = winStake + drawStake + loseStake

    local winStakeRate = math.floor(winStake / totalStake * 100)
    local drawStakeRate = math.floor(drawStake / totalStake * 100)
    local loseStakeRate = 100 - winStakeRate - drawStakeRate

    self.winRate.text = string.format(lang.transstr("lottery_percentage"), winStakeRate)
    self.drawRate.text = string.format(lang.transstr("lottery_percentage"), drawStakeRate)
    self.loseRate.text = string.format(lang.transstr("lottery_percentage"), loseStakeRate)

    local percentageWidth = self.drawPercentage.rect.width

    local winW = winStakeRate / 100 * percentageWidth
    local winX = -(percentageWidth - winW) / 2
    local loseW = (loseStakeRate / 100) * percentageWidth
    local loseX = (percentageWidth - loseW) / 2
    self:updatePosition(self.enabledWinPercentage, winX, winW)
    self:updatePosition(self.disabledWinPercentage, winX, winW)
    self:updatePosition(self.losePercentage, loseX, loseW)

    -- badges
    local homeBadge, awayBadge = LotteryModel.GetTeamBadge(model.matchId, model.homeTeam, model.guestTeam)

    self.badgeHomeIcon.overrideSprite = LotteryModel.GetBadgeIcon(homeBadge)
    self.badgeAwayIcon.overrideSprite = LotteryModel.GetBadgeIcon(awayBadge)

    self.badgeHomeLetter.text = pinyin.firstLetter(model.homeTeam)
    self.badgeAwayLetter.text = pinyin.firstLetter(model.guestTeam)

    local raise = (model.selfStakeInfo ~= nil) and (model.selfStakeInfo.stake[tostring(LotteryMatchResult.Win)] ~= nil)
    self.winButtonText.text = lang.trans(raise and "lottery_raise" or "lottery_betting")

    raise = model.selfStakeInfo ~= nil and model.selfStakeInfo.stake[tostring(LotteryMatchResult.Draw)] ~= nil
    self.drawButtonText.text = lang.trans(raise and "lottery_raise" or "lottery_betting")

    raise = model.selfStakeInfo ~= nil and model.selfStakeInfo.stake[tostring(LotteryMatchResult.Lose)] ~= nil
    self.loseButtonText.text = lang.trans(raise and "lottery_raise" or "lottery_betting")
end

function LotteryBarView:updatePosition(transform, x, width)
    transform.localPosition = Vector3(x, transform.localPosition.y, transform.localPosition.z)
    transform.sizeDelta = Vector2(width, transform.sizeDelta.y)
end

return LotteryBarView
