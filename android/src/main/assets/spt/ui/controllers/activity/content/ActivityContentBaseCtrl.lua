local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityContentBaseCtrl = class()
-- 每个单独活动的ctrl基类
function ActivityContentBaseCtrl:ctor(activityType, activityId, activityRes, parentRect, activityModel)
    self.activityType = activityType
    self.activityId = activityId
    self.activityRes = activityRes
    self.parentRect = parentRect
    self.activityModel = activityModel

    local contentPrefabRes = activityRes:GetActivityContent(activityType, activityId)
    if contentPrefabRes then 
        self.contentPrefab = Object.Instantiate(contentPrefabRes)
        self.contentPrefab.transform:SetParent(parentRect, false)
    end
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.activityModel:SetActivityView(self.view)
    self:InitWithProtocol()
end

function ActivityContentBaseCtrl:InitWithProtocol()
end

function ActivityContentBaseCtrl:ShowContent(isSelect)
    if self.contentPrefab then 
        GameObjectHelper.FastSetActive(self.contentPrefab, isSelect)
    end
end

function ActivityContentBaseCtrl:ResetCousume(func)
    if type(func) == "function" then
        func()
    end
end

function ActivityContentBaseCtrl:OnRefresh()
end

function ActivityContentBaseCtrl:OnEnterScene()
end

function ActivityContentBaseCtrl:OnExitScene()
end

return ActivityContentBaseCtrl
