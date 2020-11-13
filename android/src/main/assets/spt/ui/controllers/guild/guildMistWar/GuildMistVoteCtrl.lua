local BaseCtrl = require("ui.controllers.BaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local GuildMistVoteCtrl = class(BaseCtrl, "MistSelfDetailBattleCtrl")
local GuildMistVoteModel = require("ui.models.guild.guildMistWar.GuildMistVoteModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

GuildMistVoteCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistVote.prefab"

function GuildMistVoteCtrl:AheadRequest()
    local response = req.guildGetDonationInfo()
    if api.success(response) then
        local data =response.val
        self.model = GuildMistVoteModel.new()
        self.model:InitWithProtocol(data)
    end
end

function GuildMistVoteCtrl:Init(guildHomeModel)
    self.guildHomeModel = guildHomeModel
    self.view.applyVote = function(index) self:OnApply(index) end
    self.playerInfoModel = PlayerInfoModel.new()
end

function GuildMistVoteCtrl:GetStatusData()
    return self.guildHomeModel
end

function GuildMistVoteCtrl:Refresh()
    self.view:InitView(self.model)
end

function GuildMistVoteCtrl:OnApply(index)
    local remainCount = self.model:GetRemainCount()
    if remainCount <= 0 then
        DialogManager.ShowToastByLang("mist_vote_limit")
        return
    end
    local isCumulativeDayFull = self.model:IsCumulativeDayFull()
    if isCumulativeDayFull then
        local fullTitle = lang.trans("tips")
        local fullTip = lang.trans("mist_vote_full")
        DialogManager.ShowConfirmPop(fullTitle, fullTip, function()
            self:ApplyConfirmPop(index)
        end)
    else
        self:ApplyConfirmPop(index)
    end
end

function GuildMistVoteCtrl:ApplyConfirmPop(index)
    local voteData = self.model:GetVoteDataByIndex(index)
    local priceType = voteData.priceType
    local price = voteData.price
    local priceStr = string.formatNumWithUnit(price)
    local priceTypeStr = lang.transstr(CurrencyNameMap[priceType])
    local content = lang.trans("mist_vote_confirm", priceTypeStr, priceStr)
    local title = lang.trans("tips")
    DialogManager.ShowConfirmPop(title, content, function()
        if priceType == CurrencyType.Diamond or priceType == CurrencyType.BlackDiamond then
            CostDiamondHelper.CostCurrency(price, self.view, function()
                self:Apply(index)
            end, priceType)
        else
            self:Apply(index)
        end
    end)
end

function GuildMistVoteCtrl:Apply(index)
    self.view:coroutine(function ()
        local response = req.guildDonation(index)
        if api.success(response) then
            local data = response.val
            self.model:RefreshData(data)
            self.playerInfoModel:CostDetail(data.cost)
            self.guildHomeModel:RefreshCumulativeDay(data.cumulativeDay)
            CongratulationsPageCtrl.new(data.reward)
            self.view:InitView(self.model)
        end
    end)
end

return GuildMistVoteCtrl
