local BaseCtrl = require("ui.controllers.BaseCtrl")

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerListModel = require("ui.models.playerList.PlayerListModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local PlayerLimitCtrl = require("ui.controllers.playerList.PlayerLimitCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local MenuType = require("ui.controllers.playerList.MenuType")
local DialogManager = require("ui.control.manager.DialogManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerListMainCtrl = class(BaseCtrl, "PlayerListMainCtrl")
local UISoundManager = require("ui.control.manager.UISoundManager")
local SortType = require("ui.controllers.playerList.SortType")
local StoreModel = require("ui.models.store.StoreModel")
local MallPageType = require("ui.scene.store.MallPageType")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")

PlayerListMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerList/PlayerListCanvas.prefab"

function PlayerListMainCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.cardResourceCache:Clear()
            self.view:PlayLeaveAnimation()
        end)
    end)

    self.view.clickMenu = function(index) self:OnMenuClick(index) end
    self.view.clickSort = function(index) self:OnSortClick(index) end
    self.view.clickBack = function()
        self.cardResourceCache:Clear()
    end
    self.view.clickPlayerLimit = function() self:OnPlayerLimitClick() end
    self.view.clickSearch = function() self:OnSearchClick() end
    self.view.clickSell = function() self:OnBtnSell() end
    self.view.clickCancel = function() self:OnBtnCancel() end

    -- 动画完成时的回调
    self.view.onAnimationLevelComplete = function()
        clr.coroutine(function()
            unity.waitForEndOfFrame()
            res.PopSceneImmediate()
            -- 关闭球员管理界面
            GuideManager.Show(res.curSceneInfo.ctrl)
        end)
    end

    -- 选中卡牌之后的事件回调（球员出售）
    self.view.selectCardCallBack = function(pcid, isSelected)
        self:SelectCardCallBack(pcid, isSelected)
    end
    self.view.clearSelectedCardsCallBack = function()
        self:ClearSelectedCardsCallBack()
    end
    self.view.soldCardsCallBack = function(pcids)
        self:SoldCardsCallBack(pcids)
    end
    -- 锁定卡牌的事件回调（球员锁定）
    self.view.resetOneCardCallBack = function(pcid)
        self:ResetOneCardCallBack(pcid)
    end
    -- 排序
    self.view.sortCardListCallBack = function()
        self:SortCardListCallBack()
    end
    -- 球员上限变化
    self.view.playerCapacityCallBack = function(playerCapacity)
        self:PlayerCapacityCallBack(playerCapacity)
    end
    -- 添加球员
    self.view.addCardCallBack = function(pcid)
        self:AddCardCallBack(pcid)
    end
    -- 使用碎片合成
    self.view.clickPieceCompose = function(cardPieceModel)
        self:PieceCompose(cardPieceModel)
    end

    self.cardResourceCache = CardResourceCache.new()
    self:RegScrollComp()
    self.isInitial = true
end

