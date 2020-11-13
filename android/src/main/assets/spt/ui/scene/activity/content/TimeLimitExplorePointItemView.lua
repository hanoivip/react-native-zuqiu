local GameObjectHelper = require("ui.common.GameObjectHelper")
local TimeLimitExplorePointItemView = class(unity.base)

function TimeLimitExplorePointItemView:ctor()
    self.disableObj = self.___ex.disableObj
    self.enableObj = self.___ex.enableObj
    self.getObj = self.___ex.getObj
    self.progressNum = self.___ex.progressNum
    self.btnEnable = self.___ex.btnEnable
    self.btnDisable = self.___ex.btnDisable
    self.btnFinish = self.___ex.btnFinish
    self.enableAnim = self.___ex.enableAnim
end

function TimeLimitExplorePointItemView:start()
    --- 除领奖外其他状态点击均显示奖励信息
    self.btnDisable:regOnButtonClick(function()
        self.onItemButtonClick(false)
    end)
    self.btnFinish:regOnButtonClick(function()
        self.onItemButtonClick(false)
    end)    
    self.btnEnable:regOnButtonClick(function()
        self.onItemButtonClick(true, self.itemModel.subID)
    end)
    EventSystem.AddEvent("TimeLimitExplore.UpdatePointRewardInfo", self, self.UpdatePointRewardInfo)
end

function TimeLimitExplorePointItemView:InitView(itemModel)
    self.itemModel = itemModel
    self.progressNum.text = tostring(self.itemModel.condition)
    self:UpdatePointRewardInfo()
end

function TimeLimitExplorePointItemView:UpdatePointRewardInfo()
    self.disableObj:SetActive(self.itemModel.status == -1)
    self.enableObj:SetActive(self.itemModel.status == 0)
    if (self.itemModel.status == 0) then
        self.enableAnim:Play("CarnivalEnableBoxIdleAnimation", -1, 0)
    end
    self.getObj:SetActive(self.itemModel.status == 1)
end

function TimeLimitExplorePointItemView:onDestroy()
    EventSystem.RemoveEvent("TimeLimitExplore.UpdatePointRewardInfo", self, self.UpdatePointRewardInfo)
end


return TimeLimitExplorePointItemView
