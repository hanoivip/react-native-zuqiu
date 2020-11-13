local Model = require("ui.models.Model")
local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")

-- 球员信函视图模型
local PlayerLetterViewModel = class(Model, "PlayerLetterViewModel")

function PlayerLetterViewModel:ctor()
    self.viewData = nil
    self.model = nil
    self.super.ctor(self)
end

function PlayerLetterViewModel:Init(data)
    if not data then
        data = cache.getPlayerLetterViewInfo()
        if data == nil then
            data = {}
        end
    end
    self.viewData = data
end

--- 获取PlayerLetterModel
-- @return PlayerLetterModel
function PlayerLetterViewModel:GetModel()
    return self.model
end

--- 设置PlayerLetterModel，使ViewModel可以获取到数据
-- @param model PlayerLetterModel
function PlayerLetterViewModel:SetModel(model)
    self.model = model
end

--- 获取标签类型
-- @return number
function PlayerLetterViewModel:GetTagType()
    return self.viewData.tagType or PlayerLetterConstants.TagType.NO_REPLY
end

--- 设置标签类型
-- @param tagType 标签类型
function PlayerLetterViewModel:SetTagType(tagType)
    self.viewData.tagType = tagType
    cache.setPlayerLetterViewInfo(self.viewData)
end

--- 获取滚动归一化位置
-- @return number
function PlayerLetterViewModel:GetScrollNormalizedPosition()
    return self.viewData.scrollNormalizedPosition or 1
end

--- 设置滚动归一化位置
-- @param scrollNormalizedPosition 滚动归一化位置
function PlayerLetterViewModel:SetScrollNormalizedPosition(scrollNormalizedPosition)
    self.viewData.scrollNormalizedPosition = scrollNormalizedPosition or 1
    cache.setPlayerLetterViewInfo(self.viewData)
end

--- 获取信件列表
-- @return table
function PlayerLetterViewModel:GetLetterList()
    if self:GetTagType() == PlayerLetterConstants.TagType.NO_REPLY then
        return self.model:GetNoReplyList()
    else
        return self.model:GetHaveReplyList()
    end
end

--- 获取第一个没被阅读的信件的索引
-- @return number
function PlayerLetterViewModel:GetIndexOfFirstNoRead()
    if self:GetTagType() == PlayerLetterConstants.TagType.NO_REPLY then
        --存储的是PlayerLetterItemModel
        local noReplyList = self.model:GetNoReplyList()
        for i, v in ipairs(noReplyList) do
            if v:GetReadState() == PlayerLetterConstants.LetterReadState.UNREAD then
                return i
            end
        end
    end
    return 1
end

return PlayerLetterViewModel