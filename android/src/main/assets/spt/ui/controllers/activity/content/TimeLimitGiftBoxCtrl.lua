local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local TimeLimitGiftBoxCtrl = class(ActivityContentBaseCtrl)

function TimeLimitGiftBoxCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.clickOnlyOneTab = function() self:OnOnlyOneTab() end
    self:DoIfOnlyOneTab()
    self.view:InitView(self.activityModel)
end

function TimeLimitGiftBoxCtrl:OnRefresh()
end

function TimeLimitGiftBoxCtrl:DoIfOnlyOneTab()
    local tabDataList = self.activityModel:GetTabDataList()
    local tabNums = table.nums(tabDataList)
    assert(tabNums > 0, "data error!!!")
    local isShowOnlyOneTabBtn = tabNums == 1 and tabDataList[1].isFirstRead
    self.view:ShowOrHideOnlyOneTabBtn(isShowOnlyOneTabBtn)
end

function TimeLimitGiftBoxCtrl:OnOnlyOneTab()
    local tabTag = self.activityModel:GetSelectedTabTag()
    local hideOnlyOneTabBtn = function() self.view:ShowOrHideOnlyOneTabBtn(false) end
    self.view:AcknowledgeFirstReadAndRefresh(self.activityModel, tabTag, hideOnlyOneTabBtn)
end

function TimeLimitGiftBoxCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function TimeLimitGiftBoxCtrl:OnExitScene()
    self.view:OnExitScene()
end

return TimeLimitGiftBoxCtrl

