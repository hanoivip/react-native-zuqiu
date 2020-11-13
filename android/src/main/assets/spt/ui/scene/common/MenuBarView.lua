local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local MenuBarView = class(DynamicLoaded)

function MenuBarView:ctor()
    self.btnBall = self.___ex.btnBall
    self.moveArea = self.___ex.moveArea
    self.btnPlayers = self.___ex.btnPlayers
    self.btnFormation = self.___ex.btnFormation
    self.btnReward = self.___ex.btnReward
    -- ºìµã
    self.rewardRedPoint = self.___ex.rewardRedPoint
    self.playersRedPoint = self.___ex.playersRedPoint
end

function MenuBarView:InitView(playerInfoModel)
    
end

function MenuBarView:OnEnterScene()
    EventSystem.AddEvent("ReqEventModel_reward", self, self.UpdateRewardNum)
    self:SetPlayersRedPoint()
end

function MenuBarView:OnExitScene()
    EventSystem.RemoveEvent("ReqEventModel_reward", self, self.UpdateRewardNum)
end

function MenuBarView:SetPlayersRedPoint()
    if GuideManager.GuideIsOnGoing("main") then return end
    local isPlayersHasSign = false
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local cardList = playerCardsMapModel:GetCardList()
    for i, pcid in ipairs(cardList) do
        local cardModel = PlayerCardModel.new(pcid)
        cardModel:InitEquipsAndSkills()
        local hasSign = cardModel:HasSign()
        if hasSign then 
            isPlayersHasSign = true
            break
        end
    end
    GameObjectHelper.FastSetActive(self.playersRedPoint, isPlayersHasSign)
end

function MenuBarView:UpdateRewardNum()
    if GuideManager.GuideIsOnGoing("main") then return end
    local rewardNum = ReqEventModel.GetInfo("reward")
    local isReward = tonumber(rewardNum) > 0 and true or false
    GameObjectHelper.FastSetActive(self.rewardRedPoint, isReward)
end

function MenuBarView:start()
    self.btnPlayers:regOnButtonClick(function()
        self:OnBtnPlayers()
    end)
    self.btnFormation:regOnButtonClick(function()
        self:OnBtnFormation()
    end)
    self.btnReward:regOnButtonClick(function()
        self:OnBtnReward()
    end)
    self.btnBall:regOnButtonClick(function()
        self:OnBtnBall()
    end)

    self:UpdateRewardNum()
end

function MenuBarView:OnBtnBall()
    if self.clickBall then 
        self.clickBall()
    end
end

function MenuBarView:OnBtnPlayers()
    if self.clickPlayers then 
        self.clickPlayers()
    end
end

function MenuBarView:OnBtnFormation()
    if self.clickFormation then 
        self.clickFormation()
    end
end

function MenuBarView:OnBtnReward()
    if self.clickReward then 
        self.clickReward()
    end
end

return MenuBarView
