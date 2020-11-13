local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local GrassType = require("ui.scene.court.technologyHall.GrassType")
local WeatherType = require("ui.scene.court.technologyHall.WeatherType")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtTechnologyDetailModel = require("ui.models.court.CourtTechnologyDetailModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local SettingDisplayCtrl = class(BaseCtrl, "SettingDisplayCtrl")

SettingDisplayCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SettingDisplay.prefab"
function SettingDisplayCtrl:Init()
    self.view.clickEvent = function() self:ClickEvent() end
    self.view.clickUse = function(typeName) self:OnClickUse(typeName) end
end

function SettingDisplayCtrl:ClickEvent()
    EventSystem.SendEvent("ShowTechnologyHall")
end

function SettingDisplayCtrl:Refresh(settingType, technologyDevelopType)
    SettingDisplayCtrl.super.Refresh(self)
    self.courtBuildModel = CourtBuildModel.new()
	self.courtTechnologyDetailModel = CourtTechnologyDetailModel.new()
    self.settingType = settingType
    self.technologyDevelopType = technologyDevelopType
    local types
    if technologyDevelopType == TechnologyDevelopType.GrassType then 
        types = GrassType
    elseif technologyDevelopType == TechnologyDevelopType.WeatherType then 
        types = WeatherType
    end

	local titleStr = settingType .. "_" .. technologyDevelopType
	self.courtTechnologyDetailModel:SetTechnologyTitle(titleStr)
	self.courtTechnologyDetailModel:SetBarResPath("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SettingDisplayBar.prefab")
    self.view:InitView(self.courtBuildModel, self.courtTechnologyDetailModel, settingType, technologyDevelopType, types)
end

function SettingDisplayCtrl:OnClickUse(typeName)
    clr.coroutine(function()
        local response
        if self.technologyDevelopType == TechnologyDevelopType.GrassType then 
            response = req.setMatchGrassTech(self.settingType, typeName)
        elseif self.technologyDevelopType == TechnologyDevelopType.WeatherType then 
            response = req.setMatchWeatherTech(self.settingType, typeName)
        end
        if api.success(response) then
            local data = response.val
            self.courtBuildModel = CourtBuildModel.new()   
            self.courtBuildModel:MatchSet(self.settingType, self.technologyDevelopType, typeName)  
            self.view:Close() 
        end
    end)
end

return SettingDisplayCtrl
