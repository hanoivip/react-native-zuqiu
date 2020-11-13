local DiscussReplyItemView = class(unity.base)

function DiscussReplyItemView:ctor()
    self.replyName = self.___ex.replyName
    self.replyContent = self.___ex.replyContent
    self.playerServer = self.___ex.playerServer
    self.sendTime = self.___ex.sendTime
end

function DiscussReplyItemView:Init(detailData)
    self.replyName.text = detailData.player.name
    self.replyContent.text =detailData.content
    self.playerServer.text = detailData.player.serverName
    self.sendTime.text = detailData.sendTime
end

return DiscussReplyItemView
