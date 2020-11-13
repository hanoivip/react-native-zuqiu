local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LevelLimit = require("data.LevelLimit")
local RebornPlayerChooseView = class(unity.base)

function RebornPlayerChooseView:ctor()
    self.btnClose = self.___ex.btnClose
    self.btnConfirm = self.___ex.btnConfirm
    self.confirmButton = self.___ex.confirmButton
    self.cardParent = self.___ex.cardParent
    self.cardArea = self.___ex.cardArea
    self.scroll = self.___ex.scroll
    self.btnTransfer = self.___ex.btnTransfer
    self.transferButton = self.___ex.transferButton
    self.btnGacha = self.___ex.btnGacha
    self.gachaButton = self.___ex.gachaButton
    self.transferGradient = self.___ex.transferGradient
    self.gachaGradient = self.___ex.gachaGradient
    self.confirmGradient = self.___ex.confirmGradient
    self.selectTip = self.___ex.selectTip
    self.cardTip = self.___ex.cardTip
    self.noCardArea = self.___ex.noCardArea
    self.isChoose = false

    -- scrollRectSameSize 的注册方法需要提前执行
    self.scroll:regOnCreateItem(function(scrollSelf, index)
        if type(self.onScrollCreateItem) == "function" then
            return self.onScrollCreateItem(scrollSelf, index)
        end
    end)
    self.scroll:regOnResetItem(function(scrollSelf, spt, index)
        if type(self.onScrollResetItem) == "function" then
            return self.onScrollResetItem(scrollSelf, spt, index)
        end
    end)
end

function RebornPlayerChooseView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
    end)
    self.btnConfirm:regOnButtonClick(function()
        if type(self.clickConfirm) == "function" then
            self.clickConfirm()
        end
    end)
    self.btnTransfer:regOnButtonClick(function()
        res.PushScene("ui.controllers.transferMarket.TransferMarketCtrl", {})
    end)
    self.btnGacha:regOnButtonClick(function()
        res.PushSceneImmediate("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.GACHA)
    end)
end

function RebornPlayerChooseView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function RebornPlayerChooseView:SetButtonState()
    self.confirmButton.interactable = self.isChoose
    if self.isChoose then 
        ButtonColorConfig.SetNormalGradientColor(self.confirmGradient)
    else
        ButtonColorConfig.SetDisableGradientColor(self.confirmGradient)
    end
end

function RebornPlayerChooseView:InitView(cardModelList, isAllowChangeScene, playerLevel)
    assert(type(cardModelList) == "table")
    self:SetButtonState()
    local hasCard = tobool(table.nums(cardModelList) > 0)
    GameObjectHelper.FastSetActive(self.noCardArea.gameObject, not hasCard)
    GameObjectHelper.FastSetActive(self.cardArea.gameObject, hasCard)
    self.btnGacha:onPointEventHandle(isAllowChangeScene)
    self.btnTransfer:onPointEventHandle(isAllowChangeScene)
    self.gachaButton.interactable = isAllowChangeScene
    self.transferButton.interactable = isAllowChangeScene

    -- 玩家5级前还没有开启转会功能，所以不能跳转到转会界面
    if playerLevel < LevelLimit["transfer"].playerLevel then
        self.btnTransfer:onPointEventHandle(false)
        self.transferButton.interactable = false
    else
        self.btnTransfer:onPointEventHandle(isAllowChangeScene)
        self.transferButton.interactable = isAllowChangeScene
    end
end

function RebornPlayerChooseView:SetChoosePlayer(cardModel)
    assert(cardModel)
    self.isChoose = true
    self:SetButtonState()
    GameObjectHelper.FastSetActive(self.cardParent.gameObject, true)
    GameObjectHelper.FastSetActive(self.selectTip.gameObject, false)
    if not self.cardView then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        obj.transform:SetParent(self.cardParent.transform, false)
        self.cardView = spt
    end
    self.cardView:InitView(cardModel)
end

return RebornPlayerChooseView
