local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local Version = require("emulator.version")

local TransportMatchDetailsItemView = class(unity.base)

function TransportMatchDetailsItemView:ctor()
    self.enemyNameTxt = self.___ex.enemyNameTxt
    self.enemyLogoImg = self.___ex.enemyLogoImg
    self.ourNameTxt = self.___ex.ourNameTxt
    self.imgOurGiveUp = self.___ex.imgOurGiveUp
    self.ourLogoImg = self.___ex.ourLogoImg
    self.scoreTxt = self.___ex.scoreTxt
    self.order = self.___ex.order
end

function TransportMatchDetailsItemView:InitView(matchResultData)
    self.enemyNameTxt.text = matchResultData.enemyName
    self.ourNameTxt.text = matchResultData.ourName
    self.scoreTxt.text = matchResultData.score
    if self.order then
        self.order.text = matchResultData.order
    end
    self:InitTeamLogo(self.enemyLogoImg, matchResultData.enemyLogo)
    self:InitTeamLogo(self.ourLogoImg, matchResultData.ourLogo)
end

function TransportMatchDetailsItemView:InitTeamLogo(imgLogo ,logoId)
    if self.onInitTeamLogo then
        self.onInitTeamLogo(imgLogo , logoId)
    end
end

return TransportMatchDetailsItemView