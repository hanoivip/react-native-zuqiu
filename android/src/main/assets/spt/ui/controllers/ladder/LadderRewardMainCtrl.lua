local LadderRankCurrentSeasonCtrl = require("ui.controllers.ladder.LadderRankCurrentSeasonCtrl")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local LadderRewardDetailCtrl = require("ui.controllers.ladder.LadderRewardDetailCtrl")
local ItemModel = require("ui.models.cardDetail.ItemModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local LadderRewardMainCtrl = class(BaseCtrl)

LadderRewardMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardBoard.prefab"

function LadderRewardMainCtrl:Init(ladderModel)
    self.ladderModel = ladderModel
    self.ladderRankCurrentSeasonCtrl = LadderRankCurrentSeasonCtrl.new(self.view:GetCurrentSeasonRankBoard())
    self.view.onBack = function() self:OnBack() end
    self.view.onViewCardDetail = function() self:OnViewCardDetail() end
    self.view.onRewardDetail = function() self:OnRewardDetail() end
    self.view.onArrowClick = function() self:OnArrowClick() end
    self.rankIndex = 1
end

function LadderRewardMainCtrl:Refresh()
    LadderRewardMainCtrl.super.Refresh(self)
    clr.coroutine(function()
        local respone = req.ladderSeasonReward()
        if api.success(respone) then
            local data = respone.val
            if data.rank then
                self.ladderModel:InitCurRankDataList(data.rank)
            end
            self.ladderModel:InitMySeasonRankInfo(data.self)
            if data.seasonCd then
                self.ladderModel:InitCurSeasonCd(data.seasonCd)
            end
            if data.seasonName then
                self.ladderModel:SetCurSeasonName(data.seasonName)
            end
            if data.topCard then
                self.ladderModel:SetRewardCardCid(data.topCard)
            end
            if data.seasonReward then
                self.ladderModel:SetSeasonRewardData(data.seasonReward)
            end
            self:InitView()
            self.ladderRankCurrentSeasonCtrl:InitView(self.ladderModel)
        end
    end)
end

function LadderRewardMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function LadderRewardMainCtrl:GetStatusData()
    return self.ladderModel, self.rankIndex
end

function LadderRewardMainCtrl:InitView()
    self.view:InitView(self.ladderModel)
    self:ShowReward(self.rankIndex)
end

local ShowTopCount = 3 -- 显示指定前几名球员
function LadderRewardMainCtrl:OnViewCardDetail()
    if self.showCardCid then
        local currentModel = CardBuilder.GetBaseCardModel(self.showCardCid)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {self.showCardCid}, 1, currentModel)
    end
end

function LadderRewardMainCtrl:OnRewardDetail()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRewardDetailBoard.prefab", "camera", true, true)
    local ladderRewardDetailCtrl = LadderRewardDetailCtrl.new(dialogcomp.contentcomp)
    ladderRewardDetailCtrl:InitView(self.ladderModel)
end

function LadderRewardMainCtrl:ShowReward(rankIndex)
    local rewardData = self.ladderModel:GetAppointSeasonRewardByRankIndex(rankIndex)
    local value = rewardData.value
    if rewardData.card then
        local cid = value.id
        self.showCardCid = cid
        local playerCardModel = StaticCardModel.new(cid)
        self.view:InitPlayerCard(playerCardModel, rankIndex)
    elseif rewardData.cardPiece then
        self.showCardCid = nil
        local cid = value.id
        local cardPieceModel = CardPieceModel.new()
        local newData = {cid = cid}
        cardPieceModel:InitWithCache(newData)
        self.view:InitCardPiece(cardPieceModel, rankIndex)
    elseif rewardData.item then
        self.showCardCid = nil
        local itemModel = ItemModel.new()
        local newItemData = {id = value.id, add = value.num}
        itemModel:InitWithCache(newItemData)
        self.view:InitItem(itemModel, rankIndex)
    end
end

function LadderRewardMainCtrl:OnArrowClick()
    self.rankIndex = self.rankIndex + 1
    if self.rankIndex > ShowTopCount then
        self.rankIndex = 1
    end
    self:ShowReward(self.rankIndex)
end

function LadderRewardMainCtrl:OnBack()
    res.PopScene()
end

return LadderRewardMainCtrl
