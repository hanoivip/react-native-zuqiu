local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local Version = require("emulator.version")

local PeakMatchDetailsItemView = class(unity.base)

function PeakMatchDetailsItemView:ctor()
    -- 查看比赛详情
    self.btnView = self.___ex.btnView
    -- 对手队长名字
    self.textEnemyCaptainName = self.___ex.textEnemyCaptainName
    -- 对手阵型
    self.textEnemyFormation = self.___ex.textEnemyFormation
    -- 对手认输
    self.imgEnemyGiveUp = self.___ex.imgEnemyGiveUp
    -- 对手头像
    self.enemyCardParent = self.___ex.enemyCardParent
    -- 阵型
    self.textOurFormation = self.___ex.textOurFormation
    -- 队长名字
    self.textOurCaptainName = self.___ex.textOurCaptainName
    -- 认输
    self.imgOurGiveUp = self.___ex.imgOurGiveUp
    -- 头像
    self.ourCardParent = self.___ex.ourCardParent
    -- 比分
    self.textScore = self.___ex.textScore
    -- 场次
    self.textMatchSession = self.___ex.textMatchSession
    self.imgEnemyDefultCaption = self.___ex.imgEnemyDefultCaption
    self.imgOurDefultCaption = self.___ex.imgOurDefultCaption
end

function PeakMatchDetailsItemView:start()
    self:BindButtonHandler()
end

function PeakMatchDetailsItemView:InitView(matchResultData)
    self.matchResultData = matchResultData
    self.textMatchSession.text = self.matchResultData.MatchSession
    self.textEnemyFormation.text = self.matchResultData.defender.formationID
    GameObjectHelper.FastSetActive(self.imgEnemyGiveUp.gameObject,self.matchResultData.defender.GiveUp)
    self.textOurFormation.text = self.matchResultData.attacker.formationID
    GameObjectHelper.FastSetActive(self.imgOurGiveUp.gameObject,self.matchResultData.attacker.GiveUp)
    self.textScore.text = self.matchResultData.Score
    self:CheckIsHaveVIdeo(self.matchResultData)
    self:AddCard(self.matchResultData.defender.captain,self.enemyCardParent,self.imgEnemyDefultCaption,self.textEnemyCaptainName)
    self:AddCard(self.matchResultData.attacker.captain,self.ourCardParent,self.imgOurDefultCaption,self.textOurCaptainName)

end

function PeakMatchDetailsItemView:AddCard (CID, cardParent,defultFace,textCaptainName)
    if not CID then 
        textCaptainName.text = ""
        return
    end
    GameObjectHelper.FastSetActive(defultFace,false)
    local playerCardStaticModel = StaticCardModel.new(CID)
    local cardInfo = {}
    cardInfo.card = {}
    table.insert(cardInfo.card, {id = CID, num = 0, lvl = 1, upgrade = 0})
    local rewardParams = {
        parentObj = cardParent,
        rewardData = cardInfo,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true,
        isHideLvl = true,
    }
    RewardDataCtrl.new(rewardParams)
    textCaptainName.text = playerCardStaticModel:GetName()
end

function  PeakMatchDetailsItemView:CheckIsHaveVIdeo(flag)
    local isVideoExpired = tonumber(flag.version) ~= tonumber(Version.version)
    isVideoExpired = isVideoExpired and flag.vid 
    --检测版本，暂时用vid
    GameObjectHelper.FastSetActive(self.btnView.gameObject, flag.vid)
end

function PeakMatchDetailsItemView:BindButtonHandler()
    self.btnView:regOnButtonClick(function()
        if self.onViewFightDetail then
            self.onViewFightDetail(self.matchResultData.vid)
        end
    end)
end

function PeakMatchDetailsItemView:InitFace()
    if self.onInitFace then
        self.onInitFace()
    end
end

return PeakMatchDetailsItemView