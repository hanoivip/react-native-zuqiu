local MySceneModel = require("ui.models.myscene.MySceneModel")
local OtherSceneModel = class(MySceneModel)

function OtherSceneModel:ctor()
    OtherSceneModel.super.ctor(self)
end

function OtherSceneModel:Init(data)
    if self.data == nil then
        self.data = { data = {}}
    end
    self.data.data = data or {}
end

function OtherSceneModel:InitWithProtocol(data)
    self:Init(data)
end

function OtherSceneModel:InitData()
    self:SetSelect("SunShine", "Common", "home")
end

function OtherSceneModel:SetTeamCourtSelect(weather, grass, home)
    self.data.data.weather = weather
    self.data.data.grass = grass
    self.data.data.home = home
end

return OtherSceneModel
