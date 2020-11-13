local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityLabelModel = require("ui.models.activity.ActivityLabelModel")
local ActivityLabelCtrl = class()

function ActivityLabelCtrl:ctor(view, parentScript, activityRes, activityListModel)
    self.view = view
    self.parentScript = parentScript
    self.activityListModel = activityListModel
    self.activityRes = activityRes
    self.selectIndex = nil
    self.activityLabelModel = ActivityLabelModel.new()
    self.data = self.activityListModel:GetActivityList()
end 

function ActivityLabelCtrl:GetLabelModel()
    return self.activityLabelModel
end

function ActivityLabelCtrl:InitView(selectIndex)
    self.view:InitView(self.data, self.activityRes)
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

function ActivityLabelCtrl:ClickPreviousLabel()
    self.view:scrollToPreviousGroup()
end

function ActivityLabelCtrl:ClickNextLabel()
    self.view:scrollToNextGroup()
end

function ActivityLabelCtrl:ChangeLabel(index, isSelect)
    local labelScript = self.view:getItem(index)
    labelScript:ChangeSelectState(isSelect)
end

-- 所有label点击传递到ctrl管理
function ActivityLabelCtrl:ClickLabel(index)
    if self.selectIndex == index then return end

    if self.selectIndex then 
        self:ChangeLabel(self.selectIndex, false)
    end
    self:ChangeLabel(index, true)
    self.selectIndex = index
    self:RefreshContent()
    if self.view:getItem(index):IsFirstRead() and self.data[index].type ~= "Sign" then
        clr.coroutine(function ()
            local response = req.activityRead(self.data[index].type, self.data[index].id, nil, nil, true)
            if type(self.view.getItem) == "function" then
                self.view:getItem(index):SetReadState(false)
            end
        end)
    end

    self.activityLabelModel:SetSelectLabel(self.selectIndex)
end

function ActivityLabelCtrl:RefreshContent()
    self.parentScript:RefreshContent(self.selectIndex)
end

return ActivityLabelCtrl
