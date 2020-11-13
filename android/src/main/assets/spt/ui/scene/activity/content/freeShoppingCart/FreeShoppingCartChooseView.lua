local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FreeShoppingCartChooseView = class()

function FreeShoppingCartChooseView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.lessContentTrans = self.___ex.lessContentTrans
    self.rewardDetailGo = self.___ex.rewardDetailGo
    self.contentTrans = self.___ex.contentTrans
    self.confirmBtn = self.___ex.confirmBtn
--------End_Auto_Generate----------
    self.itemPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FreeShoppingCart/FreeShoppingCartChooseItem.prefab"
end

function FreeShoppingCartChooseView:start()
    self.closeBtn:regOnButtonClick(function()
        self.closeDialog()
    end)
    self.confirmBtn:regOnButtonClick(function()
        self:OnConfirmClick()
    end)
end

function FreeShoppingCartChooseView:InitView(dayData)
    self.dayData = dayData
    res.ClearChildren(self.contentTrans)
    self.itemList = {}
    local itemRes = res.LoadRes(self.itemPath)
    local count = table.nums(dayData)
    if count <= 4 then
        self.contentTrans = self.lessContentTrans
        GameObjectHelper.FastSetActive(self.rewardDetailGo, false)
    end
    for i, v in pairs(dayData) do
        local obj = Object.Instantiate(itemRes)
        obj.transform:SetParent(self.contentTrans, false)
        local spt = obj:GetComponent("CapsUnityLuaBehav")
        spt:InitView(v, function(rewardData)
            self:OnChooseClick(rewardData)
        end)
        local rewardId = v.chooseRewardID
        self.itemList[rewardId] = spt
    end
end

function FreeShoppingCartChooseView:OnChooseClick(rewardData)
    self.rewardId = rewardData.chooseRewardID
    for i, v in pairs(self.itemList) do
        v:SetChooseState(false)
    end
    self.itemList[self.rewardId]:SetChooseState(true)
end

function FreeShoppingCartChooseView:OnConfirmClick()
    if self.rewardId then
        EventSystem.SendEvent("FreeShoppingCart_ChooseReward", self.rewardId)
        self.closeDialog()
    else
        DialogManager.ShowToastByLang("free_shopping_reward_toast")
    end
end

return FreeShoppingCartChooseView
