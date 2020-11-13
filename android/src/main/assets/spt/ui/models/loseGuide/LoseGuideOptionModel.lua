local Model = require("ui.models.Model")
local LoseGuide = require("data.LoseGuide")

-- 球员信函数据模型
local LoseGuideOptionModel = class(Model, "LoseGuideOptionModel")

function LoseGuideOptionModel:ctor(optionID)
    self.optionID = optionID
    self.data = nil
    LoseGuideOptionModel.super.ctor(self)
end

function LoseGuideOptionModel:Init()
    self.data = LoseGuide[self.optionID]
end

--- 获取ID
-- @param string
function LoseGuideOptionModel:GetID()
    return self.optionID
end

--- 获取标题
-- @param string
function LoseGuideOptionModel:GetTitle()
    return self.data.title
end

--- 获取描述
-- @param string
function LoseGuideOptionModel:GetDesc()
    return self.data.desc
end

--- 获取图片索引
-- @param string
function LoseGuideOptionModel:GetPicIndex()
    return self.data.picIndex
end

--- 获取跳转页面名称
-- @param string
function LoseGuideOptionModel:GetTargetPageName()
    return self.data.jump
end

return LoseGuideOptionModel