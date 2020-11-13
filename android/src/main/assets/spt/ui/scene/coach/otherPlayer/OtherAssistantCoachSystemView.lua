local AssistantCoachSystemView = require("ui.scene.coach.assistantSystem.AssistantCoachSystemView")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local OtherAssistantCoachSystemView = class(AssistantCoachSystemView, "OtherAssistantCoachSystemView")

function OtherAssistantCoachSystemView:ctor()
    -- 资源框
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 菜单按钮
    self.menuGroup = self.___ex.menuGroup
    -- 书页控制脚本
    self.bookView = self.___ex.bookView
    self.objBorderL = self.___ex.objBorderL
    self.objBorderR = self.___ex.objBorderR
    -- 返回按钮
    self.btnBack = self.___ex.btnBack

    -- 教练头像控制脚本
    self.portraitSpt = nil
end

function OtherAssistantCoachSystemView:start()
    self:RegBtnEvent()
end

function OtherAssistantCoachSystemView:RegBtnEvent()
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
end

function OtherAssistantCoachSystemView:InitView(otherAssistantCoachSystemModel)
    self.model = otherAssistantCoachSystemModel

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
    self.bookView:InitView(self.model, true)
end

function OtherAssistantCoachSystemView:OnEnterScene()
end

function OtherAssistantCoachSystemView:OnExitScene()
end

-- 点击返回
function OtherAssistantCoachSystemView:OnBtnBackClick()
    if self.onBtnBackClick and type(self.onBtnBackClick) == "function" then
        self.onBtnBackClick()
    end
end

return OtherAssistantCoachSystemView
