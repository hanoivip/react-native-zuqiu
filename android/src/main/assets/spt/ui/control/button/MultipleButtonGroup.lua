local ButtonGroup = require("ui.control.button.ButtonGroup")
local MultipleButtonGroup = class(ButtonGroup, "MultipleButtonGroup")

--[[
ButtonGroup的多选模式
    多选模式1 可选择多个button 每个button 再次点击后取消选中 CanMultipleSelect --> true
             选择结果通过 GetMultipleSelectTags 获取  （格式 {"tag1" = true, "tag2" = true, "tag3" = false}）

    多选模式2 可选择一个button 每个button 再次点击后取消选中 CanMultipleSelect --> false
             选择结果通过 GetSingleSelectTag 直接获取当前选择的tag
    ！！每个button必须绑定 BindMenuItem 回调 ！！
]]--

-- 选中指定tag的按钮
function MultipleButtonGroup:selectMenuItem(tag)
    if self.isMultiple then
        if self.selectTags[tag] then
            self.menu[tag]:unselectBtn()
        else
            self.menu[tag]:selectBtn()
        end
        self.selectTags[tag] = not self.selectTags[tag]
    else
        local menuBtn = self.menu[tag]
        if menuBtn and tag ~= self.currentMenuTag then
            if self.currentMenuTag then
                local oldMenuBtn = self.menu[self.currentMenuTag]
                oldMenuBtn:unselectBtn()
            end
            self.currentMenuTag = tag
            menuBtn:selectBtn()
        else
            menuBtn:unselectBtn()
            self.currentMenuTag = nil
        end
    end
end

-- 是否可以多选
function MultipleButtonGroup:CanMultipleSelect(isMultiple)
    self.isMultiple = isMultiple
    self:ClearSelectTags()
end

-- 清除当前选择的页签
function MultipleButtonGroup:ClearSelectTags()
    self.selectTags = {}
    self.currentMenuTag = nil
    for k, v in pairs(self.menu) do
        v:unselectBtn()
    end
end

-- 默认的页签(多选)
function MultipleButtonGroup:SetMultipleDefaultSelectTags(tags)
    tags = tags or {}
    for i, v in pairs(self.menu) do
        if tags[i] then
            v:selectBtn()
        else
            v:unselectBtn()
        end
    end
    self.selectTags = tags
end

-- 默认的页签(单选)
function MultipleButtonGroup:SetSingleDefaultSelectTag(tag)
    for i, v in pairs(self.menu) do
        if i == tag then
            v:selectBtn()
        else
            v:unselectBtn()
        end
    end
    self.currentMenuTag = tag
end

-- 当前选择的页签(多选)
function MultipleButtonGroup:GetMultipleSelectTags()
    return self.selectTags
end

-- 当前选择的页签(单选)
function MultipleButtonGroup:GetSingleSelectTag()
    return self.currentMenuTag
end

return MultipleButtonGroup
