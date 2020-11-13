local Model = require("ui.models.Model")
local DiscussHotTopicModel = class(Model, "DiscussHotTopicModel")


function DiscussHotTopicModel:ctor(hotTopicList)
    if type(hotTopicList) ~= "table" then
        hotTopicList = {}
    end
    if hotTopicList then
        table.sort(hotTopicList, function(a, b) return a.topicId < b.topicId end)
    else
        hotTopicList = {}
    end
    self.hotTopicList = hotTopicList
    self.hotTopicContentList = {}
    self.hotTopicContentReplyList = {}
    self.newTopicContentList = {}
    self.newTopicContentReplyList = {}

    self.currTopicIndex = 1
end

-- 设置热门话题列表中当前选中的话题
function DiscussHotTopicModel:SetCurrHotTopicListIndex(index)
    self.currTopicIndex = index
end

-- 获取热门话题列表中当前选中的话题
function DiscussHotTopicModel:GetCurrHotTopicList()
    return self.hotTopicList[self.currTopicIndex]
end

-- 获取热门话题列表中当前选中的话题的索引
function DiscussHotTopicModel:GetCurrHotTopicListIndex()
    return self.currTopicIndex
end

-- 获取热门话题列表的第一个
function DiscussHotTopicModel:GetFirstHotTopicList()
    return self.hotTopicList[1]
end

-- 获取话题列表
function DiscussHotTopicModel:GetHotTopicList()
    return self.hotTopicList
end

-- 设置热门话题内容
function DiscussHotTopicModel:SetHotTopicContent(topicId, content)
    self.hotTopicContentList[topicId] = {}
    if content then
        content = self:AddAllTimeData(content)
        table.sort(content, function(a, b)
            if a.score == b.score then
                return a.c_t > b.c_t
            else
                return a.score > b.score
            end
        end)
        self.hotTopicContentList[topicId] = content
    end
end

-- 添加热门话题内容
function DiscussHotTopicModel:AddHotTopicContent(topicId, content)
    local length = self:GetHotTopicContentLength()
    if self.hotTopicContentList and length >= 100 then
        return
    end
    content = self:AddSingleTimeData(content)
    local tempContent = self.hotTopicContentList[topicId]
    table.insert(tempContent, content)
    table.sort(tempContent, function(a, b)
        if a.score == b.score then
            return a.c_t > b.c_t
        else
            return a.score > b.score
        end
    end)
    self.hotTopicContentList[topicId] = tempContent
end

-- 添加多个热门话题内容
function DiscussHotTopicModel:AddHotTopicContents(topicId, contents)
    local length = self:GetHotTopicContentLength(topicId) or 0
    if self.hotTopicContentList and length >= 100 then
        return
    end
    contents = self:AddAllTimeData(contents)
    local tempContent = self.hotTopicContentList[topicId]
    if not tempContent then
        self.hotTopicContentList[topicId] = {}
        tempContent = {}
    end
    for k,v in pairs(contents) do
        if not self:CheckContainCommentId(tempContent, v) then
            table.insert(tempContent, v)
        end
    end
    table.sort(tempContent, function(a, b)
        if a.score == b.score then
            return a.c_t > b.c_t
        else
            return a.score > b.score
        end
    end)
    self.hotTopicContentList[topicId] = tempContent
end

-- 获取热门话题内容
function DiscussHotTopicModel:GetHotTopicContent(topicId)
   return self.hotTopicContentList[topicId]
end

-- 获取热门话题内容的长度
function DiscussHotTopicModel:GetHotTopicContentLength(topicId)
    if self.hotTopicContentList[topicId] then
        return #self.hotTopicContentList[topicId]
    else
       return 0
    end
end

-- 根据话题id 和 评论id 设置话题的回复内容
function DiscussHotTopicModel:SetHotTopicContentReply(topicId, topicContentId, replyContent)
    if not self.hotTopicContentReplyList[topicId] then
        self.hotTopicContentReplyList[topicId] = {}
    end
    if not self.hotTopicContentReplyList[topicId][topicContentId] then
        self.hotTopicContentReplyList[topicId][topicContentId] = {}
    end
    if replyContent then
        replyContent = self:AddAllTimeData(replyContent)
        self.hotTopicContentReplyList[topicId][topicContentId] = replyContent
    end
end

-- 根据话题id 和 评论id 添加话题的回复内容
function DiscussHotTopicModel:AddHotTopicContentReply(topicId, topicContentId, replyContent)
    replyContent = self:AddSingleTimeData(replyContent)
    if not self.hotTopicContentReplyList[topicId] then
        self.hotTopicContentReplyList[topicId] = {}
    end
    if not self.hotTopicContentReplyList[topicId][topicContentId] then
        self.hotTopicContentReplyList[topicId][topicContentId] = {}
    end
    local tempContent = self.hotTopicContentReplyList[topicId][topicContentId]
    table.insert(tempContent, replyContent)
    table.sort(tempContent, function(a, b) return a.c_t < b.c_t end)
    self.hotTopicContentReplyList[topicId][topicContentId] = tempContent
end

-- 根据热门话题id 和 评论id 获取回复内容
function DiscussHotTopicModel:GetHotTopicContentReply(topicId, topicContentId)
    if not self.hotTopicContentReplyList[topicId] then
        return nil
    end
    if not self.hotTopicContentReplyList[topicId][topicContentId] then
        return nil
    end
    return self.hotTopicContentReplyList[topicId][topicContentId]
end

-- 设置最新话题内容
function DiscussHotTopicModel:SetNewTopicContent(topicId, content)
    self.newTopicContentList[topicId] = {}
    if content then
        content = self:AddAllTimeData(content)
        table.sort(content, function(a, b) return a.c_t > b.c_t end)
        self.newTopicContentList[topicId] = content
    end
