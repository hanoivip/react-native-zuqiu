local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local DiscussMainItenView = class(unity.base)

function DiscussMainItenView:ctor()
    self.detailBtn = self.___ex.detailBtn
    self.playerIcon = self.___ex.playerIcon
    self.server = self.___ex.server
    self.playerName = self.___ex.playerName
    self.mainContent = self.___ex.mainContent
    self.discussTime = self.___ex.discussTime
    self.upBtn = self.___ex.upBtn
    self.downBtn = self.___ex.downBtn
    self.upCount = self.___ex.upCount
    self.downCount = self.___ex.downCount
    self.replyCount = self.___ex.replyCount
end

function DiscussMainItenView:InitView(discussContent, topicID, discussHotTopicModel)
    self.discussHotTopicModel = discussHotTopicModel
    self.server.text = discussContent.player.serverName
    self.playerName.text = discussContent.player.name
    self.mainContent.text = discussContent.content
    self.upCount.text = tostring(discussContent.agreeCount)
    self.downCount.text = tostring(discussContent.disagreeCount)
    self.replyCount.text = tostring(discussContent.allReplyCount)
    self.discussTime.text = tostring(discussContent.sendTime)
    self.commentId = discussContent.commentId
    self.discussContent = discussContent
    -- teamlogo的显示
    TeamLogoCtrl.BuildTeamLogo(self.playerIcon, discussContent.player.logo)
    self.upBtn:regOnButtonClick(
        function()
            self:OnUpClick()
        end
    )
    self.downBtn:regOnButtonClick(
        function()
            self:OnDownClick()
        end
    )
    self.detailBtn:regOnButtonClick(
        function()
            self:OnDetailClick()
        end
    )
end

function DiscussMainItenView:OnUpClick()
    clr.coroutine(function()
        local response = req.agreeComment(self.commentId)
        if api.success(response) then
            local data = response.val
            self.upCount.text = tostring(data.count)
            self.discussHotTopicModel:RefreshAgreeCountByCommentId(self.commentId, data.count)
        end
    end)
end

function DiscussMainItenView:OnDownClick()
    clr.coroutine(function()
        local response = req.disagreeComment(self.commentId)
        if api.success(response) then
            local data = response.val
            self.downCount.text = tostring(data.count)
            self.discussHotTopicModel:RefreshDisagreeCountByCommentId(self.commentId, data.count)
        end
    end)
end

function DiscussMainItenView:OnDetailClick()
    res.PushDialog("ui.controllers.discuss.DiscussDetailCtrl", self.discussContent, self.commentId)
end

return DiscussMainItenView
