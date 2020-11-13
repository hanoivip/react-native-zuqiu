local RankModel = require("ui.models.rank.RankModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerDetailModel = require("ui.models.playerDetail.PlayerDetailModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local RankMainCtrl = class(BaseCtrl)
RankMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Rank/Prefab/RankBoard.prefab"

local SelectType = {
    People = 1,
    Guild = 2,
    Card = 3
}
-- 意思就是上边的
local NormalIndex = {
    1,2,3,3,3,3,1,1
}

function RankMainCtrl:Init()
    self.view.onBack = function() self:OnBack() end
    self.view.clickView = function(pid, sid, pcid, gid, cid, normalizedPos) self:OnViewClick(pid, sid, pcid, gid, cid, normalizedPos) end
    self.view.clickTab = function(index) self.mIndex = index; self:OnTabClick(index) end
    self.view.clickServer = function(key) self:OnClickServer(key) end
end

function RankMainCtrl:Refresh(rankModel, guildData, normalizedPos)
    RankMainCtrl.super.Refresh(self)
    self:InitView(rankModel, guildData, normalizedPos)
end

function RankMainCtrl:GetStatusData()
    return self.rankModel, self.guildData, self.normalizedPos
end

function RankMainCtrl:AheadRequest()
    local respone = req.guildIndex()
    if api.success(respone) then
        self.guildData = respone.val
    end
end

function RankMainCtrl:InitView(rankModel, guildData, normalizedPos)
    self.playerInfoModel = PlayerInfoModel.new()
    self.view:Reset()
    if rankModel then 
        self.rankModel = rankModel
        self.guildData = guildData
        self.normalizedPos = normalizedPos
        local selectMenu = self.rankModel:GetSelectMenu()
        self.view:InitView(self.rankModel, self.playerInfoModel, self.guildData)
        self.view:ClickRankTab(selectMenu)
    else
        self.rankModel = RankModel.new()
        clr.coroutine(function()
            local respone = req.multiRankInfo()
            if api.success(respone) then
                local data = respone.val
                self.rankModel:InitWithProtocol(data)
                self.view:InitView(self.rankModel, self.playerInfoModel, self.guildData)
                self.view:ClickRankTab(self.rankModel:GetSelectMenu())
            end
        end)
    end
    clr.coroutine(function()
        --假壳
        local response = req.friendsDetail(self.playerInfoModel:GetID(), self.playerInfoModel:GetSID())
        if api.success(response) then
            self.playerDetailModel = PlayerDetailModel.new()
            self.playerDetailModel:InitWithProtocol(response.val)
        end
    end)
end

function RankMainCtrl:OnBack()
    res.PopScene()
end

function RankMainCtrl:OnViewClick(pid, sid, pcid, gid, cid, normalizedPos)
    local selectDetail = NormalIndex[tonumber(self.mIndex)]
    if selectDetail == SelectType.People then
        PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
    elseif selectDetail == SelectType.Guild then
        clr.coroutine(function()
            local respone = req.GuildDetail(gid)
            if api.success(respone) then
                local data = respone.val
                if data.base.isExsit == true then
                    res.PushDialog("ui.controllers.guild.GuildDetailCtrl", data.base)
                end
            end
        end)
    elseif selectDetail == SelectType.Card then
       clr.coroutine(function()
            local response = req.friendsCardDetail(pid, sid, pcid)
            if api.success(response) then
                local data = response.val
                if data.cardInfo then
                    local cids = data.cidChemical
                    local otherPlayerTeamsModel = self.playerDetailModel:GetOtherPlayerTeamsModel()
                    local playerCardModelsMap = self.playerDetailModel:GetOtherPlayerCardsMapModel()
                    playerCardModelsMap.data[tostring(pcid)] = data.cardInfo
                    local currentModel = CardBuilder.GetOtherCardModel(pcid, cids, playerCardModelsMap, otherPlayerTeamsModel)
                    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {pcid}, 1, currentModel)
                else
                    DialogManager.ShowAlertPop(lang.trans("tips"),lang.trans("menu_peak_rank_card_hide"),3)
                end
            end
        end)
        self.normalizedPos = normalizedPos
    end
end

function RankMainCtrl:OnTabClick(index)
    self.rankModel:SetSelectMenu(index)
    self.view:RefreshScrollView(self.normalizedPos)
    self.normalizedPos = nil
end

function RankMainCtrl:OnClickServer(key)
    self.rankModel:SetServerState(key)
    self.view:RefreshScrollView()
end

return RankMainCtrl