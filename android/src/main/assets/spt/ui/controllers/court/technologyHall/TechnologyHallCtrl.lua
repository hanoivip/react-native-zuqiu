local TechnologyHallPageType = require("ui.scene.court.technologyHall.TechnologyHallPageType")
local GrassPageCtrl = require("ui.controllers.court.technologyHall.GrassPageCtrl")
local CourtPageCtrl = require("ui.controllers.court.technologyHall.CourtPageCtrl")
local WeatherPageCtrl = require("ui.controllers.court.technologyHall.WeatherPageCtrl")
local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local TechnologyHallCtrl = class(BaseCtrl, "TechnologyHallCtrl")
TechnologyHallCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/TechnologyHall.prefab"

function TechnologyHallCtrl:Init()
    self.view.clickPage = function(key) self:ClickPage(key) end
    self.prePage = nil
    self.technologyHallPageMap = {}
end

function TechnologyHallCtrl:Refresh()
    TechnologyHallCtrl.super.Refresh(self)
    self.courtBuildModel = CourtBuildModel.new()
    self.view:InitView(self.courtBuildModel)
end

function TechnologyHallCtrl:OnEnterScene()
    self.view:EnterScene()
    for k, v in pairs(self.technologyHallPageMap) do
        v:EnterScene()
    end
end

function TechnologyHallCtrl:OnExitScene()
    self.view:ExitScene()
    for k, v in pairs(self.technologyHallPageMap) do
        v:ExitScene()
    end
end

-- 点击菜单按钮事件
function TechnologyHallCtrl:ClickPage(key)
    if self.prePage and self.technologyHallPageMap[self.prePage] then 
        self.technologyHallPageMap[self.prePage]:ShowPageVisible(false)
    end

    if not self.technologyHallPageMap[key] then 
        if key == TechnologyHallPageType.CourtPage then 
            self.technologyHallPageMap[key] = CourtPageCtrl.new(nil, self.view.pageArea, TechnologySettingConfig.TechnologyHall)
        elseif key == TechnologyHallPageType.GrassPage then 
            self.technologyHallPageMap[key] = GrassPageCtrl.new(nil, self.view.pageArea)
        elseif key == TechnologyHallPageType.WeatherPage then 
            self.technologyHallPageMap[key] = WeatherPageCtrl.new(nil, self.view.pageArea)
        end
        self.technologyHallPageMap[key]:EnterScene()
    end
    self.prePage = key
    self.technologyHallPageMap[key]:ShowPageVisible(true)
    self.courtBuildModel = CourtBuildModel.new()
    self.technologyHallPageMap[key]:InitView(self.courtBuildModel)
end

return TechnologyHallCtrl
