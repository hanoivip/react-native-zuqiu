local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local TeamLogoBorderCtrl = class()

function TeamLogoBorderCtrl:ctor()
    self:CreateView()
end

function TeamLogoBorderCtrl:CreateView()
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Team/Prefab/TeamLogoBorder.prefab")
    self.view = spt
    self.view.ctrl = self
end

function TeamLogoBorderCtrl:Init(data)
    self.data = data
    self.view:InitView(TeamLogoModel.new(data))
end

function TeamLogoBorderCtrl:RegOnButtonClick(func)
    if type(func) == "function" then
        self.view:regOnButtonClick(function ()
            func(self.data)
        end)
    end
end

return TeamLogoBorderCtrl