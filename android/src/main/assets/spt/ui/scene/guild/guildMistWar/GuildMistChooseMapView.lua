local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Text = clr.UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildMistChooseMapView = class(unity.base)

function GuildMistChooseMapView:ctor()
--------Start_Auto_Generate--------
    self.menuGroupSpt = self.___ex.menuGroupSpt
    self.closeBtn = self.___ex.closeBtn
    self.mapScrollSpt = self.___ex.mapScrollSpt
--------End_Auto_Generate----------
    self.defaultTag = 0
end

function GuildMistChooseMapView:start()
    self:RegOnBtn()
    DialogAnimation.Appear(self.transform, nil)
end

function GuildMistChooseMapView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GuildMistChooseMapView:InitView(guildMistChooseMapModel)
    self.model = guildMistChooseMapModel
    self:InitTabList()
    self.menuGroupSpt:selectMenuItem(self.defaultTag)
    self:OnFilterTagClick(self.defaultTag)
    self:InitScrollView(self.defaultTag)
end

function GuildMistChooseMapView:InitTabList()
    local tabList = self.model:GetTabList()
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

function GuildMistChooseMapView:InitScrollView(tag)
    local mapList = self.model:GetMapListByTag(tag)
    self.mapScrollSpt:InitView(mapList, self.onApplyClick)
end

function GuildMistChooseMapView:OnFilterTagClick(tag)
    self:InitScrollView(tag)
end

function GuildMistChooseMapView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildMistChooseMapView
