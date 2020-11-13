local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerTreasureCountItemView = class(unity.base)

function PlayerTreasureCountItemView:ctor()
    self.disableObj = self.___ex.disableObj
    self.enableObj = self.___ex.enableObj
    self.getObj = self.___ex.getObj
    self.progressNum = self.___ex.progressNum
    self.btnEnable = self.___ex.btnEnable
    self.btnDisable = self.___ex.btnDisable
    self.btnFinish = self.___ex.btnFinish
    self.enableAnim = self.___ex.enableAnim
end

function PlayerTreasureCountItemView:start()
    --- 除领奖外其他状态点击均显示奖励信息
    self.btnDisable:regOnButtonClick(function()
        self.onItemButtonClick()
    end)
    self.btnFinish:regOnButtonClick(function()
        self.onItemButtonClick()
    end)    
    self.btnEnable:regOnButtonClick(function()
        self.onItemButtonClick()
    end)
end

function PlayerTreasureCountItemView:InitView(countData, clickCallBack)
    self.onItemButtonClick = clickCallBack
    self.count = countData.count
    self.status = countData.status
    self.progressNum.text = tostring(self.count)
    self:UpdatePointRewardInfo()
end

function PlayerTreasureCountItemView:UpdatePointRewardInfo()
    self.disableObj:SetActive(self.status == -1)
    self.enableObj:SetActive(self.status == 0)
    if (self.status == 0) then
        self.enableAnim:Play("CarnivalEnableBoxIdleAnimation", -1, 0)
    end
    self.getObj:SetActive(self.status == 1)
end

return PlayerTreasureCountItemView
