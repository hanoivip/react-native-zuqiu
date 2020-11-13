local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local VIPModel = require("ui.models.store.VIPModel")
local CommonConstants = require("ui.common.CommonConstants")

local ChargeAndVIPView = class(unity.base)

function ChargeAndVIPView:ctor()
    self.title = self.___ex.title
    self.vipLevelText = self.___ex.vipLevelText
    self.vipDescText = self.___ex.vipDescText
    self.vipNextLevelText = self.___ex.vipNextLevelText
    self.switchBtn = self.___ex.switchBtn
    self.switchBtnText = self.___ex.switchBtnText
    self.progressSlider = self.___ex.progressSlider
    self.progressText = self.___ex.progressText
    self.chargeContent = self.___ex.chargeContent
    self.vipContent = self.___ex.vipContent
    self.chargeListContent = self.___ex.chargeListContent
    self.vipScrollRect = self.___ex.vipScrollRect
    self.vipPrevBtn = self.___ex.vipPrevBtn
    self.vipNextBtn = self.___ex.vipNextBtn
    self.closeBtn = self.___ex.closeBtn
    self.vipPrevNone = self.___ex.vipPrevNone
    self.vipPrevExist = self.___ex.vipPrevExist
    self.vipNextNone = self.___ex.vipNextNone
    self.vipNextExist = self.___ex.vipNextExist
    self.chargeScrollRect = self.___ex.chargeScrollRect
    self.currVIPLevel = nil
    self.vipRect = self.___ex.vipRect

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, nil)
    self.vipScrollRect:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Charge/VIPItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.vipScrollRect:regOnItemIndexChanged(function(index)
        if index > 1 then
            self.vipPrevNone:SetActive(false)
            self.vipPrevExist:SetActive(true)
            self.vipPrevBtn:onPointEventHandle(true)
        else
            self.vipPrevNone:SetActive(true)
            self.vipPrevExist:SetActive(false)
            self.vipPrevBtn:onPointEventHandle(false)
        end
        if index < #self.vipScrollRect.itemDatas then
            self.vipNextNone:SetActive(false)
            self.vipNextExist:SetActive(true)
            self.vipNextBtn:onPointEventHandle(true)
        else
            self.vipNextNone:SetActive(true)
            self.vipNextExist:SetActive(false)
            self.vipNextBtn:onPointEventHandle(false)
        end
        self.currVIPLevel = index
    end)
    self.vipPrevBtn:regOnButtonClick(function()
        self.vipScrollRect:scrollToPreviousGroup()
    end)
    self.vipNextBtn:regOnButtonClick(function()
        self.vipScrollRect:scrollToNextGroup()
    end)
    EventSystem.AddEvent("VIPLevelUpInVIPPage", self, self.ShowVIPTip)
end

function ChargeAndVIPView:ShowVIPTip(vipLevel)
    res.PushDialog("ui.controllers.charge.VIPTipCtrl", vipLevel, self)
end

function ChargeAndVIPView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function ChargeAndVIPView:InitTop(vipLevel, currentDiamond)
    self.vipLevelText.text = format("VIP\n%s", vipLevel)
    local vipRectPosX = vipLevel > 9 and -365 or -353
    self.vipRect.anchoredPosition = Vector2(vipRectPosX, 0)

    local nextDiamond
    if vipLevel < self.MaxVIPLevel then
        nextDiamond = VIPModel[vipLevel + 1].cumDiamond
        self.vipNextLevelText.text = format("VIP%s", vipLevel + 1)
        self.vipDescText.text = lang.trans("charge_info_1", nextDiamond - currentDiamond)
    elseif vipLevel == self.MaxVIPLevel then
        nextDiamond = VIPModel[vipLevel].cumDiamond
        self.vipNextLevelText.text = "VIP"
        self.vipDescText.text = lang.trans("charge_info_2")
    end

    self.progressText.text = format("%s / %s", currentDiamond, nextDiamond)
    if currentDiamond <= nextDiamond then
        self.progressSlider.value = currentDiamond / nextDiamond
    else
        self.progressSlider.value = 1
    end
end

function ChargeAndVIPView:InitAsCharge(vipLevel, currentDiamond, items, isBlackDiamond)
    self:InitTop(vipLevel, currentDiamond)
    self.title.text = lang.transstr("charge")
    self.switchBtnText.text = "VIP"
    self.chargeContent:SetActive(true)
    self.vipContent:SetActive(false)

    if type(items) == "table" then
        res.ClearChildren(self.chargeListContent)
        for i, v in ipairs(items) do
            v.transform:SetParent(self.chargeListContent, false)
        end
    end
    if isBlackDiamond then
        self.chargeScrollRect.verticalNormalizedPosition = 0
    end
end

function ChargeAndVIPView:InitAsVIP(vipLevel, currentDiamond, datas, boughtInfo, showVIPLevel)
    self:InitTop(vipLevel, currentDiamond)
    self.title.text = "VIP"
    self.switchBtnText.text = lang.transstr("charge")
    self.chargeContent:SetActive(false)
    self.vipContent:SetActive(true)

    self.vipScrollRect:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data.vipLv, data.desc, data.price, data.bagContents, boughtInfo)
        scrollSelf:updateItemIndex(spt, index)
    end)
    self.vipScrollRect:refresh(datas)
    self.vipScrollRect:scrollToCellImmediate(showVIPLevel or vipLevel)
end

function ChargeAndVIPView:GotoVIPContentByVIPLevel(vipLevel)
    if type(self.refresh) == "function" then
        self.refresh("vip", vipLevel)
    end
end

function ChargeAndVIPView:RegOnSwitchBtnClick(func)
    if type(func) == "function" then
        self.switchBtn:regOnButtonClick(func)
    end
end

function ChargeAndVIPView:onDestroy()
    EventSystem.RemoveEvent("VIPLevelUpInVIPPage", self, self.ShowVIPTip)
end

return ChargeAndVIPView
