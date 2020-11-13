-- local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local Model = require("ui.models.Model")
local Introduce = require("data.Introduce")

local SimpleIntroduceModel = class(Model, "SimpleIntroduceModel")

function SimpleIntroduceModel:ctor(id, descId)
    -- 必填参数 --
    self.id = nil
    self.descId = nil
    if id ~= nil then self.id = id end
    if descId ~= nil then self.descId = descId end
    --------------

    -- 说明数据
    self.intro = {}
    self.intro.title = lang.trans("untranslated_2500")
    self.intro.introduce = lang.trans("untranslated_2500")

    -- 可选参数 --
    -- 面板大小
    self.width = 750
    self.height = 463
    -- 面板位置
    self.x = 0
    self.y = 0
    -- 关闭按钮
    self.showBtnClose = true

    SimpleIntroduceModel.super.ctor(self)
end

function SimpleIntroduceModel:Init()
    if self.id == nil or self.descId == nil then return end

    if Introduce then
        self.intro = Introduce[tostring(self.id)]
        if self.intro == nil or self.intro.descID ~= self.descId then
            -- descID与id不匹配
            self.intro = {}
            self.intro.title = lang.trans("untranslated_2500")
            self.intro.introduce = lang.trans("untranslated_2500")
        end
    end
end

function SimpleIntroduceModel:InitModel(id, descId)
    self.id = id or ""
    self.descId = descId or ""

    self:Init()
end

-- 获取说明id
function SimpleIntroduceModel:GetID()
    return self.id or ""
end

-- 获取说明descID
function SimpleIntroduceModel:GetDescID()
    return self.descId or ""
end

-- 获取说明配置的标题
function SimpleIntroduceModel:GetTitle()
    return self.intro.title
end

-- 获取说明配置内容
function SimpleIntroduceModel:GetIntro()
    return self.intro.introduce
end

-- 获得面板大小
function SimpleIntroduceModel:GetBoardSize()
    return self.width, self.height
end

-- 设置面板大小
function SimpleIntroduceModel:SetBoardSize(width, height)
    self.width = width
    self.height = height
end

-- 获得面板位置
function SimpleIntroduceModel:GetBoardPos()
    return self.x, self.y
end

-- 设置得面板位置
function SimpleIntroduceModel:SetBoardPos(x, y)
    self.x = x
    self.y = y
end

-- 是否显示关闭按钮
function SimpleIntroduceModel:IsShowBtnClose()
    return self.showBtnClose
end

-- 设置是否显示关闭按钮
function SimpleIntroduceModel:SetShowBtnClose(isShow)
    self.showBtnClose = isShow
end

return SimpleIntroduceModel
