local GameObjectHelper = require("ui.common.GameObjectHelper")

local PlayerDetailLabelBtnView = class(unity.base)

-- 左侧单个label
function PlayerDetailLabelBtnView:ctor()
    self.btnLabel = self.___ex.btnLabel
    self.labelText = self.___ex.labelText
    self.selectButton = self.___ex.selectButton
    self.selLabeText = self.___ex.selLabeText
end

function PlayerDetailLabelBtnView:start()
    self.btnLabel:regOnButtonClick(function()
        if self.clickBack then
            self.clickBack()
        end
    end)
end

function PlayerDetailLabelBtnView:InitView(title)
    self.labelText.text = title
    self.selLabeText.text = title
    self:ChangeSelectState()
end

function PlayerDetailLabelBtnView:ChangeSelectState(isSelect)
    GameObjectHelper.FastSetActive(self.selectButton, isSelect)
    self.btnLabel:onPointEventHandle(not isSelect)
end

return PlayerDetailLabelBtnView
