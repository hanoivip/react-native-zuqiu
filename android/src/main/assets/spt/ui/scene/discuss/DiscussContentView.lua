local Vector2 = clr.UnityEngine.Vector2
local Quaternion = clr.UnityEngine.Quaternion
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")

local DiscussContentView = class(unity.base)

function DiscussContentView:ctor()
    self.contentHotObj = self.___ex.contentHotObj
    self.contentNewObj = self.___ex.contentNewObj
    self.scrollHotView = self.___ex.scrollHotView
    self.scrollNewView = self.___ex.scrollNewView
    self.switchBtn = self.___ex.switchBtn
    self.btnReplay = self.___ex.btnReplay
    self.inputText = self.___ex.inputText
    self.replyObj = self.___ex.replyObj
    self.inputObj = self.___ex.inputObj
    self.sendBtn = self.___ex.sendBtn
    self.closeReply = self.___ex.closeReply
    self.discussAnimator = self.___ex.discussAnimator
    self.hotViewRect = self.___ex.hotViewRect
    self.newViewRect = self.___ex.newViewRect
    self.contentRect = self.___ex.contentRect
    self.arrowRect = self.___ex.arrowRect
end

function DiscussContentView:Init(topicID, index, discussHotTopicModel)
    self.discussHotTopicModel = discussHotTopicModel
    GameObjectHelper.FastSetActive(self.inputObj, false)
    GameObjectHelper.FastSetActive(self.replyObj, true)
    self.topicID = topicID
    self.switchBtn:regOnButtonClick(
        function()
            if self.isDiscussNew then
                self:RefreshHot(topicID, 0, 10, true)
                self.discussAnimator:SetBool("isBack", false)  --Lua assist checked flag
                self.discussAnimator:SetBool("init", true)  --Lua assist checked flag
                self.isDiscussNew = false
            else
                self:RefreshNew(topicID, 0, 10, true)
                self.discussAnimator:SetBool("isBack", true)  --Lua assist checked flag
                self.discussAnimator:SetBool("init", true)  --Lua assist checked flag
                self.isDiscussNew = true
            end
        end
    )

    self.btnReplay:regOnButtonClick(
        function()
           GameObjectHelper.FastSetActive(self.replyObj, false)
           GameObjectHelper.FastSetActive(self.inputObj, true)
        end
    )

    for k,v in pairs(self.closeReply) do
        v:regOnButtonClick(
            function()
               GameObjectHelper.FastSetActive(self.replyObj, true)
               GameObjectHelper.FastSetActive(self.inputObj, false)
            end
        )
    end

    self.sendBtn:regOnButtonClick(
        function()
            local inputStr = tostring(self.inputText.text)
            if (not inputStr) or inputStr == "" then
                DialogManager.ShowToastByLang("empty_reply_discuss")
                return
            end
            local message = self.inputText.text
            self.inputText.text = ""
            GameObjectHelper.FastSetActive(self.replyObj, true)
            GameObjectHelper.FastSetActive(self.inputObj, false)
            clr.coroutine(function()
                local response = req.addNormalComment(topicID, message)
                if api.success(response) then
                    self.discussHotTopicModel:AddHotTopicContent(topicID, response.val.comment)
                    self.discussHotTopicModel:AddNewTopicContent(topicID, response.val.comment)
                    self:RefreshHot(topicID)
                    self:RefreshNew(topicID)
                end
            end)
        end
    )

    self.scrollHotView:RegOnEndDrag(function(pos)
        self:OnHotEndDrag(pos) 
    end)
    self.scrollNewView:RegOnEndDrag(function(pos)
        self:OnNewEndDrag(pos) 
    end)
    self:RefreshHot(topicID)
    self:RefreshNew(topicID)
end

