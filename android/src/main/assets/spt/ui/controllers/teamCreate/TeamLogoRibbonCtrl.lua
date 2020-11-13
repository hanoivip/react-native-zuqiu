local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local TeamLogoRibbonCtrl = class()

function TeamLogoRibbonCtrl:ctor()
    self:CreateView()
end

function TeamLogoRibbonCtrl:CreateView()
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Team/Prefab/TeamLogoRibbon.prefab")
    self.view = spt
    self.view.ctrl = self
end

function TeamLogoRibbonCtrl:Init(data)
    self.data = data
    self.view:InitView(TeamLogoModel.new(data))
end

function TeamLogoRibbonCtrl:RegOnButtonClick(func)
    if type(func) == "function" then
        self.view:regOnButtonClick(function ()
            func(self.data)
        end)
    end
end

return TeamLogoRibbonCtrl