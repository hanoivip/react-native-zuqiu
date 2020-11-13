local BaseCtrl = require("ui.controllers.BaseCtrl")
local TransferMarketModel = require("ui.models.transferMarket.TransferMarketModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local FormationType = require("ui.common.enum.FormationType")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CardBuilder = require("ui.common.card.CardBuilder")
local CustomEvent = require("ui.common.CustomEvent")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CardSymbolModel = require("ui.models.cardDetail.CardSymbolModel")
local CustomTagModel = require("ui.models.cardDetail.CustomTagModel")

local TransferMarketCtrl = class(BaseCtrl)

TransferMarketCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/TransferMarket/TransferMarketCanvas.prefab"

function TransferMarketCtrl:AheadRequest()
    local respone = req.transferInfo()
    if api.success(respone) then
        local data = respone.val
        self.transferMarketModel = TransferMarketModel.new()
        self.transferMarketModel:InitWithProtocol(data)
    end
end

function TransferMarketCtrl:Init()
    self.cardSymbolModel = CardSymbolModel.new()
    self.cardSymbolModel:InitAboutOtherFlag(true, true, true)

    self.view.onRefresh = function() self:OnRefresh() end
    self.view.onPlayerSet = function() self:OnPlayerSet() end
    self.view.updateCacheDataCallBack = function() self:UpdateCacheDataCallBack() end

    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:PlayLeaveAnimation()
            self:PlayTransferPlayersLeaveAnimation()
        end)
        self.view:RegOnLeave(function()
            res.PopScene()
        end)
    end)
end

function TransferMarketCtrl:Refresh()
    TransferMarketCtrl.super.Refresh(self)
    self:InitView()
end

function TransferMarketCtrl:GetStatusData()
end

function TransferMarketCtrl:OnEnterScene()
    self.view:EnterScene()
end

function TransferMarketCtrl:OnExitScene()
    self.view:ExitScene()
end

function TransferMarketCtrl:InitView()
    self.view:InitView(self.transferMarketModel)

    -- 卡牌
    self.transferMarketPlayerViewMap = { }
    self.playerLetterInsidePlayerModel = PlayerLetterInsidePlayerModel.new()
    self.isHasLetterCard = false
    self.playerCardMap = { }
    self.view:ClearPlayerObject()
    local playerList = self.transferMarketModel:GetPlayerList()
    self.oldPlayerNum = #playerList
    self.customTagModel = CustomTagModel.new()
    for i, playerData in ipairs(playerList) do
        local playerCardModel = StaticCardModel.new(playerData.cid)
        local playerCardValue = self.transferMarketModel:GetPlayerCardPrice(playerData.pos)
        local isHave = PlayerCardsMapModel.new():IsExistCardID(playerData.cid)
        -- 当信件需要并且玩家还未拥有时提示
        if self.playerLetterInsidePlayerModel:IsBelongToLetterCard(playerData.cid) and not isHave then
            self.isHasLetterCard = true
        end
        local transferMarketPlayerObject, transferMarketPlayerView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/TransferMarket/TransferPlayer.prefab")
        self.view:AddPlayerObject(transferMarketPlayerObject)
        local flagData = self.cardSymbolModel:GetShowSymbolData(playerList[i].cid)
        transferMarketPlayerView:InitView(playerData.pos, self.transferMarketModel, playerCardModel, flagData, self.customTagModel)
        transferMarketPlayerView.onBuy = function(pos) self:OnBuy(pos, self.transferMarketModel:GetPlayerCardPrice(pos), callBackFunc) end
        transferMarketPlayerView.onClickCard = function(pos) self:OnClickCard(pos) end
        self.transferMarketPlayerViewMap[i] = transferMarketPlayerView

        local playerCardObject, playerCardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        transferMarketPlayerView:AddPlayerCard(playerCardObject)
        playerCardView:InitView(playerCardModel)
        playerCardView:IsShowName(false)
        self.playerCardMap[i] = { view = playerCardView, model = playerCardModel }
    end
    for i = #playerList + 1, 15 do
        local transferMarketPlayerObjectExtraLocked, transferMarketPlayerViewExtraLocked = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/TransferMarket/TransferPlayer.prefab")
        self.view:AddPlayerObject(transferMarketPlayerObjectExtraLocked)
        self.transferMarketPlayerViewMap[i] = transferMarketPlayerViewExtraLocked
        transferMarketPlayerViewExtraLocked:InitView(i, nil, nil)
    end
    
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function TransferMarketCtrl:OnBuy(pos, value, callBackFunc)
    if value > self.playerInfoModel:GetMoney() then 
        self:NotEnoughEuroMessageBox()
    else
        local title = lang.trans("transferMarket_buyPlayerTitle")
        local msg = lang.trans("transferMarket_buyPlayerMsg", string.formatNumWithUnit(self.transferMarketModel:GetPlayerCardPrice(pos)))
        DialogManager.ShowConfirmPop(title, msg, function() self:BuyPlayer(pos, callBackFunc) end)
    end
