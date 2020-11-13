local ShowGirlState = require("ui.models.showgirl.ShowGirlState")

local Model = require("ui.models.Model")
local ShowGirlModel = class(Model)

function ShowGirlModel:ctor()
    ShowGirlModel.super.ctor(self)
end

function ShowGirlModel:InitWithProtocol(data)
    self.data = data
end

function ShowGirlModel:Qualified()
    return self.data.GsSetting and self.data.GsSetting.enable == 1 and
        self.data.player.GsState ~= ShowGirlState.NotQualified
end

function ShowGirlModel:Charged()
    return self.data.GsSetting and self.data.GsSetting.enable == 1 and
        self.data.player.GsState == ShowGirlState.Charged
end

-- static methods
function ShowGirlModel.HasCache()
    return ShowGirlModel.cache ~= nil
end

function ShowGirlModel.GetCache()
    return ShowGirlModel.cache
end

function ShowGirlModel.SetCache(value)
    ShowGirlModel.cache = value
end

function ShowGirlModel.Enabled()
    return ShowGirlModel.HasCache() and ShowGirlModel.GetCache():Qualified()
end
return ShowGirlModel
