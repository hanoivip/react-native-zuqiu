local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Text = clr.UnityEngine.UI.Text
local GuildMistWarMap = require("data.GuildMistWarMap")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildMistPreviewMapView = class(unity.base)

function GuildMistPreviewMapView:ctor()
--------Start_Auto_Generate--------
    self.menuGroupSpt = self.___ex.menuGroupSpt
    self.closeBtn = self.___ex.closeBtn
    self.mapScrollSpt = self.___ex.mapScrollSpt
--------End_Auto_Generate----------
    self.defaultTag = 0
end

function GuildMistPreviewMapView:start()
    self:RegOnBtn()
    DialogAnimation.Appear(self.transform, nil)
end

function GuildMistPreviewMapView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GuildMistPreviewMapView:InitView()
    self:InitTabList()
    self.menuGroupSpt:selectMenuItem(self.defaultTag)
    self:OnFilterTagClick(self.defaultTag)
    self:InitScrollView(self.defaultTag)
end

function GuildMistPreviewMapView:InitTabList()
    local tabList = self:GetTabList()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistChooseMapTabItem.prefab"
    local tabORes = res.LoadRes(path)
    if not self.menuGroupSpt.menu then
        self.menuGroupSpt.menu = {}
        for i, v in ipairs(tabList) do
            local obj = Object.Instantiate(tabORes)
            obj.transform:SetParent(self.menuGroupSpt.transform, false)
            local tabSpt = obj:GetComponent("CapsUnityLuaBehav")
            self.menuGroupSpt.menu[v.count] = tabSpt
            self.menuGroupSpt:BindMenuItem(v.count, function() self:OnFilterTagClick(v.count) end)
            local tabTxt = obj:GetComponentInChildren(Text)
            if v.count <= 0 then
                tabTxt.text = lang.trans("guild_mist_all_map")
            else
                tabTxt.text = lang.trans("guild_mist_start_point", v.count)
            end
        end
    end
end

function GuildMistPreviewMapView:InitScrollView(tag)
    local mapList = self:GetMapListByTag(tag)
    self.mapScrollSpt:InitView(mapList)
end

function GuildMistPreviewMapView:OnFilterTagClick(tag)
    self:InitScrollView(tag)
end

function GuildMistPreviewMapView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

-- 筛选按钮列表 按照默认打开的格子个数进行筛选
-- 从表里取出所有可能的
-- 0 表示全部地图
function GuildMistPreviewMapView:GetTabList()
    local temp = {}
    temp.all = {count = 0}
    for i, v in pairs(GuildMistWarMap) do
        local default = v.default
        local defaultCount = #default
        temp[defaultCount] = {count = defaultCount}
    end
    local tabList = {}
    for i, v in pairs(temp) do
        table.insert(tabList, v)
    end
    table.sort(tabList, function(a, b) return a.count < b.count end)
    return tabList
end

-- tag 默认开启个数为tag的所有地图
function GuildMistPreviewMapView:GetMapListByTag(tag)
    local mapList = {}
    for i, v in pairs(GuildMistWarMap) do
        local default = v.default
        local defaultCount = #default
        local mapInfo = {}
        mapInfo.staticData = clone(v)
        if tag <= 0 then
            table.insert(mapList, mapInfo)
        else
            if tag == defaultCount then
                table.insert(mapList, mapInfo)
            end
        end
    end
    table.sort(mapList,function(a, b)
        return a.staticData.id < b.staticData.id
    end)
    return mapList
end

return GuildMistPreviewMapView