end

function TransferMarketCtrl:NotEnoughEuroMessageBox()
    local content = { }
    content.title = lang.trans("tips") 
    content.content = lang.trans("transfer_market_euro") 
    content.button1Text = lang.trans("goto")
    content.onButton1Clicked = function()
        res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM)   
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/GeneralBox.prefab',"camera", true, true)
    dialogcomp.contentcomp:initData(content)   
end

function TransferMarketCtrl:BuyPlayer(pos, callBackFunc)
    clr.coroutine(function()
        local signPlayerPos = {}
        signPlayerPos[1] = pos - 1
        local respone = req.transferSign(signPlayerPos)
        if api.success(respone) then
            local data = respone.val
            if next(data) then
                CongratulationsPageCtrl.new(data.contents)
                self.transferMarketModel:InitWithProtocol(data)
                self.transferMarketModel:UpdateCacheData()

                if type(callBackFunc) == "function" then
                    callBackFunc()
                end

                -- 更新花费，更新获奖数据
                if data.cost and data.cost.type == "m" then
                    self.playerInfoModel:SetMoney(data.cost.curr_num)
                    CustomEvent.ConsumeMoney("1", data.cost.num)
                    luaevt.trig("HoolaiBISendCounterRes", "inflow", 6, data.cost.num)
                end
            end
        end
    end)
end

function TransferMarketCtrl:OnRefresh()
    if self.isHasLetterCard == true then
        local content = lang.trans("transferMarket_letter_1")
        DialogManager.ShowConfirmPop(lang.trans("tips"), content, function ()
            self:RefreshData()
        end)
    else
        self:RefreshData()
    end
end

function TransferMarketCtrl:RefreshData()
    local title = lang.trans("transferMarket_refreshPlayer")
    local msg = lang.trans("transferMarket_refreshPlayerMsg", self.transferMarketModel:GetRefreshDiamondCost())
    local refreshRemainCount = self.transferMarketModel:GetFreeRefreshRemainCount()
    if refreshRemainCount > 0 then
        self:RefreshPlayer()
    else
        if self.transferMarketModel:GetChargeResfreshTime() > 0 then
            DialogManager.ShowConfirmPop(title, msg, function() 
                CostDiamondHelper.CostDiamond(self.transferMarketModel:GetRefreshDiamondCost(), nil, function()self:RefreshPlayer()end)
            end)
        else
            self:GotoVIPPage(PlayerInfoModel.new():GetVipLevel())
        end
    end
end

function TransferMarketCtrl:OnPlayerSet()
    local courtBuildModel = CourtBuildModel.new()
    if courtBuildModel.data and type(courtBuildModel.data) == "table" then
        res.PushDialog("ui.controllers.court.courtScoutPlayer.CourtScoutPlayerInfoCtrl", courtBuildModel)
    else
        clr.coroutine(function()
            local response = req.buildInfo()
            if api.success(response) then
                local data = response.val
                local courtBuildModel = CourtBuildModel.new()
                courtBuildModel:InitWithProtocol(data)
                res.PushDialog("ui.controllers.court.courtScoutPlayer.CourtScoutPlayerInfoCtrl", courtBuildModel)
            end
        end)
    end
end

function TransferMarketCtrl:GotoVIPPage(currVIPLevel)
    local title = lang.trans("transferMarket_refreshPlayer")
    local content = lang.trans("transfer_tip")
    local callback = nil
    local callbackVIPLevl = nil

    if currVIPLevel <= 1 then
        callbackVIPLevl = 2
    elseif currVIPLevel <= 13 then
        callbackVIPLevl = currVIPLevel + 1
    else
        content = lang.trans("transfer_market_refresh_is_zero")
    end

    callback = function ()
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl","vip", callbackVIPLevl)
    end
    if callbackVIPLevl == nil then
        callback = nil
    end

    DialogManager.ShowConfirmPop(title, content, callback)
