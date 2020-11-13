local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local TeamLogoColorCtrl = class()

function TeamLogoColorCtrl:ctor()
    self:CreateView()
end

function TeamLogoColorCtrl:CreateView()
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Team/Prefab/TeamLogoColor.prefab")
    self.view = spt
    self.view.ctrl = self
end

function TeamLogoColorCtrl:Init(data)
    self.data = data
    self.view:InitView(TeamLogoModel.new(data))
end

function TeamLogoColorCtrl:RegOnButtonClick(func)
    if type(func) == "function" then
        self.view:regOnButtonClick(function ()
            func(self.data)
        end)
    end
end

return TeamLogoColorCtrl