function PlayerListMainCtrl:Refresh(menuType, scrollNormalizedPos, selectTypeIndex, selectPos, isInitial, selectQuality, selectNationality, selectName, selectSkill)
    PlayerListMainCtrl.super.Refresh(self)
    if not selectTypeIndex then
        selectTypeIndex = SortType.DEFAULT
    end

    self.playerListModel = PlayerListModel.new(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    if not self.cardIndexViewModel then
        self.cardIndexViewModel = CardIndexViewModel.new()
    end

    if not menuType then
        menuType = MenuType.LIST
    end
    self.currentMenu = menuType
    self.cacheScrollPos = scrollNormalizedPos or 1
    self:InitView(self.playerListModel)
    self:InitialInfo(isInitial, selectTypeIndex)

    clr.coroutine(function()
        coroutine.yield(UnityEngine.WaitForEndOfFrame())
        if menuType == MenuType.PIECE then
            self.view.pieceView:InitView(self.playerListModel, self.cardResourceCache)
        else
            self.playerListModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
        end
    end)
end

-- 初始化默认数据
function PlayerListMainCtrl:InitialInfo(isInitial, selectTypeIndex)
    self.isInitial = isInitial
    if self.isInitial then 
        self.view:InitialData()
        self.isInitial = false
    else
        self.view:AdjustAnimation()
        self.view:OnSelectSort(selectTypeIndex)
    end
end

function PlayerListMainCtrl:GetStatusData()
    return self.currentMenu, self.cacheScrollPos, self.selectTypeIndex, self.selectPos, self.isInitial, self.selectQuality, self.selectNationality, self.selectName, self.selectSkill
end

function PlayerListMainCtrl:OnEnterScene()
    self.view:EnterScene()
end

function PlayerListMainCtrl:OnExitScene()
    self.view:ExitScene()
end

function PlayerListMainCtrl:InitView(playerListModel)
    self.view:InitView(playerListModel, self.currentMenu)
    self.view:ControlScrollRect()
end

function PlayerListMainCtrl:GetPlayerRes()
    if not self.playerRes then
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Player.prefab")
    end
    return self.playerRes
end

function PlayerListMainCtrl:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function PlayerListMainCtrl:RegScrollComp()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj = Object.Instantiate(self:GetPlayerRes())
        local spt = res.GetLuaScript(obj)
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local itemData = self.view.scrollView.itemDatas[index]
        spt:InitView(itemData, self.currentMenu, self.playerListModel, self.cardResourceCache, self)
        if self.currentMenu == MenuType.LIST then
            itemData:InitEquipsAndSkills()
            local hasSign = false
            if not GuideManager.GuideIsOnGoing("main") then
                hasSign = itemData:HasSign()
            end
            spt:SetCardTip(hasSign)
        elseif self.currentMenu == MenuType.SELL then
            spt:SetSellState(self.playerListModel:IsCardSelected(itemData:GetPcid()))
        end
        spt.clickCard = function() self:OnCardClick(itemData:GetPcid()) end
        self.view.scrollView:updateItemIndex(spt, index)
    end
end

function PlayerListMainCtrl:RefreshScrollView()
    -- 创建卡牌列表
    local sortCardList = self.playerListModel:GetSortCardList()
    self.selectTypeIndex = self.playerListModel:GetSelectTypeIndex()
    self.selectPos = self.playerListModel:GetSelectPos()
    self.selectQuality = self.playerListModel:GetSelectQuality()
    self.selectName = self.playerListModel:GetSeletName()
    self.selectNationality = self.playerListModel:GetSeletNationality()
    self.selectSkill = self.playerListModel:GetSeletSkill()
    local cardsArray = {}
    for i, pcid in ipairs(sortCardList) do
        local cardModel = self.playerListModel:GetCardModel(pcid)
        table.insert(cardsArray, cardModel)
    end
    self.view.scrollView:RefreshItemWithScrollPos(cardsArray, self.cacheScrollPos)
end

function PlayerListMainCtrl:SortCardListCallBack()
    self:RefreshScrollView()
end

function PlayerListMainCtrl:SoldCardsCallBack(pcids)
    self:RefreshScrollView()

    self.view:InitView(self.playerListModel, self.currentMenu)
    self.view:SetSellInfo(self.playerListModel)
end

function PlayerListMainCtrl:ClearSelectedCardsCallBack()
    for index, v in pairs(self.view.scrollView.itemDatas) do
        local cardView = self.view.scrollView:getItem(index)
        if cardView then
            cardView:SetSellState(false)
        end
    end
    self.view:SetSellInfo(self.playerListModel)
end

function PlayerListMainCtrl:ResetOneCardCallBack(pcid)
    local index
    local cardModel = self.playerListModel:GetCardModel(pcid)
    for i, v in ipairs(self.view.scrollView.itemDatas) do
        if tostring(v:GetPcid()) == tostring(pcid) then
            index = i
            break
        end
    end
    if index then
        self.view.scrollView.itemDatas[index] = cardModel
        local cardView = self.view.scrollView:getItem(index)
        if cardView then
            cardView:InitView(cardModel, self.currentMenu, self.playerListModel)
        end
    end
end

function PlayerListMainCtrl:SelectCardCallBack(pcid, isSelected)
    local index
    for i, v in ipairs(self.view.scrollView.itemDatas) do
        if tostring(v:GetPcid()) == tostring(pcid) then
            index = i
            break
        end
    end
    if index then
        local cardView = self.view.scrollView:getItem(index)
        if cardView then
            cardView:SetSellState(isSelected)
        end
    end
    self.view:SetSellInfo(self.playerListModel)
end

function PlayerListMainCtrl:OnCardClick(pcid)
    if self.currentMenu == MenuType.LIST then
        -- 点击卡牌，弹出卡牌详情页面
        local cardList = self.playerListModel:GetSortCardList()

        for i, v in ipairs(cardList) do
            if tostring(v) == tostring(pcid) then
                self.cacheScrollPos = self.view.scrollView:GetScrollNormalizedPosition()
                local teamModel = self.playerListModel:GetTeamModel()
                local currentModel = CardBuilder.GetOwnCardModel(cardList[i], teamModel)
                clr.coroutine(function()
                    unity.waitForEndOfFrame()
                    local CardDetailMainCtrl = res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, i, currentModel, nil, true)
                    -- 打开大卡界面
                    GuideManager.Show(CardDetailMainCtrl)
                end)
                break
            end
        end
    elseif self.currentMenu == MenuType.LOCK then
        local cardModel = self.playerListModel:GetCardModel(pcid)
        if cardModel:IsInPlayingLock()or cardModel:IsInPlayingRepLock() then return end
        local isLock = cardModel:IsInPlayerLock()
        -- lock : 0=解锁，1=加锁
        clr.coroutine(function()
            local respone = req.cardLock(pcid, isLock and 0 or 1)
            if api.success(respone) then
                local data = respone.val
                self.playerListModel:ResetCardData(data.pcid, data)
            end
        end)
    elseif self.currentMenu == MenuType.SELL then
        local cardModel = self.playerListModel:GetCardModel(pcid)
        if cardModel:IsNotAllowSell() then return end
        if not self.playerListModel:IsCardSelected(pcid) then
            if cardModel:HasMedal() then 
                DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip5", cardModel:GetName()), nil)
            elseif cardModel:HasPaster() then 
                DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip2", cardModel:GetName()), nil)
            elseif not PlayerLetterInsidePlayerModel.new():IsBelongToLetterCard(cardModel:GetCid()) then
                self.playerListModel:ToggleSelectCard(pcid)
            else
                DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("player_sell_tip", cardModel:GetName()), function ()
                    self.playerListModel:ToggleSelectCard(pcid)
                end, nil)
            end
        else
            self.playerListModel:ToggleSelectCard(pcid)
        end
    end