end

function TransferMarketCtrl:RefreshPlayer()
    clr.coroutine(function()
        local respone = req.transferRefresh()
        if api.success(respone) then
            local data = respone.val
            self.transferMarketModel:InitWithProtocol(data)
            self.transferMarketModel:UpdateCacheData()

            -- 更新花费
            if data.cost and data.cost.type == "d" then
                self.playerInfoModel:SetDiamond(data.cost.curr_num)
                CustomEvent.ConsumeDiamond("4", data.cost.curr_num)
            end
        end
    end)
end

function TransferMarketCtrl:UpdateCacheDataCallBack()
    self.view:InitView(self.transferMarketModel)
    -- 是否还有未签约的并且和球员来信有关的球员
    self.isHasLetterCard = false
    local playerList = self.transferMarketModel:GetPlayerList()
    -- 逻辑:球探社升级后，点击刷新后对应解锁栏解锁新球员
    for i = self.oldPlayerNum + 1, #playerList do
        self.oldPlayerNum = self.oldPlayerNum + 1
        local transferMarketPlayerView = self.transferMarketPlayerViewMap[i]
        local playerCardModel = StaticCardModel.new(playerList[i].cid)
        local flagData = self.cardSymbolModel:GetShowSymbolData(playerList[i].cid)
        transferMarketPlayerView:InitView(playerList[i].pos, self.transferMarketModel, playerCardModel, flagData, self.customTagModel)
        transferMarketPlayerView.onBuy = function(pos) self:OnBuy(pos, self.transferMarketModel:GetPlayerCardPrice(pos), callBackFunc) end
        transferMarketPlayerView.onClickCard = function(pos) self:OnClickCard(pos) end
        local playerCardObject, playerCardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        transferMarketPlayerView:AddPlayerCard(playerCardObject)
        playerCardView:InitView(playerCardModel)
        playerCardView:IsShowName(false)
        self.playerCardMap[i] = { view = playerCardView, model = playerCardModel } 
    end

    for i, playerData in ipairs(playerList) do
        local isHave = PlayerCardsMapModel.new():IsExistCardID(playerData.cid)
        if self.playerLetterInsidePlayerModel:IsBelongToLetterCard(playerData.cid) and not isHave then
            self.isHasLetterCard = true
        end
    end

    for i, playerView in ipairs(self.transferMarketPlayerViewMap) do
        if i <= #playerList then
            local playerCardModel = StaticCardModel.new(playerList[i].cid)
            local flagData = self.cardSymbolModel:GetShowSymbolData(playerList[i].cid)
            playerView:InitView(playerList[i].pos, self.transferMarketModel, playerCardModel, flagData, self.customTagModel)
        end
    end

    for i, playerCard in ipairs(self.playerCardMap) do
        playerCard.model:InitWithCache(playerList[i].cid)
        playerCard.view:InitView(playerCard.model)
    end
end

function TransferMarketCtrl:OnClickCard(pos)
    local cardList = { }
    local selectCardId = nil
    local playerList = self.transferMarketModel:GetPlayerList()
    for i, v in ipairs(playerList) do
        if tonumber(pos) == tonumber(i) then 
            selectCardId = v.cid
            break
        end
    end

    local currentModel = CardBuilder.GetBaseCardModel(selectCardId)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {selectCardId}, 1, currentModel)
end

function TransferMarketCtrl:PlayTransferPlayersLeaveAnimation()
    for i, playerView in ipairs(self.transferMarketPlayerViewMap) do
        playerView:PlayLeaveAnimation()
    end
end

function TransferMarketCtrl:GetShowSymbolData(cid)

    local flagData = {}
    if not self.playerCardsMapModel then
        self.playerCardsMapModel = PlayerCardsMapModel.new()
    end
    if self.playerCardsMapModel:IsExistCardID(cid) then
        return flagData
    end
    if not self.cCidList then
        self.cCidList = CardSymbolHelper.GetChemicalCidsInTeams()
    end
    if not self.bCidList then
        self.bCidList = CardSymbolHelper.GetBestPartnerInTeams()
    end
    flagData.showChemical = self.cCidList[cid] and true or false
    flagData.showBestPartener = self.bCidList[cid] and true or false
    return flagData
end

function TransferMarketCtrl:ClearCidList()
    self.cCidList = nil
    self.bCidList = nil
end

return TransferMarketCtrl
