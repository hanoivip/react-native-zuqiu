local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local SettingDisplayListScrollView = class(LuaScrollRectExSameSize)

function SettingDisplayListScrollView:ctor()
    SettingDisplayListScrollView.super.ctor(self)
end

function SettingDisplayListScrollView:start()
end

function SettingDisplayListScrollView:GetSettingBarRes()
    if not self.settingBarRes then 
        self.settingBarRes = res.LoadRes(self.courtTechnologyDetailModel:GetBarResPath())
    end
    return self.settingBarRes
end

function SettingDisplayListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetSettingBarRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function SettingDisplayListScrollView:resetItem(spt, index)
    spt:InitView(self.settingType, self.technologyDevelopType, self.data[index].TypeName, self.courtBuildModel)
    spt.clickUse = function(typeName) self:OnClickUse(typeName) end
    self:updateItemIndex(spt, index)
end

function SettingDisplayListScrollView:InitView(courtBuildModel, courtTechnologyDetailModel, settingType, technologyDevelopType, types)
    self.data = types
    self.settingType = settingType
    self.technologyDevelopType = technologyDevelopType
    self.courtBuildModel = courtBuildModel
	self.courtTechnologyDetailModel = courtTechnologyDetailModel
    self:refresh(self.data)
end

function SettingDisplayListScrollView:OnClickUse(typeName)
    if self.clickUse then
        self.clickUse(typeName)
    end
end

return SettingDisplayListScrollView
