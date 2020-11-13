local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local TeamLogoButtonCtrl = class()

function TeamLogoButtonCtrl:ctor()
    self:CreateView()
end

function TeamLogoButtonCtrl:CreateView()
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Team/Prefab/TeamLogoButton.prefab")
    self.view = spt
    self.view.ctrl = self
end

function TeamLogoButtonCtrl:Init(data, isShowBase)
    self.data = data
    if data then
        self.view.ctrl = self
        if not self.teamLogoCtrl then
            self.teamLogoCtrl = TeamLogoCtrl.new()
            self.view:Init(self.teamLogoCtrl.view)
        end
        self.teamLogoCtrl:Init(data, isShowBase)
        self.view:SetExist()
    else
        self.view:SetEmpty()
    end
end

function TeamLogoButtonCtrl:PlayAppearAnimationWithImageOnly()
    self.view:PlayAppearAnimationWithImageOnly()
end

function TeamLogoButtonCtrl:PlayAppearAnimation()
    self.view:PlayAppearAnimation()
end

function TeamLogoButtonCtrl:PlayDisappearAnimation()
    self.view:PlayDisappearAnimation()
end

function TeamLogoButtonCtrl:PlaySelectAnimation()
    self.view:PlaySelectAnimation()
end

function TeamLogoButtonCtrl:StopAnimation()
    self.view:StopAnimation()
end

function TeamLogoButtonCtrl:RegOnButtonClick(func)
    if type(func) == "function" then
        self.view:regOnButtonClick(function()
            func(self.data)
        end)
    end
end

function TeamLogoButtonCtrl:Hide()
    self.view:Hide()
end

return TeamLogoButtonCtrl
