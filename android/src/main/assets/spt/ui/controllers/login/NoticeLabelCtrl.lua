local NoticeLabelCtrl = class()

-- 控制labelScroll的Ctrl
function NoticeLabelCtrl:ctor(view, parentScript, data)
    -- view 是 labelScroll
    self.view = view
    self.parentScript = parentScript
    self.selectIndex = nil
    self.data = data
end 

function NoticeLabelCtrl:InitView(selectIndex)
    self.view:InitView(self.data)
    self.view:scrollToCellImmediate(selectIndex)
    self:ClickLabel(selectIndex)

    self.view.clickLabel = function(index) 
        self:ClickLabel(index) 
    end
    self.view.clickPreviousLabel = function() 
        self:ClickPreviousLabel() 
    end
    self.view.clickNextLabel = function() 
        self:ClickNextLabel() 
    end
end

function NoticeLabelCtrl:ClickPreviousLabel()
    self.view:scrollToPreviousGroup()
end

function NoticeLabelCtrl:ClickNextLabel()
    self.view:scrollToNextGroup()
end

function NoticeLabelCtrl:ChangeLabel(index, isSelect)
    local labelScript = self.view:getItem(index)
    labelScript:ChangeSelectState(isSelect)
end

-- 所有label点击传递到ctrl管理
function NoticeLabelCtrl:ClickLabel(index)
    if self.selectIndex == index then return end
    
    if self.selectIndex then 
        self:ChangeLabel(self.selectIndex, false)
    end
    self:ChangeLabel(index, true)
    self.selectIndex = index
    self:RefreshContent()
end

function NoticeLabelCtrl:RefreshContent()
    self.parentScript:RefreshContent(self.selectIndex)
end

return NoticeLabelCtrl
