local HomePersonalCtrl = class()

function HomePersonalCtrl:ctor(view, parentCtrl)
    self.parentCtrl = parentCtrl
    self.personalView = view
end

function HomePersonalCtrl:InitView(playerInfoModel)
    self.personalView:InitView(playerInfoModel)
end

return HomePersonalCtrl
