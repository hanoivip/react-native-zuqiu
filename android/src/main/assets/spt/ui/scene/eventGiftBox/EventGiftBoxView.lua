local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Timer = require('ui.common.Timer')
local Object = clr.UnityEngine.Object
local EventGiftBoxView = class(unity.base)

function EventGiftBoxView:ctor()
    self.group = self.___ex.group
    self.flag = self.___ex.flag
    self.clickBtn = self.___ex.clickBtn
    self.clickBtn1 = self.___ex.clickBtn1
    self.clickBtn2 = self.___ex.clickBtn2
    self.parentRect = self.___ex.parentRect
end

function EventGiftBoxView:start()
    self.clickBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.clickBtn1:regOnButtonClick(function()
        self:Close()
    end)
    self.clickBtn2:regOnButtonClick(function()
        self:Close()
    end)
    self:PlayInAnimator()
end

function EventGiftBoxView:InitView(model)
    self.model = model
    local list = self.model:GetGiftList()
    self:SetFlagShow(#list < 2)
    self:InitList(list)
end

function EventGiftBoxView:OnMySceneUpdate()
    for k,v in pairs(self.sceneList) do
        v:SetSelect()
    end
end

local path = "Assets/CapstonesRes/Game/UI/Scene/EventGiftBox/GiftItem.prefab"
function EventGiftBoxView:InitList(list)
    res.ClearChildren(self.group)
    self.sptList = {}
    for i,v in ipairs(list) do
        local obj, spt = res.Instantiate(path)
        obj.transform:SetParent(self.group, false)
        spt.onBuyClick = function() self:OnClickPurchase(v) end
        spt:InitView(v, self.parentRect)
        self.sptList[v] = spt
    end
end

function EventGiftBoxView:OnClickPurchase(data)
    if self.onClickPurchase then
        self.onClickPurchase(data)
    end
end

function EventGiftBoxView:OnConfirm()
    self:Close()
end

function EventGiftBoxView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function EventGiftBoxView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function EventGiftBoxView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

--刷新购买情况
function EventGiftBoxView:RefreshBuyInfo()
    if not self.sptList then
        return
    end
    for k, v in pairs(self.sptList) do
        v:SetBuyInfo()
    end
end

--设置底图是否显示
function EventGiftBoxView:SetFlagShow(bShow)
    GameObjectHelper.FastSetActive(self.flag, bShow)
end

function EventGiftBoxView:update()
    if not self.sptList then
        return
    end
    local haveCount = 0
    local needRList = {}
    for k, v in pairs(self.sptList) do
        local lastTime = self.model:GetLastTime(k)
        if lastTime <= 0 then
            needRList[k] = 1
        else
            v:UpdateTime(lastTime)
            haveCount = haveCount + 1
        end
    end

    if haveCount < 1 then
        --全都过时了
        self:Close()
        return
    end

    for k, v in pairs(needRList) do
        Object.Destroy(self.sptList[k].gameObject)
        self.sptList[k] = nil
        self.model:Remove(k)
    end

    self:SetFlagShow(haveCount < 2)
end

function EventGiftBoxView:Close()
    self.sptList = nil
    self:PlayOutAnimator()
end

return EventGiftBoxView