end

function PlayerListMainCtrl:OnMenuClick(index)
    if index == self.currentMenu then return end

    if self.currentMenu == MenuType.PIECE then -- 碎片界面合成后回到其它界面重新更新数据
        self.view:SetCurrentCardsCount(table.nums(self.playerListModel:GetCardList()), self.playerListModel:GetCardNumberLimit())
        local selectTypeIndex = self.playerListModel:GetSelectTypeIndex()
        local selectPos = self.playerListModel:GetSelectPos()
        self.playerListModel:SortCardList(selectTypeIndex, selectPos)
    end

    self.currentMenu = index
    if index == MenuType.SELL then
        self.playerListModel:ClearSelectedCardList()
    end

    if index == MenuType.PIECE then
        self.view.pieceView:InitView(self.playerListModel, self.cardResourceCache) 
    else
        self.view.scrollView:refresh()
    end
end

function PlayerListMainCtrl:OnSortClick(selectTypeIndex)
    self.cacheScrollPos = 1
    local typeIndex = self.playerListModel:GetSelectTypeIndex()
    if typeIndex == selectTypeIndex then return end
    local selectPos = self.playerListModel:GetSelectPos()
    local selectQuality = self.playerListModel:GetSelectQuality()
    local selectNationality = self.playerListModel:GetSeletNationality()
    local selectName = self.playerListModel:GetSeletName()
    local selectSkill = self.playerListModel:GetSeletSkill()
    self.playerListModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
end

function PlayerListMainCtrl:OnBtnSell()
    local selectedCardList = self.playerListModel:GetSelectedCardList()
    local title = lang.trans("playerList_sellPlayers")
    local desc = ""
    if next(selectedCardList) == nil then
        print("selcect card nums : 0!")
        desc = lang.trans("select_sale_player")
        DialogManager.ShowAlertPop(title, desc, function() end)
        return
    end

    local confirmCallback = function()
        clr.coroutine(function()
            local respone = req.cardSell(selectedCardList)
            if api.success(respone) then
                UISoundManager.play('Player/sellPlayerSuccess')
                local data = respone.val
                -- 先清除选中列表
                self.playerListModel:ModifyFormation(data.pcids)
            
                self.playerListModel:ClearSelectedCardList()
                self.playerListModel:RemoveCards(data.pcids)
                CustomEvent.GetMoney("3", tonumber(data.m))
                luaevt.trig("HoolaiBISendCounterRes", "inflow", 4, tonumber(data.m))
                CustomEvent.CardSell()

                local rewardTable = {m = data.m}
                CongratulationsPageCtrl.new(rewardTable)
            end
        end)
    end

    local totalPlayers = table.nums(selectedCardList)
    local totalValue = string.formatNumWithUnit(self.playerListModel:GetSelectedCardValue())
    local desc = lang.trans("sale_player_tip", totalPlayers, totalValue)
    DialogManager.ShowConfirmPop(title, desc, confirmCallback)
