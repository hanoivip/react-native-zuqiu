local HomePersonalView = class(unity.base)

function HomePersonalView:ctor()
    self.playerName = self.___ex.playerName
    self.playerLevel = self.___ex.playerLevel
end

function HomePersonalView:InitView(playerInfoModel)
    self.playerName.text = playerInfoModel:GetName()
    self.playerLevel.text = 'Lv.' .. playerInfoModel:GetLevel()
end

function HomePersonalView:start()
    self:RegModelHandler()
end

function HomePersonalView:onDestroy()
    self:RemoveModelHandler()
end

function HomePersonalView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.InitView)
end

function HomePersonalView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.InitView)
end

return HomePersonalView