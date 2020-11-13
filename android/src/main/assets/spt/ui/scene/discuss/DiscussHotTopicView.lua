local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local DiscussHotTopicView = class(unity.base)

function DiscussHotTopicView:ctor()
    self.discussContentParent = self.___ex.discussContentParent
    self.topicHotParent = self.___ex.topicHotParent
    self.groupBtn = self.___ex.groupBtn
    self.contentView = self.___ex.contentView
    self.close = self.___ex.close

    self.close:regOnButtonClick(
        function()
            self:Close()
        end
    )
    DialogAnimation.Appear(self.transform, nil)
end

function DiscussHotTopicView:InitView(discussHotTopicModel)
    self.discussHotTopicModel = discussHotTopicModel
    local topicList = discussHotTopicModel:GetHotTopicList()
    self.groupBtn:CreateMenuItems(
        topicList,
        function(spt, value, index)
            spt:Init(value, index)
        end,
        function(value, index)
            self:OnMenuItemClick(value.topicId, index)
        end
    )
    local currTopic = discussHotTopicModel:GetCurrHotTopicList()
    if currTopic then
        self.contentView:Init(currTopic.topicId, nil, self.discussHotTopicModel)
        self.groupBtn:selectMenuItem(discussHotTopicModel:GetCurrHotTopicListIndex())
    else
        local firstTopic = discussHotTopicModel:GetFirstHotTopicList()
        local firstTopicIndex = 1
        if firstTopic then
            self.contentView:Init(firstTopic.topicId, nil, self.discussHotTopicModel)
            self.groupBtn:selectMenuItem(firstTopicIndex)
        end
    end
end

function DiscussHotTopicView:OnMenuItemClick(topicId, index)
    if self.onMenuItemClick then
        self.onMenuItemClick(topicId, index)
    end
    self.contentView:Init(topicId, index, self.discussHotTopicModel)
end

function DiscussHotTopicView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(
            self.transform,
            nil,
            function()
                if type(self.closeCallback) == "function" then
                    self.closeCallback()
                end
                self.closeDialog()
            end
        )
    end
end

return DiscussHotTopicView
