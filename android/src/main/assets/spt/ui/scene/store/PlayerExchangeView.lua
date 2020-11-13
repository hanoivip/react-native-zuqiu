local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local PlayerExchangeView = class(unity.base)

function PlayerExchangeView:ctor()
    self.btnTarget = self.___ex.btnTarget
    self.btnExchangePlayer1 = self.___ex.btnExchangePlayer1
    self.btnExchangePlayer2 = self.___ex.btnExchangePlayer2
    self.targetArea = self.___ex.targetArea
    self.exchangePlayerArea1 = self.___ex.exchangePlayerArea1
    self.exchangePlayerArea2 = self.___ex.exchangePlayerArea2
    self.arrow = self.___ex.arrow
    self.exchangeDesc = self.___ex.exchangeDesc
    self.exchangeTip = self.___ex.exchangeTip
    self.canExchange = self.___ex.canExchange
    self.btnExchange = self.___ex.btnExchange
    self.exchangeCount = self.___ex.exchangeCount
    self.ownerNumTxt = self.___ex.ownerNumTxt
    self.needNumTxt = self.___ex.needNumTxt
    self.needConsumeGo = self.___ex.needConsumeGo
    self.targetPcid = nil
    self.exchangePlayer1 = nil
    self.exchangePlayer2 = nil
end

function PlayerExchangeView:start()
    self.btnTarget:regOnButtonClick(function()
        self:OnClickTarget()
    end)
    self.btnExchangePlayer1:regOnButtonClick(function()
        self:OnClickExchangePlayer1()
    end)
    self.btnExchangePlayer2:regOnButtonClick(function()
        self:OnClickExchangePlayer2()
    end)
    self.btnExchange:regOnButtonClick(function()
        self:OnClickExchange()
    end)
end

function PlayerExchangeView:EnterScene()
    EventSystem.AddEvent("Exchange_UpdateTarget", self, self.EventUpdateTarget)
    EventSystem.AddEvent("Exchange_UpdateChoose", self, self.EventUpdateChoose)
end

function PlayerExchangeView:onDestroy()
    EventSystem.RemoveEvent("Exchange_UpdateTarget", self, self.EventUpdateTarget)
    EventSystem.RemoveEvent("Exchange_UpdateChoose", self, self.EventUpdateChoose)
end

function PlayerExchangeView:InitView(exchangeModel)
    self.exchangeModel = exchangeModel
    self.targetPcid = nil
    self.exchangePlayer1 = nil
    self.exchangePlayer2 = nil
    GameObjectHelper.FastSetActive(self.targetArea.gameObject, false)
    GameObjectHelper.FastSetActive(self.exchangePlayerArea1.gameObject, false)
    GameObjectHelper.FastSetActive(self.exchangePlayerArea2.gameObject, false)
    self:UpdateTip()

    local hasCount = exchangeModel:HasExchangeCount()
    local exchangeCount = exchangeModel:GetExchangeCount()
    local maxExchangeCount = exchangeModel:GetMaxExchangeCount()
    local exchangeItemCount = exchangeModel:GetExchangeItemCount()
    local needExchangeItemCount = exchangeModel:GetNeedExchangeItemCount()
    local countStr = hasCount and "<color=#9CDC14>" .. exchangeCount .. "</color>" .. " / " .. maxExchangeCount or "<color=red>" .. exchangeCount .. "</color>" .. " / " .. maxExchangeCount
    self.exchangeCount.text = countStr
    self.needNumTxt.text = "x" .. needExchangeItemCount
    self.ownerNumTxt.text = "(" .. lang.transstr("now_own", exchangeItemCount) .. ")"
end

function PlayerExchangeView:EventUpdateTarget(targetPcid)
    if targetPcid then 
        self.targetPcid = targetPcid
        local cardModel = PlayerCardModel.new(targetPcid)
        if not self.cardView then
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
            obj.transform:SetParent(self.targetArea.transform, false)
            self.cardView = spt
            self.cardView:IsShowName(false)
        end
        self.cardView:InitView(cardModel)
        GameObjectHelper.FastSetActive(self.targetArea.gameObject, true)
    end
    self.exchangePlayer1 = nil
    self.exchangePlayer2 = nil
    local isSpecialCard = self.exchangeModel:IsSpecialCard(targetPcid)
    GameObjectHelper.FastSetActive(self.exchangePlayerArea1.gameObject, false)
    GameObjectHelper.FastSetActive(self.exchangePlayerArea2.gameObject, false)
    GameObjectHelper.FastSetActive(self.needConsumeGo, isSpecialCard)
    self:UpdateTip()
end

function PlayerExchangeView:EventUpdateChoose(choosePcid, slot)
    if choosePcid then 
        local chooseView
        local chooseArea
        if slot == 1 then 
            self.exchangePlayer1 = choosePcid
            chooseView = self.cardView1
            chooseArea = self.exchangePlayerArea1
        elseif slot == 2 then 
            self.exchangePlayer2 = choosePcid
            chooseView = self.cardView2
            chooseArea = self.exchangePlayerArea2
        end
        
        local cardModel = PlayerCardModel.new(choosePcid)
        if not chooseView then
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
            obj.transform:SetParent(chooseArea.transform, false)
            chooseView = spt
            chooseView:IsShowName(false)
        end
        chooseView:InitView(cardModel)
        GameObjectHelper.FastSetActive(chooseArea.gameObject, true)
    end
    self:UpdateTip()
end

function PlayerExchangeView:UpdateTip()
    local isCanExchange = false
    if self.targetPcid then 
        if self.exchangePlayer1 and self.exchangePlayer2 then 
            isCanExchange = true
        else
            self.exchangeDesc.text = lang.trans("select_exchange_player2")
            self.arrow.transform.anchoredPosition = Vector2(400, -2)
            self.arrow.transform.localScale = Vector3(-1, 1, 1)
        end
    else
        self.exchangeDesc.text = lang.trans("select_target_player2")
        self.arrow.transform.anchoredPosition = Vector2(68, -2)
        self.arrow.transform.localScale = Vector3(1, 1, 1)
    end
    GameObjectHelper.FastSetActive(self.canExchange, isCanExchange)
    GameObjectHelper.FastSetActive(self.exchangeTip, not isCanExchange)
end

function PlayerExchangeView:OnClickTarget()
    if self.clickTarget then 
        self.clickTarget(self.targetPcid)
    end
end

function PlayerExchangeView:OnClickExchangePlayer1()
    if self.clickExchangePlayer1 then 
        self.clickExchangePlayer1(self.targetPcid, self.exchangePlayer1, self.exchangePlayer2)
    end
end

function PlayerExchangeView:OnClickExchangePlayer2()
    if self.clickExchangePlayer2 then 
        self.clickExchangePlayer2(self.targetPcid, self.exchangePlayer2, self.exchangePlayer1)
    end
end

function PlayerExchangeView:OnClickExchange()
    if self.clickExchange then 
        self.clickExchange(self.targetPcid, self.exchangePlayer1, self.exchangePlayer2)
    end
end

function PlayerExchangeView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return PlayerExchangeView
