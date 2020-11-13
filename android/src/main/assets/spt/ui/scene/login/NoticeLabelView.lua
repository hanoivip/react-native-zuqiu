local GameObjectHelper = require("ui.common.GameObjectHelper")

local NoticeLabelView = class(unity.base)

-- 左侧单个label
function NoticeLabelView:ctor()
    self.btnLabel = self.___ex.btnLabel
    self.labelText = self.___ex.labelText
    self.selectButton = self.___ex.selectButton
    self.selLabeText = self.___ex.selLabeText

    self.isFirstRead = true
end

function NoticeLabelView:start()
    self.btnLabel:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function NoticeLabelView:InitView(data)
    self.labelText.text = data.title
    self.selLabeText.text = data.title
    self:ChangeSelectState()
end

function NoticeLabelView:ChangeSelectState(isSelect)
    GameObjectHelper.FastSetActive(self.selectButton, isSelect)
    self.btnLabel:onPointEventHandle(not isSelect)
end

function NoticeLabelView:OnBtnClick()
    if self.clickBack then
        self.clickBack()
    end
end

return NoticeLabelView
