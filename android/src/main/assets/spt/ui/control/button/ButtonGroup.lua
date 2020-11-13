local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local ButtonGroup = class(unity.base)
local GameObjectHelper = require("ui.common.GameObjectHelper")

function ButtonGroup:ctor()
    self.menu = self.___ex.menu
end

-- 选中指定tag的按钮
function ButtonGroup:selectMenuItem(tag)
    local menuBtn = self.menu[tag]
    if menuBtn and tag ~= self.currentMenuTag then
        if self.currentMenuTag then
            local oldMenuBtn = self.menu[self.currentMenuTag]
            oldMenuBtn:unselectBtn()
            oldMenuBtn:onPointEventHandle(true)
        end
        self.currentMenuTag = tag
        menuBtn:selectBtn()
        menuBtn:onPointEventHandle(false)
    end
end

function ButtonGroup:start()
    if type(self.menu) == 'table' then
        for k, v in pairs(self.menu) do
            local menuTag = k
            local menuBtn = v
            v:selectWhenClick()
            v:regOnButtonClick('changeState', function(eventData)
                self:selectMenuItem(menuTag)
            end)
        end
    end
end

function ButtonGroup:BindMenuItem(tag, callback)
    local menuBtn = self.menu[tag]
    if menuBtn then
        menuBtn:selectWhenClick()
        menuBtn:regOnButtonClick(function ()
            if type(callback) == "function" then
                return callback()
            end
        end)
        menuBtn:regOnButtonClick('changeState', function ()
            self:selectMenuItem(tag)
        end)
    end
end

-- create items with list of data and a template
-- @param list: models of each item, must be an array
-- @param initFunc: callback for init item, with three params: spt, model of item, index of item
-- @param callback: callback for button click, with two params: model of item, index of item
function ButtonGroup:CreateMenuItems(list, initFunc, callback)
    assert(type(list) == "table")
    assert(type(initFunc) == "function")
    assert(self.transform.childCount >= 1)

    self.menu = {}

    for index, value in ipairs(list) do
        local obj
        if index <= self.transform.childCount then
            obj = self.transform:GetChild(index - 1).gameObject
        else
            obj = Object.Instantiate(self.transform:GetChild(0).gameObject)
            obj.transform:SetParent(self.transform, false)
        end

        GameObjectHelper.FastSetActive(obj, true)
        local spt = res.GetLuaScript(obj)
        initFunc(spt, value, index)
        self.menu[index] = spt
        self:BindMenuItem(
            index,
            function()
                if type(callback) == "function" then
                    return callback(value, index)
                end
            end
        )

    end

    for index = #list + 1, self.transform.childCount do
        GameObjectHelper.FastSetActive(self.transform:GetChild(index - 1).gameObject, false)
    end
end

function ButtonGroup:UnbindAll()
    if type(self.menu) == 'table' then
        for tag, btn in pairs(self.menu) do
            self:UnbindMenuItem(tag)
        end
    end
end

function ButtonGroup:UnbindMenuItem(tag)
    local menuBtn = self.menu[tag]
    if menuBtn then
        menuBtn:unRegOnButtonClick()
        menuBtn:unRegOnButtonClick('changeState')
    end
end

function ButtonGroup:GetMenuCount()
    local count = 0
    if self.menu then 
        count = table.nums(self.menu)
    end
    return count
end

-- 设置某button是否显示
function ButtonGroup:SetActive(tag, isActive)
    local menuBtn = self.menu[tag]
    if menuBtn then
        GameObjectHelper.FastSetActive(menuBtn.gameObject, isActive)
    end
end

return ButtonGroup
