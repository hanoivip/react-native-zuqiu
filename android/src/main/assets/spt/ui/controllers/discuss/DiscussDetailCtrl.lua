local DiscussDetailModel = require("ui.models.discuss.DiscussDetailModel")
local EventSystem = require("EventSystem")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DiscussDetailCtrl = class(BaseCtrl)

DiscussDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Disscuss/DiscussDetail.prefab"
DiscussDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false
}

function DiscussDetailCtrl:Init(discussContent)
    self.view.sendMessage = function(message) self:OnSendMessage(message) end
    self.view.onUpClick = function() self:OnUpClick() end
    self.view.onDownClick = function() self:OnDownClick() end
end

function DiscussDetailCtrl:Refresh(discussContent)
    self.view:InitView(self.discussDetailModel)
end

function DiscussDetailCtrl:AheadRequest(discussContent, commentId)
    self.commentId = discussContent.commentId
    self.discussDetailModel = DiscussDetailModel.new(discussContent)
    local response = req.queryReplyComment(commentId, 0, 30)
    if api.success(response) then
        self.discussDetailModel:SetDiscussList(response.val.replyCommentList)
    end
end

function DiscussDetailCtrl:OnSendMessage(message)
    clr.coroutine(function()
        local response = req.replyComment(self.commentId, message)
        if api.success(response) then
            self.discussDetailModel:AddDiscussList(response.val.comment)
            local tempDetailList = self.discussDetailModel:GetDiscussList()
            self.view:RefreshDetailList(tempDetailList)
        end
    end)
end

function DiscussDetailCtrl:OnUpClick()
    clr.coroutine(function()
        local response = req.agreeComment(self.commentId)
        if api.success(response) then
            local data = response.val
            self.view.upCount.text = tostring(data.count)
            EventSystem.SendEvent("DiscussContentView_RefreshContent", true, self.commentId, data.count)
        end
    end)
end

function DiscussDetailCtrl:OnDownClick()
    clr.coroutine(function()
        local response = req.disagreeComment(self.commentId)
        if api.success(response) then
            local data = response.val
            self.view.downCount.text = tostring(data.count)
            EventSystem.SendEvent("DiscussContentView_RefreshContent", false, self.commentId, data.count)
        end
    end)
end

return DiscussDetailCtrl
