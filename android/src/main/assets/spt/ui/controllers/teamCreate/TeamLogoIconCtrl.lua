local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local TeamLogoIconCtrl = class()

function TeamLogoIconCtrl:ctor()
    self:CreateView()
end

function TeamLogoIconCtrl:CreateView()
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Team/Prefab/TeamLogoIcon.prefab")
    self.view = spt
    self.view.ctrl = self
end

function TeamLogoIconCtrl:Init(data)
    self.data = data
    self.view:InitView(TeamLogoModel.new(data))
end

function TeamLogoIconCtrl:RegOnButtonClick(func)
    if type(func) == "function" then
        self.view:regOnButtonClick(function ()
            func(self.data)
        end)
    end
end

return TeamLogoIconCtrl