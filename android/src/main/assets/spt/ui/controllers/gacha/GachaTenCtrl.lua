local GachaTenCtrl = class(unity.base)
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local UI = UnityEngine.UI
local Color = UnityEngine.Color
local Image = UI.Image
local CanvasGroup = UnityEngine.CanvasGroup
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RollRingData = require("ui.control.rollRing.RollRingData")
local CommonConstants = require("ui.common.CommonConstants")
local GachaTenModel = require("ui.models.gacha.GachaTenModel")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")
local UISoundManager = require("ui.control.manager.UISoundManager")

function GachaTenCtrl:ctor(rewardTable, gachaMainCtrl)
        self.rewardTable = rewardTable
        self.sptMap = {}
        self.allSpt = {}
        self.gachaTenModel = GachaTenModel.new()
        local GachaTenDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Congratulations/GachaTen.prefab", "camera", false, true)
        local spt = dialogcomp.contentcomp
        spt.againFunc = function()
            gachaMainCtrl:TenViewBuyTenClick(function() spt.closeDialog() end)
        end
        spt.sellFunc = function()
            self:SellFunc()
        end
        spt.destroyFunc = function()
            self:DestroyFunc()
        end
        spt.allFunc = function()
            spt:SetAll()
            self:AllFunc()
        end
        spt.shareStartFunc = function()
            self:ShareStartFunc()
        end
        spt.shareEndFunc = function()
            self:ShareEndFunc()
        end
        self.view = spt
        self.view:InitView()
        rollRingManger = spt.rollManager
        local RollData =
        {
            {positionX = 0 * 4, positionY = -40 * 4, scale = 0.61 / 0.6, alpha = 1, order = 10, outAlpha = 0, groupAlpha = 1 },
            {positionX = 71 * 4, positionY = -33 * 4, scale = 0.55 / 0.6, alpha = 1, order = 9, outAlpha = 0, groupAlpha = 1 },
            {positionX = 130 * 4, positionY = -5 * 4, scale = 0.50 / 0.6, alpha = 1, order = 7, outAlpha = 0.1, groupAlpha = 0.95 },
            {positionX = 92 * 4, positionY = 25 * 4, scale = 0.45 / 0.6, alpha = 1, order = 5, outAlpha = 0.3, groupAlpha = 0.9 },
            {positionX = 45 * 4, positionY = 40 * 4, scale = 0.40 / 0.6, alpha = 1, order = 3, outAlpha = 0.5, groupAlpha = 0.85 },
            {positionX = 0 * 4, positionY = 43 * 4, scale = 0.38 / 0.6, alpha = 1, order = 1, outAlpha = 0.6, groupAlpha = 0.80 },
            {positionX = -45 * 4, positionY = 40 * 4, scale = 0.40 / 0.6, alpha = 1, order = 2, outAlpha = 0.5, groupAlpha = 0.85 },
            {positionX = -92 * 4, positionY = 25 * 4, scale = 0.45 / 0.6, alpha = 1, order = 4, outAlpha = 0.3, groupAlpha = 0.9 },
            {positionX = -130 * 4, positionY = -5 * 4, scale = 0.50 / 0.6, alpha = 1, order = 6, outAlpha = 0.1, groupAlpha = 0.95 },
            {positionX = -71 * 4, positionY = -33 * 4, scale = 0.55 / 0.6, alpha = 1, order = 8, outAlpha = 0, groupAlpha = 1 }    
        }
        self.animOverCount = 0
        local rewardTable = self:RandomRewardOrder(rewardTable)
        for i = 1, 10 do
            local childGo, childSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Gacha/CardParentInGachaTen.prefab")
            childGo.transform:SetParent(spt.contentArea.transform, false)
            childSpt:InitView(rewardTable[i].detail, rewardTable[i].rType)
            childSpt.onAnimEndFunc = function() self:OnEachAnimEnd() end

            if rewardTable[i].rType == "card" then
                local pcid = rewardTable[i].pcid
                local quality = StaticCardModel.new(rewardTable[i].detail):GetCardQuality()
                if quality < 5 then
                    childSpt.clickCard = function() 
                        self:OnCardClick(pcid) 
                    end
                    self.gachaTenModel:AddCard(rewardTable[i].detail, pcid)
                    self.allSpt[tostring(pcid)] = childSpt
                end                
            end            

            childSpt.onTurnEndCallBack = function()
                self.animOverCount = self.animOverCount + 1
                if self.animOverCount >= 10 then
                    self:GoiOSStore()
                end
            end
            v = RollData[i]
            v.object = childGo
            rollRingManger:AddRollRingData(v)
            table.insert(self.sptMap, childSpt)
        end
        local function IntegerDataFunc(v, nextIndex, originData)
            v.outAlpha = originData[nextIndex].outAlpha
            v.groupAlpha = originData[nextIndex].groupAlpha
        end
        local function DecimalDataFunc(i, nextIndex, t, v, cachedData)
            v.outAlpha = math.lerp(cachedData[i].outAlpha, cachedData[nextIndex].outAlpha, t)
            v.groupAlpha = math.lerp(cachedData[i].groupAlpha, cachedData[nextIndex].groupAlpha, t)
        end

        local function DrawFunc(v, obj)
            local spt = obj:GetComponent("CapsUnityLuaBehav")
            spt:SetMaskAlpha(v.outAlpha)
            obj.transform:GetComponent(CanvasGroup).alpha = v.groupAlpha
        end
        rollRingManger:AddIntegerDataFunc(IntegerDataFunc)
        rollRingManger:AddDecimalDataFunc(DecimalDataFunc)
        rollRingManger:AddDrawFunc(DrawFunc)
        rollRingManger:SetDistRat(0.1)
        rollRingManger:SetMoveMode("arc", {x = 0, y = 0})
        rollRingManger:Init()
        self:PlayAllAnim(spt)
        NewYearCongratulationsPageCtrl.new(self.rewardTable.exchangeItem, NewYearOutPutPosType.CARD)
