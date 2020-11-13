local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardIntroduceView = class(unity.base)

function GreenswardIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.tabAreaGo = self.___ex.tabAreaGo
    self.buttonGroupSpt = self.___ex.buttonGroupSpt
    self.contentTrans = self.___ex.contentTrans
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.introMap = {}
    self.introPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/"
end

function GreenswardIntroduceView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function GreenswardIntroduceView:InitView(greenswardIntroduceModel)
    self.model = greenswardIntroduceModel
    for i, v in pairs(self.buttonGroupSpt.menu) do
        self.buttonGroupSpt:BindMenuItem(i, function()
            self:OnTabClick(i)
        end)
    end
end

function GreenswardIntroduceView:RefreshView()
    local currTag = self.model:GetTab()
    self.buttonGroupSpt:selectMenuItem(currTag)
    self:OnTabClick(currTag)
    -- 控制那个tab显示
    self:SetTabListSate()
end

function GreenswardIntroduceView:OnTabClick(tag)
    local introSpt = self.introMap[tag]
    if not introSpt then
        local iPrefabPath = tag:gsub("^%l", string.upper)
        iPrefabPath = self.introPath .. iPrefabPath .. ".prefab"
        local obj, spt = res.Instantiate(iPrefabPath)
        obj.transform:SetParent(self.contentTrans, false)
        self.introMap[tag] = spt
        introSpt = spt
    end
    self.model:SetTab(tag)
    introSpt:InitView(self.model, self.model:GetRegion())
    for i, v in pairs(self.introMap) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    GameObjectHelper.FastSetActive(introSpt.gameObject, true)
    GameObjectHelper.FastSetActive(self.tabAreaGo, true)
end

function GreenswardIntroduceView:SetTabListSate()
    local tabStates = self.model:GetTabStates()
    if tabStates then
        for i, v in pairs(self.buttonGroupSpt.menu) do
            local state = tobool(tabStates[i])
            GameObjectHelper.FastSetActive(v.gameObject, state)
        end
    end
end

function GreenswardIntroduceView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GreenswardIntroduceView
