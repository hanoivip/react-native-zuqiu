local Model = require("ui.models.Model")

-- 球员信函详情视图模型
local PlayerLetterDetailViewModel = class(Model, "PlayerLetterDetailViewModel")

function PlayerLetterDetailViewModel:ctor()
    self.viewData = nil
    self.model = nil
    self.super.ctor(self)
end

function PlayerLetterDetailViewModel:Init(data)
    if data == nil then
        data = {}
    end
    self.viewData = data
end

--- 获取PlayerLetterItemModel
-- @return PlayerLetterItemModel
function PlayerLetterDetailViewModel:GetModel()
    return self.model
end

--- 设置PlayerLetterItemModel，使ViewModel可以获取到数据
-- @param model PlayerLetterItemModel
function PlayerLetterDetailViewModel:SetModel(model)
    self.model = model
end

return PlayerLetterDetailViewModel