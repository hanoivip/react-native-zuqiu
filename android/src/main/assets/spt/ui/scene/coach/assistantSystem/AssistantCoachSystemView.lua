local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachSystemView = class(unity.base, "AssistantCoachSystemView")

function AssistantCoachSystemView:ctor()
    -- 资源框
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 菜单按钮
    self.menuGroup = self.___ex.menuGroup
    -- 书页控制脚本
    self.bookView = self.___ex.bookView
    self.objBorderL = self.___ex.objBorderL
    self.objBorderR = self.___ex.objBorderR

    -- 教练头像控制脚本
    self.portraitSpt = nil
end

function AssistantCoachSystemView:start()
    self:RegBtnEvent()
end

function AssistantCoachSystemView:RegBtnEvent()
    self.bookView.onBtnSwitchTeam = function() self:OnBtnSwitchTeam() end
    self.bookView.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
    self.bookView.onBtnSelect = function() self:OnBtnSelect() end
    self.bookView.onBtnHire = function() self:OnBtnHire() end
end

function AssistantCoachSystemView:InitView(assistantCoachSystemModel)
    self.model = assistantCoachSystemModel

    local menus = self.model:GetTeams()
    local initFunc = function(spt, data, index)
        spt:InitView(data)
    end
    local callback = function(data, index)
        if self.onMenuClick and type(self.onMenuClick) == "function" then
            self.onMenuClick(index, data)
        end
    end
    self.menuGroup:CreateMenuItems(menus, initFunc, callback)
    self.bookView:InitView(self.model)
end

function AssistantCoachSystemView:RefreshView()
    self.menuGroup:selectMenuItem(self.model:GetCurrTeamIndex())
    self.bookView:RefreshView(self.model:GetCurrTeamIndex())
end

function AssistantCoachSystemView:OnEnterScene()
    EventSystem.AddEvent("AssistantCoach_UpdateAfterUpgrade", self, self.UpdateAfterUpgrade)
end

function AssistantCoachSystemView:OnExitScene()
    EventSystem.RemoveEvent("AssistantCoach_UpdateAfterUpgrade", self, self.UpdateAfterUpgrade)
end

function AssistantCoachSystemView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.menuGroup.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.bookView.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.objBorderL.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.objBorderR.gameObject, isShow)
end

function AssistantCoachSystemView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

-- 按钮事件
function AssistantCoachSystemView:OnBtnSwitchTeam()
    if self.onBtnSwitchTeam and type(self.onBtnSwitchTeam) == "function" then
        self.onBtnSwitchTeam()
    end
end

function AssistantCoachSystemView:OnBtnUpdateClick()
    if self.onBtnUpdateClick and type(self.onBtnUpdateClick) == "function" then
        self.onBtnUpdateClick()
    end
end

function AssistantCoachSystemView:OnBtnSelect()
    if self.onBtnSelect and type(self.onBtnSelect) == "function" then
        self.onBtnSelect()
    end
end

function AssistantCoachSystemView:OnBtnHire()
    if self.onBtnHire and type(self.onBtnHire) == "function" then
        self.onBtnHire()
    end
end

-- 升级后更新界面
function AssistantCoachSystemView:UpdateAfterUpgrade(data)
    self:RefreshView()
end

--- 跳转至特定章节
function AssistantCoachSystemView:GoToTeamByIndex(teamIdx, isScrollToStage, isPlayFlipAnim)
    self.bookView:GoToTeam(teamIdx, isScrollToStage, isPlayFlipAnim)
end

return AssistantCoachSystemView
