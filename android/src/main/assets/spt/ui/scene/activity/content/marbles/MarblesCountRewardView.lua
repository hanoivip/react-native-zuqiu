local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local EventSystem = require("EventSystem")
local MarblesCountRewardView = class(unity.base)

function MarblesCountRewardView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.countTxt = self.___ex.countTxt
    self.scrollViewSpt = self.___ex.scrollViewSpt
    self.exchangeTrans = self.___ex.exchangeTrans
    self.rewardTrans = self.___ex.rewardTrans
    self.exchangeBtn = self.___ex.exchangeBtn
    self.buyLimitTxt = self.___ex.buyLimitTxt
    self.soldOutGo = self.___ex.soldOutGo
    self.disableGo = self.___ex.disableGo
--------End_Auto_Generate----------
end

function MarblesCountRewardView:start()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function MarblesCountRewardView:InitView(marblesCountRewardModel)
    self.model = marblesCountRewardModel
    DialogAnimation.Appear(self.transform, nil)
    self:InitCount()
    res.ClearChildren(self.contentTrans)
    local countRewardList = self.model:GetCountRewardList()
    self.scrollViewSpt:InitView(countRewardList, self.getCountReward)
    self:RefreshContent()
end

function MarblesCountRewardView:RefreshContent()
    local scrollPos = self.scrollViewSpt:getScrollNormalizedPos()
    local countRewardList = self.model:GetCountRewardList()
    self.scrollViewSpt:refresh(countRewardList, scrollPos)
end

function MarblesCountRewardView:InitCount()
    local count = self.model:GetCurShootCount()
    self.countTxt.text = tostring(count)
end

function MarblesCountRewardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return MarblesCountRewardView