end

function GachaTenCtrl:RandomRewardOrder(contents)
    local ret = {}
    local left_num = {}
    local card_sorting = {}
    if type(contents.card) == "table" then
        local first_or_last = 1
        local pairs_count = 0
        for i = 1, #contents.card do
            if i % 2 == 0 then
                pairs_count = pairs_count + 1
            end
            table.insert(card_sorting, pairs_count * first_or_last % 10 + 1)
            first_or_last = -first_or_last
        end
    end
    local cardNum = contents.card and #contents.card or 0

    for i = 1 + math.floor((cardNum + 1)/ 2), 10 - math.floor(cardNum / 2) do
        table.insert(left_num, i)
    end

    local function getRandomOrder()
        local rand = math.floor(math.randomInRange(1, #left_num + 1))
        local index = left_num[rand]
        table.remove(left_num, rand)
        return index
    end

    for k, v1 in pairs(contents) do
        local item = {}
        if k ~= "m" then
            item.rType = k
            if k == "card" then
                local all_card = {}
                for i, v in ipairs(v1) do
                    local cardModel = StaticCardModel.new()
                    cardModel:InitWithCache(v.cid)
                    table.insert(all_card, {detail = v.cid, model = cardModel, pcid = v.pcid})
                end

                table.sort(all_card, function(a, b) return a.model:GetCardQuality() > b.model:GetCardQuality() end)
                self.view:SetGachaData(all_card[1].detail)
                for i, v in ipairs(all_card) do
                    item.detail = v.detail
                    item.pcid = v.pcid
                    ret[card_sorting[i]] = clone(item)
                end
            elseif k == "item" then
                for i, v in ipairs(v1) do
                    item.detail = v
                    ret[getRandomOrder()] = clone(item)
                end
            elseif k == "mDetail" then
                for i, v in ipairs(v1) do
                    item.detail = v
                    ret[getRandomOrder()] = clone(item)
                end
            end
        end
    end
    return ret
end

function GachaTenCtrl:PlayAllAnim(viewSpt)
    local curRound = 0
    local function startPlayNextRound()
        -- local ret = {}
        -- if curRound == #self.sptMap / 2 + 1 then
        --     return false
        -- else
        --     if curRound == 0 then
        --         local spt = self.sptMap[#self.sptMap / 2 + 1]
        --         spt:PlayAnim()
        --     elseif curRound == #self.sptMap / 2 then
        --         local spt = self.sptMap[1]
        --         spt:PlayAnim()
        --     else
        --         local spt
        --         spt =  self.sptMap[#self.sptMap / 2 + 1 + curRound]
        --         spt:PlayAnim()
        --         spt =  self.sptMap[#self.sptMap / 2 + 1 - curRound]
        --         spt:PlayAnim()
        --     end
        --     curRound = curRound + 1
        --     return curRound
        -- end
        local start = #self.sptMap / 2 + 1
        curRound = curRound + 1
        if curRound > #self.sptMap then
            return false
        end

        self.sptMap[start + 1 - curRound >= 1 and start + 1 - curRound or #self.sptMap + start + 1 - curRound]:PlayAnim()

        return true
    end

    viewSpt:coroutine(function()
        while true do
            if startPlayNextRound() then
                coroutine.yield(UnityEngine.WaitForSeconds(0.1))
            else
                break
            end
        end
    end)
end

function GachaTenCtrl:OnEachAnimEnd()
    self.waiting = self.waiting and self.waiting + 1 or 1
    if self.waiting == #self.sptMap then
        self.view:coroutine(function()
            coroutine.yield(UnityEngine.WaitForSeconds(0.5))
            -- for i, v in ipairs(self.sptMap) do
            --     v:TurnAround()
            --     coroutine.yield(UnityEngine.WaitForSeconds(0.05))
            -- end
            local start = #self.sptMap / 2 + 1
            for i = 1, #self.sptMap do
                self.sptMap[start + 1 - i >= 1 and start + 1 - i or #self.sptMap + start + 1 - i]:TurnAround()
                coroutine.yield(UnityEngine.WaitForSeconds(0.1))
            end

        end)
    end
end

function GachaTenCtrl:GoiOSStore()
    local isHave = cache.getIsHasSSCard()
    if isHave then return end

    local isHasSSCard = false
    for k, v in pairs(self.rewardTable.card or {}) do
        local quality = StaticCardModel.new(v.cid):GetCardQuality()
        if tonumber(quality) >= tonumber(CommonConstants.PlatinumID) then
            isHasSSCard = true
        end
    end

    if isHasSSCard and clr.plat == "IPhonePlayer" then
        res.PushDialog("ui.control.guideComment.GoodGuideCtrl", true)
        cache.setIsHasSSCard(true)
    end
end

function GachaTenCtrl:OnCardClick(pcid)
    if self.gachaTenModel:GetCardModel(pcid) then
        self.gachaTenModel:ToggleSelectCard(pcid)
        self.allSpt[tostring(pcid)]:SetSelectState(self.gachaTenModel:IsCardSelected(pcid))
    end
end

function GachaTenCtrl:DestroyFunc()
end

function GachaTenCtrl:SellFunc()
    local selectedCardList = self.gachaTenModel:GetSelectedCardList()
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
                UISoundManager.play("Player/sellPlayerSuccess")
                local data = respone.val
                self.gachaTenModel:ClearSelectedCardList()
                self.gachaTenModel:RemoveCards(data.pcids)
                self:SoldCallBack(data.pcids)
                CustomEvent.GetMoney("3", tonumber(data.m))
                luaevt.trig("HoolaiBISendCounterRes", "inflow", 4, tonumber(data.m))
                CustomEvent.CardSell()
                local rewardTable = {m = data.m}
                CongratulationsPageCtrl.new(rewardTable)
            end
        end)
    end

    local totalPlayers = table.nums(selectedCardList)
    local totalValue = string.formatNumWithUnit(self.gachaTenModel:GetSelectedCardValue())
    local desc = lang.trans("gacha_sellplayer_tip", totalPlayers, totalValue)
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Gacha/SellDialog.prefab", "overlay", true, true)
    local data = {}
    data.content = desc
    data.button1Text = lang.trans("cancel")
    data.button2Text = lang.trans("sell")
    data.onButton2Clicked = confirmCallback
    dialogcomp.contentcomp:initData(data)
end

function GachaTenCtrl:AllFunc()
    local flag = self.gachaTenModel:SetAllSelect()
    if flag then 
        self.gachaTenModel:AddAllToSelectedList()
        self:SetAllSign(flag)
    else 
        self.gachaTenModel:ClearSelectedCardList()
        self:SetAllSign(flag)
    end
    self.view:SetAll(flag)
end

function GachaTenCtrl:SetAllSign(flag)
    for k, v in pairs(self.allSpt) do
        v:SetSelectState(flag)
    end
end

function GachaTenCtrl:SoldCallBack(pcids)
    assert(pcids)
    for i, pcid in ipairs(pcids) do
        self:RemoveCard(pcid)
    end
end

function GachaTenCtrl:RemoveCard(pcid)
    self.allSpt[tostring(pcid)]:SetSold()
end

function GachaTenCtrl:ShareStartFunc()
    for k, v in pairs(self.allSpt) do
        v:SetCheckBox(false)
        v:HideSold()
        v:HideMessage()
    end
end

function GachaTenCtrl:ShareEndFunc()
    for k, v in pairs(self.allSpt) do
        if not self.gachaTenModel:GetCardModel(k) then
            v:SetSold()
        else
            v:SetCheckBox(true)
        end
        v:SetMessage()
    end
end

return GachaTenCtrl