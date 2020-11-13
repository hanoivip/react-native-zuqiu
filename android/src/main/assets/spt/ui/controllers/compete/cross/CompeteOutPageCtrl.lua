local ArenaKnockoutModel = require("ui.models.arena.schedule.ArenaKnockoutModel")
local CompeteOutPageCtrl = class(nil, "CompeteOutPageCtrl")

function CompeteOutPageCtrl:ctor(view, content)
    self:Init(content)
end

function CompeteOutPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteOutPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
end

function CompeteOutPageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function CompeteOutPageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function CompeteOutPageCtrl:InitView()

end

return CompeteOutPageCtrl
