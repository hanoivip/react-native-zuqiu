local GameObjectHelper = require("ui.common.GameObjectHelper")
local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local PlayerNewfunctionModel = require("ui.models.PlayerNewFunctionModel") 
local EventSystem = require("EventSystem")
local HomeMainTheme = require("ui.scene.home.HomeMainTheme")

local HomeMenuBar = class(DynamicLoaded, "HomeMenuBar")

local RedPointKeys = { Reward = 1 }
function HomeMenuBar:ctor()
    self.btnPlayers = self.___ex.btnPlayers
    self.btnItem = self.___ex.btnItem
    self.btnFormation = self.___ex.btnFormation
    self.btnReward = self.___ex.btnReward

    self.normalRewardIcon = self.___ex.normalRewardIcon
    self.plusRewardIcon = self.___ex.plusRewardIcon
    -- 红点
    self.rewardRedPoint = self.___ex.rewardRedPoint
    self.playersRedPoint = self.___ex.playersRedPoint

    self.menuBar = self.___ex.menuBar

    self.totalRedPoint = {}
    self.playerInfoModel = nil
    --新功能进入红点
    self.transferRedPoint = self.___ex.transferRedPoint
end

function HomeMenuBar:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
end

function HomeMenuBar:start()
    self:UpdateRewardNum()
    self:RegModelHandler()
    self:UpdateSuitSkin()
end

function HomeMenuBar:UpdateSuitSkin()
    local playerInfoModel = PlayerInfoModel.new()
    local skinKey = playerInfoModel:GetSpecificTeam() or HomeMainTheme.Default_Skin_Key
    local themeConfig = HomeMainTheme[skinKey]
    if themeConfig == nil then themeConfig = HomeMainTheme.Classic end

    self.menuBar.overrideSprite = res.LoadRes(themeConfig.menuPath)
end

function HomeMenuBar:EnterScene()
    EventSystem.AddEvent("ReqEventModel_reward", self, self.UpdateRewardNum)
    EventSystem.AddEvent("UserLevelUp", self, self.SetFunctionOpen)
    EventSystem.AddEvent("UpdateNewFunctionState", self, self.UpdateNewFunctionState)
    self:SetPlayersRedPoint()
    self:SetFunctionOpen()
    self:CheckNewFunctionOpend(PlayerNewfunctionModel.new())
end

function HomeMenuBar:ExitScene()
    EventSystem.RemoveEvent("ReqEventModel_reward", self, self.UpdateRewardNum)
    EventSystem.RemoveEvent("UserLevelUp", self, self.SetFunctionOpen)
    EventSystem.RemoveEvent("UpdateNewFunctionState", self, self.UpdateNewFunctionState)
end

function HomeMenuBar:RegModelHandler()
    EventSystem.AddEvent("UpdateSuitSkin", self, self.UpdateSuitSkin)
end

function HomeMenuBar:RemoveModelHandler()
    EventSystem.RemoveEvent("UpdateSuitSkin", self, self.UpdateSuitSkin)
end

function HomeMenuBar:onDestroy()
    self:RemoveModelHandler()
end

function HomeMenuBar:SetPlayersRedPoint()
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

function HomeMenuBar:SetTransferRedPoint(isShow)
    GameObjectHelper.FastSetActive(self.transferRedPoint, isShow)
end

function HomeMenuBar:CheckNewFunctionOpend(playerNewFunctionModel)
    if playerNewFunctionModel:IsOpend() then
        if playerNewFunctionModel:CheckFirstEnterScene("transfer") then
            GameObjectHelper.FastSetActive(self.transferRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.transferRedPoint, false)
        end
    else
        GameObjectHelper.FastSetActive(self.transferRedPoint, false)
    end
end

function HomeMenuBar:UpdateRewardNum()
    if GuideManager.GuideIsOnGoing("main") then return end
    local rewardNum = ReqEventModel.GetInfo("reward")
    local isReward = tonumber(rewardNum) > 0 and true or false
    GameObjectHelper.FastSetActive(self.rewardRedPoint, isReward)
    self.totalRedPoint[RedPointKeys.Reward] = isReward
end

function HomeMenuBar:SetFunctionOpen()
    local level = self.playerInfoModel:GetLevel()
    GameObjectHelper.FastSetActive(self.btnItem.gameObject, level >= 8)
end

function HomeMenuBar:UpdateNewFunctionState(name, isShow)
    if name == "transfer" then
        GameObjectHelper.FastSetActive(self.transferRedPoint, isShow)
    end
end

return HomeMenuBar
