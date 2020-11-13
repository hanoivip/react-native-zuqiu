local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CommonConstants = require("ui.models.activity.mascotPresent.CommonConstants")
local MascotPresentGiftView = class(unity.base)

function MascotPresentGiftView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.scrollView1 = self.___ex.scrollView1
    self.scrollView2 = self.___ex.scrollView2
    self.scrollView3 = self.___ex.scrollView3
    self.giftBox1 = self.___ex.giftBox1
    self.giftBox2 = self.___ex.giftBox2
    self.giftBox3 = self.___ex.giftBox3
    self.titleText = self.___ex.titleText
    self.view2Tip1 = self.___ex.view2Tip1
    self.view2Tip2 = self.___ex.view2Tip2
    self.view3Tip = self.___ex.view3Tip
    self.btnToView3 = self.___ex.btnToView3

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function MascotPresentGiftView:start()
    EventSystem.AddEvent("MascotPresent_UpdateActivityModel", self, self.UpdateActivityModel)

    self.btnToView3:regOnButtonClick(function()
        if type(self.clickToView3) == "function" then
            self.clickToView3()
        end 
    end)
end

function MascotPresentGiftView:InitView(mascotPresentModel, showType)
    self.activityModel = mascotPresentModel
    self:ShowViewOfShowType(showType)
    self:InitTextArea()
    self["scrollView"..tostring(showType)]:InitView(self.activityModel, showType)
end

local totalViewNum = 3
function MascotPresentGiftView:UpdateActivityModel(mascotPresentModel)
    local oldActivityModel = self.activityModel
    local giftBoxData = oldActivityModel:GetMascotPresentGiftBoxData()
    local clickCount = oldActivityModel:GetClickProgressItemCount()
    local orderedGiftBoxData = oldActivityModel:GetOrderedOwnedGiftBoxData()

    self.activityModel = mascotPresentModel
    self.activityModel:InitMascotPresentGiftBoxData(giftBoxData, clickCount)
    if type(orderedGiftBoxData) == "table" and next(orderedGiftBoxData) then
        self.activityModel:InitOrderedOwnedGiftBoxData(orderedGiftBoxData)
    end

    if type(self.refreshCtrlModel) == "function" then
        self.refreshCtrlModel(self.activityModel)
    end
    for i = 1, totalViewNum do
        self["scrollView"..tostring(i)].activityModel = mascotPresentModel
    end
end

function MascotPresentGiftView:ShowViewOfShowType(showType)
    self.showType = showType
    for i = 1, totalViewNum do
        GameObjectHelper.FastSetActive(self["giftBox" .. tostring(i)], i == showType)
    end
end

function MascotPresentGiftView:InitTextArea()
    local clickCount = self.activityModel:GetClickProgressItemCount()
    self.titleText.text = lang.transstr("mascotPresent_desc24", tostring(clickCount))
    self.view2Tip1.text = lang.transstr("mascotPresent_desc23", tostring(clickCount))
    self.view2Tip2.text = lang.transstr("mascotPresent_desc22", tostring(clickCount))
    self.view3Tip.text = lang.transstr("mascotPresent_desc22", tostring(clickCount))
end

function MascotPresentGiftView:Close()
    if self.showType == CommonConstants.COLLECTABLE_PREVIEW then
        self:ShowViewOfShowType(CommonConstants.COLLECTABLE)
        return
    end
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function MascotPresentGiftView:onDestroy()
    EventSystem.RemoveEvent("MascotPresent_UpdateActivityModel", self, self.UpdateActivityModel)
end

return MascotPresentGiftView