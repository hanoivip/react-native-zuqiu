local AdventureEvent = require("data.AdventureEvent")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local MatchDialog = class(unity.base)

function MatchDialog:ctor()
--------Start_Auto_Generate--------
    self.contentGo = self.___ex.contentGo
    self.scoreTxt = self.___ex.scoreTxt
    self.homeLogoImg = self.___ex.homeLogoImg
    self.visitLogoImg = self.___ex.visitLogoImg
    self.homeNameTxt = self.___ex.homeNameTxt
    self.visitNameTxt = self.___ex.visitNameTxt
    self.obtainPowerTxt = self.___ex.obtainPowerTxt
    self.imageImg = self.___ex.imageImg
    self.reciveTipTxt = self.___ex.reciveTipTxt
    self.tipsTxt = self.___ex.tipsTxt
    self.bottomGo = self.___ex.bottomGo
    self.confirmSpt = self.___ex.confirmSpt
--------End_Auto_Generate----------
    self.tipsGo = self.___ex.tipsGo
end

function MatchDialog:start()
    DialogAnimation.Appear(self.transform)
    self.confirmSpt:regOnButtonClick(function()
        self:Close()
    end)
end

function MatchDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
    if self.closeClick then
        self.closeClick()
    end
end

function MatchDialog:InitView(matchModel, greenswardBuildModel)
    self.matchModel = matchModel
    local playerScore, opponentScore = matchModel:GetScoreData()
    self.scoreTxt.text = tostring(playerScore) .. " : " .. tostring(opponentScore)
    local content = matchModel:GetRewardContent()
    self.reciveTipTxt.text = lang.trans("adventure_match_tips3")
    local hasReward = false
    if content then
        hasReward = true
        local num = 0
        local path = ""
        if content.fight then
            path = CurrencyImagePath.fight
            num = tonumber(content.fight)
        elseif content.morale then
            path = CurrencyImagePath.morale
            num = tonumber(content.morale)
        end
        self.imageImg.overrideSprite = res.LoadRes(path)
        self.reciveTipTxt.text = "x" .. tostring(num)
    end

    local playerTeamInfo = matchModel:GetPlayerTeamInfo()
    local opponentTeamInfo = matchModel:GetOpponentTeamInfo()
    if playerTeamInfo and opponentTeamInfo then
        TeamLogoCtrl.BuildTeamLogo(self.homeLogoImg, playerTeamInfo.logo)
        TeamLogoCtrl.BuildTeamLogo(self.visitLogoImg, opponentTeamInfo.logo)
        self.homeNameTxt.text = tostring(playerTeamInfo.teamName)
        self.visitNameTxt.text = tostring(opponentTeamInfo.teamName)
    end

    local hasPassTip = matchModel:HasAssistPassTip()
    local tips = ""
    if hasPassTip then
        local trumpBossModel = greenswardBuildModel:GetTrumpBossModel()
        local isOkayToHitBoss = trumpBossModel and trumpBossModel:IsOperable() or false
        tips = matchModel:GetAssistEnemyTip(isOkayToHitBoss)
    end
    self.tipsTxt.text = tips

    local enemyType = matchModel:GetEnemyType()
    local staticData = AdventureEvent[tostring(enemyType)] or {}
    local name = staticData.eventName or ""
    self.obtainPowerTxt.text = lang.trans("obtain_power", name)

    GameObjectHelper.FastSetActive(self.tipsGo.gameObject, hasPassTip)
    GameObjectHelper.FastSetActive(self.imageImg.gameObject, hasReward)
end

return MatchDialog
