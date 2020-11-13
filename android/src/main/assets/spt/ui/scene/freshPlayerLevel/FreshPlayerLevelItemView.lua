local Timer = require("ui.common.Timer")
local DialogManager = require("ui.control.manager.DialogManager")
local FreshPlayerLevelModel = require("ui.models.freshPlayerLevel.FreshPlayerLevelModel")
local FreshPlayerLevelItemView = class(unity.base)
local BuyType = FreshPlayerLevelModel.BuyType

function FreshPlayerLevelItemView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.timeTxt = self.___ex.timeTxt
    self.freeTitleTxt = self.___ex.freeTitleTxt
    self.freeBtn = self.___ex.freeBtn
    self.freeTxt = self.___ex.freeTxt
    self.costTitleTxt = self.___ex.costTitleTxt
    self.costBtn = self.___ex.costBtn
    self.costTxt = self.___ex.costTxt
--------End_Auto_Generate----------
    self.freeButton = self.___ex.freeButton
    self.costButton = self.___ex.costButton
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
        self.countDownTimer = nil
    end
end

function FreshPlayerLevelItemView:start()
    self.freeBtn:regOnButtonClick(function()
        if self.freeData.cacheData.state == 1 then
            DialogManager.ShowToastByLang("have_received")
            return
        end
        if self.buyBtnClick then
            self:ShowDetail(self.freeId)
        end
    end)
    self.costBtn:regOnButtonClick(function()
        if self.costData.cacheData.state == 1 then
            DialogManager.ShowToastByLang("bought")
            return
        end
        if self.buyBtnClick then
            self:ShowDetail(self.costId)
        end
    end)
end

function FreshPlayerLevelItemView:InitView(boxData, freshPlayerLevelModel, buyBtnClick, onTimeOut)
    self.boxData = boxData
    self.index = boxData.index
    self.freshPlayerLevelModel = freshPlayerLevelModel
    self.buyBtnClick = buyBtnClick
    self.onTimeOut = onTimeOut
    self.freeData = boxData.pageContent[BuyType.Free]
    self.costData = boxData.pageContent[BuyType.Cost]
    local level = self.freeData.staticData.level
    self.freeId = self.freeData.id
    self.costId = self.costData.id
    self.freeTitleTxt.text = self.freeData.staticData.desc
    self.costTitleTxt.text = self.costData.staticData.desc

    if self.freeData.cacheData.state == 0 then
        self.freeTxt.text = lang.trans("ladder_btnReceive")
        self.freeButton.interactable = true
    else
        self.freeTxt.text = lang.trans("have_received")
        self.freeButton.interactable = false
    end

    if self.costData.cacheData.state == 0 then
        self.costTxt.text = lang.trans("buy")
        self.costButton.interactable = true
    else
        self.costTxt.text = lang.trans("bought")
        self.costButton.interactable = false
    end

    self.titleTxt.text = lang.trans("time_limit_level_box", level)
    self:RefreshTimeArea()
end

function FreshPlayerLevelItemView:ShowDetail(id)
    local remainTime = self.freshPlayerLevelModel:GetRemainTimeById(id)
    if remainTime < 1 then
        DialogManager.ShowToastByLang("belatedGift_item_nil_time")
        return
    end
    self.freshPlayerLevelModel:SetPageIndex(self.index)
    local ctrlPath = "ui.controllers.freshPlayerLevel.FreshPlayerLevelBuyCtrl"
    res.PushDialog(ctrlPath, id, self.buyBtnClick)
end

function FreshPlayerLevelItemView:RefreshTimeArea()
    local firstKey, firstData = next(self.boxData.pageContent)
    local id = firstData.id
    local remainTime = self.freshPlayerLevelModel:GetRemainTimeById(id)
    if remainTime < 1 then
        self.timeTxt.text = lang.trans("belatedGift_item_nil_time")
        return
    end
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
        self.countDownTimer = nil
    end
    self.countDownTimer = Timer.new(remainTime, function(time)
        if time > 1 then
            self.timeTxt.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
        else
            self.timeTxt.text = lang.trans("belatedGift_item_nil_time")
            if self.onTimeOut then
                self.freshPlayerLevelModel:SetPageIndex(1)
                self.onTimeOut()
            end
        end
    end)
end

function FreshPlayerLevelItemView:GetBtnTxtByState(state)
    if state == 0 then
        return lang.trans("friends_manager_item_viewDetail")
    else
        return lang.trans("have_received")
    end
end

function FreshPlayerLevelItemView:onDestroy()
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
        self.countDownTimer = nil
    end
end

return FreshPlayerLevelItemView