end

-- 添加最新话题内容
function DiscussHotTopicModel:AddNewTopicContent(topicId, content)
    content = self:AddSingleTimeData(content)
    local tempContent = self.newTopicContentList[topicId]
    table.insert(tempContent, content)
    table.sort(tempContent, function(a, b) return a.c_t > b.c_t end)
    self.newTopicContentList[topicId] = tempContent
end

-- 添加多个最新话题内容
function DiscussHotTopicModel:AddNewTopicContents(topicId, contents)
    contents = self:AddAllTimeData(contents)
    local tempContent = self.newTopicContentList[topicId]
    if not tempContent then
        self.newTopicContentList[topicId] = {}
        tempContent = {}
    end
    for k,v in pairs(contents) do
        if not self:CheckContainCommentId(tempContent, v) then
            table.insert(tempContent, v)
        end
    end
    table.sort(tempContent, function(a, b) return a.c_t > b.c_t end)
    self.newTopicContentList[topicId] = tempContent
end

-- 获取最新话题内容
function DiscussHotTopicModel:GetNewTopicContent(topicId)
   return self.newTopicContentList[topicId]
end

-- 获取最新话题内容的长度
function DiscussHotTopicModel:GetNewTopicContentLength(topicId)
    if self.newTopicContentList[topicId] then
        return #self.newTopicContentList[topicId]
    else
        return 0
    end
end

-- 根据最新话题id 和 评论id 设置话题的回复内容
function DiscussHotTopicModel:SetNewTopicContentReply(topicId, topicContentId, replyContent)
    if not self.newTopicContentReplyList[topicId] then
        self.newTopicContentReplyList[topicId] = {}
    end
    if not self.newTopicContentReplyList[topicId][topicContentId] then
        self.newTopicContentReplyList[topicId][topicContentId] = {}
    end
    if replyContent then
        replyContent = self:AddAllTimeData(replyContent)
        self.newTopicContentReplyList[topicId][topicContentId] = replyContent
    end
end

-- 根据最新话题id 和 评论id 添加话题的回复内容
function DiscussHotTopicModel:AddNewTopicContentReply(topicId, topicContentId, replyContent)
    replyContent = self:AddSingleTimeData(replyContent)
    if not self.newTopicContentReplyList[topicId] then
        self.newTopicContentReplyList[topicId] = {}
    end
    if not self.newTopicContentReplyList[topicId][topicContentId] then
        self.newTopicContentReplyList[topicId][topicContentId] = {}
    end
    local tempContent = self.newTopicContentReplyList[topicId][topicContentId]
    table.insert(tempContent, replyContent)
    table.sort(tempContent, function(a, b) return a.c_t < b.c_t end)
    self.newTopicContentReplyList[topicId][topicContentId] = tempContent
    return tempContent
end

-- 根据最新话题id 和 评论id 获取回复内容
function DiscussHotTopicModel:GetNewTopicContentReply(topicId, topicContentId)
    if not self.newTopicContentReplyList[topicId] then
        return nil
    end
    if not self.newTopicContentReplyList[topicId][topicContentId] then
        return nil
    end
    return self.newTopicContentReplyList[topicId][topicContentId]
end

function DiscussHotTopicModel:RefreshAgreeCountByCommentId(commentId, count)
    self:AgreeScoreAndCount(self.hotTopicContentList, commentId, count)
    self:AgreeScoreAndCount(self.newTopicContentList, commentId, count)
end

function DiscussHotTopicModel:RefreshDisagreeCountByCommentId(commentId, count)
    self:DisagreeScoreAndCount(self.hotTopicContentList, commentId, count)
    self:DisagreeScoreAndCount(self.newTopicContentList, commentId, count)
end

function DiscussHotTopicModel:SetCid(cid)
    self.cid = cid
end

function DiscussHotTopicModel:GetCid(cid)
    return self.cid
end

-- 添加多条评论的时间
function DiscussHotTopicModel:AddAllTimeData(contents)
    for i,v in ipairs(contents) do
        v.sendTime = self:FormatTimestamp(v.c_t)
    end
    return contents
end

-- 添加单条评论的时间
function DiscussHotTopicModel:AddSingleTimeData(content)
    content.sendTime = self:FormatTimestamp(content.c_t)
    return content
end

-- 时间的转换
function DiscussHotTopicModel:FormatTimestamp(timestamp)
    local year = os.date("%Y", timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    local hour = os.date("%H", timestamp)
    local minute = os.date("%M", timestamp)
    return year.. "-" .. month .. "-" .. day .. "  " .. hour .. ":" .. minute
end

-- table contains
function DiscussHotTopicModel:CheckContainCommentId(oldContents, newContent)
    for k,v in pairs(oldContents) do
        if v.commentId == newContent.commentId then
            return true
        end
    end
    return false
end

-- 分享
function DiscussHotTopicModel:GetShareContent()
    local reply = {}

    for k,v in pairs(self.hotTopicContentList) do
        for key, value in ipairs(v) do
            if value then
                table.insert(reply, value.content)
            end
        end
        return reply
    end
end

function DiscussHotTopicModel:DisagreeScoreAndCount(commentList, commentId, count)
    for k,v in pairs(commentList) do
        for key,value in pairs(v) do
            if value.commentId == commentId then
                value.disagreeCount = count
                value.score  = value.score + 1
                return true
            end
        end
    end
    return false
end

function DiscussHotTopicModel:AgreeScoreAndCount(commentList, commentId, count)
    for k,v in pairs(commentList) do
        for key,value in pairs(v) do
            if value.commentId == commentId then
                value.agreeCount = count
                value.score  = value.score + 3
                return true
            end
        end
    end
    return false
end
return DiscussHotTopicModel
