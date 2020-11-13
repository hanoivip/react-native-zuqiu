local GameObjectHelper = require("ui.common.GameObjectHelper")
local CarnivalLabelView = class(unity.base)

function CarnivalLabelView:ctor()
    self.btnLabel =  self.___ex.btnLabel
    self.labelText = self.___ex.labelText
    self.selectObj = self.___ex.selectObj
    self.selectText = self.___ex.selectText
    self.lockObj = self.___ex.lockObj
    self.lockText = self.___ex.lockText
    self.redPoint = self.___ex.redPoint
end

function CarnivalLabelView:start()
    self.btnLabel:regOnButtonClick(function()
        self:OnButtonClick()
    end)
end

function CarnivalLabelView:InitView(data)
    self.data = data
    self.labelText.text = lang.trans("activity_day", self.data.dayIndex)
    self.selectText.text = lang.trans("activity_day", self.data.dayIndex)
    self.lockText.text = lang.trans("activity_day", self.data.dayIndex)
    GameObjectHelper.FastSetActive(self.lockObj, not self.data.isUnlock)
    self:UpdateRedPoint()
end

function CarnivalLabelView:UpdateRedPoint()
    if self.data ~= nil then
        GameObjectHelper.FastSetActive(self.redPoint, self.data.redPointCounter > 0)
    end
end

function CarnivalLabelView:ChangeButtonState(isSelect)
    GameObjectHelper.FastSetActive(self.selectObj, isSelect)
    self.btnLabel:onPointEventHandle(not isSelect)
end

function CarnivalLabelView:OnButtonClick()
    if self.clickButton then
        self:clickButton()
    end
end

return CarnivalLabelView