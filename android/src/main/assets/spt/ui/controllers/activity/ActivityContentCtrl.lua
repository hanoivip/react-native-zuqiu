local ActivityContentCtrl = class()

function ActivityContentCtrl:ctor(parentRect, activityRes, activityListModel)
    self.activityListModel = activityListModel
    self.activityRes = activityRes
    self.parentRect = parentRect
    self.selectIndex = nil
    self.contentControllerMap = {}
    self.data = self.activityListModel:GetActivityList()
end 

function ActivityContentCtrl:ShowContent(index, isSelect)
    local selectContent = self.contentControllerMap[index]
    if selectContent then 
        selectContent:ShowContent(isSelect)
    end
end

local DefaultId = 1
function ActivityContentCtrl:ShowActivityContent(index)
    if self.selectIndex then
        self:ShowContent(self.selectIndex, false)
        self.contentControllerMap[self.selectIndex]:OnExitScene()
    end

    local currentContentController = self.contentControllerMap[index]
    if not currentContentController then 
        local activityData = self.data[index]
        local activityType = activityData["type"]
        local activityId = activityData["id"] or DefaultId
        self:CreateContent(index, activityType, activityId)
    else
        self:ShowContent(index, true)
        currentContentController:OnRefresh()
    end
    self.contentControllerMap[index]:OnEnterScene()
    self.selectIndex = index
end 

function ActivityContentCtrl:OnEnterScene()
    
end

function ActivityContentCtrl:OnExitScene()
    for k, ctrl in pairs(self.contentControllerMap) do
        ctrl:OnExitScene()
    end
end

function ActivityContentCtrl:CreateContent(index, activityType, activityId)
    local activityControllerPath = self.activityRes:GetActivityControllerPath(activityType, activityId)
    local activityModel = self.activityListModel:GetSingleModel(activityType, activityId)
    if not activityControllerPath then 
        activityControllerPath = "ui.controllers.activity.content.ActivityContentBaseCtrl"
    end
    local activityController = require(activityControllerPath).new(activityType, activityId, self.activityRes, self.parentRect, activityModel)
    self.contentControllerMap[index] = activityController
end

return ActivityContentCtrl
