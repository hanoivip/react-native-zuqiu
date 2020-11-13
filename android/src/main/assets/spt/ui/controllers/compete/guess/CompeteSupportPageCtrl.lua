local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local PlayerDetailModel = require("ui.models.playerDetail.PlayerDetailModel")
local CompeteSupportPageModel = require("ui.models.compete.guess.CompeteSupportPageModel")
local CompeteInfoBarCtrl = require("ui.controllers.common.CompeteInfoBarCtrl")
local CardBuilder = require("ui.common.card.CardBuilder")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local CompeteSupportPageCtrl = class(BaseCtrl, "CompeteSupportPageCtrl")

CompeteSupportPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteSupportPage.prefab"

function CompeteSupportPageCtrl:AheadRequest(playerData, matchType, combatIndex, stageReward)
    local pid = playerData.pid
    local sid = playerData.sid
    if self.view then
        self.view:ShowDisplayArea(false)
    end
    -- 网络请求中的matchType不是此处定义的matchType
    local response = req.competeFormationDetail(pid, sid)
    if api.success(response) then
        local data = response.val
        if not self.competeSupportPageModel then
            self.competeSupportPageModel = CompeteSupportPageModel.new()
        end
        playerData.lvl = data.player.lvl
        self.competeSupportPageModel:InitWithParentScene(playerData, matchType, combatIndex, stageReward)
        if type(data) == "table" and next(data) then
            self.playerDetailModel = PlayerDetailModel.new()
            self.playerDetailModel:InitWithProtocol(data)  --实际只用到data.card, data.team
            self.otherPlayerTeamsModel = OtherPlayerTeamsModel.new()
        end
    end
end

function CompeteSupportPageCtrl:Init(playerData, matchType, combatIndex, stageReward)
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = CompeteInfoBarCtrl.new(child, self)
    end)

    self.view.onBtnSupport = function() self:OnBtnSupport() end
    self.view.onRewardItemClick = function(itemData) self:OnRewardItemClick(itemData) end
    self.view.onCardClick = function(pcid) self:OnCardClick(pcid) end
end

function CompeteSupportPageCtrl:Refresh(playerData, matchType, combatIndex, stageReward)
    CompeteSupportPageCtrl.super.Refresh(self)
    self.view:ShowDisplayArea(true)
    self.view:InitView(self.competeSupportPageModel, self.otherPlayerTeamsModel, self.playerDetailModel)
end

function CompeteSupportPageCtrl:GetStatusData()
    return self.competeSupportPageModel:GetStatusData()
end

function CompeteSupportPageCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteSupportPageCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CompeteSupportPageCtrl:OnBtnSupport()
    local matchType = self.competeSupportPageModel:GetMatchType()
    local guessStage = self.competeSupportPageModel:GetCurrStage()
    local mConsume = self.competeSupportPageModel:GetRewards()[guessStage].mConsume
    local combatIndex = self.competeSupportPageModel:GetCombatIndex()
    local guessPlayer = self.competeSupportPageModel:GetGuessPlayer()

    local playerInfoModel = require("ui.models.PlayerInfoModel").new()
    local currMoney = playerInfoModel:GetMoney()
    if currMoney < mConsume then
        DialogManager.ShowToastByLang("goldCoinNotEnough")
        return
    end

    local confirmCallback = function()
        self.view:coroutine(function()
            local response = req.competeGuess(matchType, guessStage, combatIndex, guessPlayer)
            if api.success(response) then
                local data = response.val
                self.competeSupportPageModel:UpdateAfterGuess(data)
                res.PopScene()
            end
        end)
    end

    local title = lang.transstr("compete_guess") -- 争霸赛竞猜
    local msg = lang.transstr("compete_guess_guess_confirm", string.formatNumWithUnit(mConsume))
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

-- 点击奖励物品
function CompeteSupportPageCtrl:OnRewardItemClick(itemData)
    local oldIdx = self.competeSupportPageModel:GetCurrChoosedReward()
    local newIdx = itemData.idx
    if newIdx ~= oldIdx then
        -- 取消旧的选择，选择新的
        self.competeSupportPageModel:ChangeChoosedReward(newIdx)
        -- 更新列表显示
        self.view.rewardScroll:UpdateItem(oldIdx, self.competeSupportPageModel:GetRewards()[oldIdx])
        self.view.rewardScroll:UpdateItem(newIdx, self.competeSupportPageModel:GetRewards()[newIdx])
    end
    res.PushDialog("ui.controllers.compete.guess.CompeteGuessStageRewardCtrl", itemData, true)
end

-- 点击球员
function CompeteSupportPageCtrl:OnCardClick(pcid)
    local cids = self.playerDetailModel:GetChemicalCids()
    local otherPlayerTeamsModel = self.playerDetailModel:GetOtherPlayerTeamsModel()
    local playerCardModelsMap = self.playerDetailModel:GetOtherPlayerCardsMapModel()
    local otherLegendCardsMapModel = self.playerDetailModel:GetOtherPlayerLegendCardModel()
    local currentModel = CardBuilder.GetOtherCardModel(pcid, cids, playerCardModelsMap, otherPlayerTeamsModel, otherLegendCardsMapModel)
    local pcidList = {}
    local tempIndex = 1
    local mIndex = nil
    for k,v in pairs(otherPlayerTeamsModel:GetInitPlayersData()) do
        table.insert(pcidList, v)
        if tostring(v) == tostring(pcid) then
            mIndex = tempIndex
        end
        tempIndex = tempIndex + 1
    end
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", mIndex and pcidList or {pcid}, mIndex and mIndex or 1, currentModel)
end

return CompeteSupportPageCtrl
