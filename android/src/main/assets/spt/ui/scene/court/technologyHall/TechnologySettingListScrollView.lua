local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local TechnologySettingListScrollView = class(LuaScrollRectExSameSize)

function TechnologySettingListScrollView:ctor()
    TechnologySettingListScrollView.super.ctor(self)
end

function TechnologySettingListScrollView:start()
end

function TechnologySettingListScrollView:GetSettingBarRes()
    if not self.settingBarRes then 
        self.settingBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SettingBar.prefab")
    end
    return self.settingBarRes
end

function TechnologySettingListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetSettingBarRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function TechnologySettingListScrollView:resetItem(spt, index)
    spt:InitView(self.data[index], self.courtBuildModel)
    spt.clickGrass = function(settingType) self:OnClickGrass(settingType) end
    spt.clickWeather = function(settingType) self:OnClickWeather(settingType) end
    self:updateItemIndex(spt, index)
end

function TechnologySettingListScrollView:InitView(data, courtBuildModel)
    self.data = data
    self.courtBuildModel = courtBuildModel
    self:refresh(self.data)
end

function TechnologySettingListScrollView:OnClickGrass(settingType)
    if self.clickGrass then
        self.clickGrass(settingType)
    end
end

function TechnologySettingListScrollView:OnClickWeather(settingType)
    if self.clickWeather then
        self.clickWeather(settingType)
    end
end

return TechnologySettingListScrollView
