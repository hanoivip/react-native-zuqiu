local Model = require("ui.models.Model")
local PlayerLevelModel = class(Model)
-- 登录弹板的model
function PlayerLevelModel:ctor()
    PlayerLevelModel.super.ctor(self)
end

function PlayerLevelModel:Init(data)
    if not data then
        data = cache.getLoginPlate()
    end
    self.data = data or {}
end

function LoginPlateModel:InitWithProtocol(data)
    cache.setLoginPlate(data)
    self:Init(data)
end

return PlayerLevelModel
