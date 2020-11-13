local MatchDataItemView = class(unity.base)

function MatchDataItemView:ctor()
    -- 左边的文本
    self.leftText = self.___ex.leftText
    -- 右边的文本
    self.rightText = self.___ex.rightText
    -- 左边的要显示的文本
    self.leftStr = nil
    -- 右边要显示的文本
    self.rightStr = nil
end

function MatchDataItemView:InitView(leftStr, rightStr)
    self.leftStr = leftStr
    self.rightStr = rightStr
    self:BuildView()
end

function MatchDataItemView:BuildView()
    self.leftText.text = self.leftStr
    self.rightText.text = self.rightStr
end

return MatchDataItemView