function DiscussContentView:RefreshHot(topicID, startIndex, num, isForceAdd)
    local topicHotContent = self.discussHotTopicModel:GetHotTopicContent(topicID)
    startIndex = startIndex or 0
    num = num or 10
    local getContent = function()
        clr.coroutine(function()
            local response = req.queryNormalHotComment(topicID, startIndex, num)
            if api.success(response) then
                hotDiscussList = response.val.commentList
                self.discussHotTopicModel:AddHotTopicContents(topicID, hotDiscussList)
                topicHotContent = self.discussHotTopicModel:GetHotTopicContent(topicID)
                self:SetHotDiscussView(topicHotContent, topicID, startIndex)
            end
        end)
    end
    if isForceAdd then
        getContent()
    end
    if topicHotContent then
        self:SetHotDiscussView(topicHotContent, topicID, startIndex)
    else
        getContent()
    end
end

function DiscussContentView:SetHotDiscussView(topicHotContent, topicID, startIndex)
    local pos = 1 - (startIndex / #topicHotContent)
    self.scrollHotView:InitView(topicHotContent, pos, topicID, self.discussHotTopicModel)
end

function DiscussContentView:RefreshNew(topicID, startIndex, num, isForceAdd)
    local topicNewContent = self.discussHotTopicModel:GetNewTopicContent(topicID)
    startIndex = startIndex or 0
    num = num or 10
    local getContent = function()
        clr.coroutine(function()
            local response = req.queryNormalNewComment(topicID, startIndex, num)
            if api.success(response) then
                newDiscussList = response.val.commentList
                self.discussHotTopicModel:AddNewTopicContents(topicID, newDiscussList)
                topicNewContent = self.discussHotTopicModel:GetNewTopicContent(topicID)
                self:SetNewDiscussView(topicNewContent, topicID, startIndex)
            end
        end)
    end
    if isForceAdd then
        getContent()
        return
    end
    if topicNewContent then
        self:SetNewDiscussView(topicNewContent, topicID, startIndex)
    else 
        getContent()
    end
end

function DiscussContentView:SetNewDiscussView(topicNewContent, topicID, startIndex)
    local pos = 1 - (startIndex / #topicNewContent)
    self.scrollNewView:InitView(topicNewContent, pos, topicID, self.discussHotTopicModel)
end

function DiscussContentView:RefreshContent(isAgree, commentId, count)
    if isAgree then
        self.discussHotTopicModel:RefreshAgreeCountByCommentId(commentId, count)
    else
        self.discussHotTopicModel:RefreshDisagreeCountByCommentId(commentId, count)
    end

    self:RefreshHot(self.topicID)
    self:RefreshNew(self.topicID)
end

function DiscussContentView:onEnable()
    EventSystem.AddEvent("DiscussContentView_RefreshContent", self, self.RefreshContent)
end

function DiscussContentView:onDisable()
    self:ResetToDiscussHotView()
    EventSystem.RemoveEvent("DiscussContentView_RefreshContent", self, self.RefreshContent)
end

function DiscussContentView:OnHotEndDrag(pos)
    if pos <= 0 then
        local startIndex = self.discussHotTopicModel:GetHotTopicContentLength(self.topicID) or 0
        self:RefreshHot(self.topicID, startIndex, 10, true)
    end
end

function DiscussContentView:OnNewEndDrag(pos)
    if pos <= 0 then
        local startIndex = self.discussHotTopicModel:GetNewTopicContentLength(self.topicID) or 0
        self:RefreshNew(self.topicID, startIndex, 10, true)
    end
end

-- 重新设置右侧显示为热门评论，球员评价界面使用
function DiscussContentView:ResetToDiscussHotView()
    self.discussAnimator:Rebind()  --Lua assist checked flag
    if self.contentRect then
        self.contentRect.anchoredPosition = Vector2(356.6, -6.5)
    end
    if self.arrowRect then
        self.arrowRect.anchoredPosition = Vector2(-32, 10.4)
        self.arrowRect.rotation = Quaternion.Euler(0, 0, 0)
    end
end

function DiscussContentView:SetDiscussViewPara(value)
    self.isDiscussNew = value
end

return DiscussContentView
