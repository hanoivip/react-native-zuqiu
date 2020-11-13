local DiscussHotTopicModel = require("ui.models.discuss.DiscussHotTopicModel")


local BaseCtrl = require("ui.controllers.BaseCtrl")

local DiscussHotTopicCtrl = class(BaseCtrl)

DiscussHotTopicCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Disscuss/HotTopic.prefab"

DiscussHotTopicCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false
}

function DiscussHotTopicCtrl:Init()
    self.view.onMenuItemClick = function(topicId, index) self:OnMenuItemClick(topicId, index) end
end

function DiscussHotTopicCtrl:Refresh(discussHotTopicModel)
    self.discussHotTopicModel = discussHotTopicModel
    self.view:InitView(self.discussHotTopicModel)
end

function DiscussHotTopicCtrl:OnMenuItemClick(topicId, index)
    local hotDiscussList = self.discussHotTopicModel:GetHotTopicContent(topicId)
    self.discussHotTopicModel:SetCurrHotTopicListIndex(index)
    if not hotDiscussList then
        clr.coroutine(function()
            local response = req.queryNormalHotComment(topicId, 0, 10)
            if api.success(response) then
                hotDiscussList = response.val.commentList
                self.discussHotTopicModel:SetHotTopicContent(topicId, hotDiscussList)
            end
        end)
    end
end

function DiscussHotTopicCtrl:GetStatusData()
    return self.discussHotTopicModel
end

return DiscussHotTopicCtrl