end

function PlayerListMainCtrl:OnBtnCancel()
    self.playerListModel:ClearSelectedCardList()
end

function PlayerListMainCtrl:OnSearchClick()
    res.PushDialog("ui.controllers.playerList.PlayerSearchCtrl", self.playerListModel, self.cardIndexViewModel)
end

function PlayerListMainCtrl:OnPlayerLimitClick()
    local playerLimitCtrl = PlayerLimitCtrl.new()
end

function PlayerListMainCtrl:PlayerCapacityCallBack(playerCapacity)
    self.view:SetCurrentCardsCount(table.nums(self.playerListModel:GetCardList()), self.playerListModel:GetCardNumberLimit())
end

function PlayerListMainCtrl:AddCardCallBack(pcid)
    self.playerListModel:AddCard(pcid)
    self:RefreshScrollView()
end

function PlayerListMainCtrl:BuildPieceCompose(cost, contents)
    local cardPiece = cost.cardPiece or {}
    local cid = cardPiece.cid
    local finalNum = tonumber(cardPiece.num)
    if finalNum > 0 then
        self.playerListModel:ResetPieceData(cid, cardPiece)
    else
        self.playerListModel:RemovePieceData(cid)
    end
    CongratulationsPageCtrl.new(contents)
end

function PlayerListMainCtrl:PieceCompose(cardPieceModel)
    local isPasterPiece = cardPieceModel:IsPasterPiece()
    local isUniversalPiece = cardPieceModel:IsUniversalPiece()
    local isCoachIntelligencePiece = cardPieceModel:IsCoachIntelligencePiece()
    if isPasterPiece then
        StoreModel.SetMallPageType(MallPageType.PasterPiece)
        StoreModel.SetShowPasterType(cardPieceModel:GetId())
        res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
    elseif isUniversalPiece then 
        StoreModel.SetMallPageType(MallPageType.PlayerPiece)
        res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
    elseif isCoachIntelligencePiece then
        local pieceNeed = cardPieceModel:GetComposeNeedPiece()
        local pieceNum = cardPieceModel:GetNum()
        if pieceNum >= pieceNeed then
            local composeFunc = function()
                local id = cardPieceModel:GetId()
                self.view:coroutine(function()
                    local respone = req.cardIncorporateAssistantCoachInfo(id)
                    if api.success(respone) then
                        local data = respone.val
                        if next(data) then
                            local cost = data.cost or {}
                            local contents = data.contents and data.contents.item or {}
                            self:BuildPieceCompose(cost, contents)
                        end
                    end
                end)
            end
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.transstr("coach_item_compose_tips"),
                    function() composeFunc() end)
        else
            DialogManager.ShowToast(lang.trans("coachIntelligencePiece_not_enough"))
        end
    else
        local pieceNeed = cardPieceModel:GetComposeNeedPiece() 
        local pieceNum = cardPieceModel:GetNum()
        if pieceNum >= pieceNeed then
            local composeFunc = function()
                local id = cardPieceModel:GetId()
                self.view:coroutine(function()
                    local respone = req.cardIncorporate(id)
                    if api.success(respone) then 
                        local data = respone.val
                        if next(data) then
                            local cost = data.cost
                            local contents = data.contents
                            self:BuildPieceCompose(cost, contents)
                        end
                    end
                end)
            end
            local pieceName = cardPieceModel:GetName()
            local pieceQuality = cardPieceModel:GetQuality()
            local pieceFixQuality = CardHelper.GetQualityFixed(pieceQuality, cardPieceModel:GetQualitySpecial())
            pieceQuality = CardHelper.GetQualitySign(pieceFixQuality)
            pieceName = pieceQuality .. pieceName
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.transstr("activity_exchange_item_tips", 1, pieceName), 
            function() 
                composeFunc() 
            end)
        else
            DialogManager.ShowToast(lang.trans("piece_not_enough"))
        end
    end
end

return PlayerListMainCtrl
