local AdventureRegion = require("data.AdventureRegion")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local WelcomePageView = class(unity.base)

function WelcomePageView:ctor()
--------Start_Auto_Generate--------
    self.seasonNameTxt = self.___ex.seasonNameTxt
    self.regionTrans = self.___ex.regionTrans
    self.tipsTxt = self.___ex.tipsTxt
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
end

function WelcomePageView:start()
    self.closeBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("AllDialogBeDestroy")
        self.closeDialog()
        self:ShowGuide()
    end)
end

function WelcomePageView:ShowGuide()
    local currentFloor = self.greenswardBuildModel:GetCurrentFloor()
    GuideManager.InitCurModule("adventureF" .. currentFloor)
    GuideManager.Show(self)
end

function WelcomePageView:InitView(greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    local welcome = greenswardBuildModel:GetWelcome()
    local power = welcome.power
    local season = greenswardBuildModel:GetSeason()
    local region = greenswardBuildModel:GetRegion()
    self.seasonNameTxt.text = lang.trans("ladder_reward_seasonName", season)
    local regionPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/RegionItem.prefab"
    local object, spt = res.Instantiate(regionPath)
    spt:InitView(region, self.regionTrans)
    self:SetRegionTips(region, power)
    EventSystem.SendEvent("DialogInsertCurrentScene")
end

function WelcomePageView:SetRegionTips(region, power)
        region = tostring(region)
        local regionData = AdventureRegion[region]
        local regionName = regionData.regionName
        local powerLow = regionData.powerLow
        local powerHigh = regionData.powerHigh
        if power >= powerLow and power <= powerHigh then
            self.tipsTxt.text = lang.trans("adventure_welcome_region", power, regionName, regionName)
        else
            local realLow, realHigh
        for i, v in pairs(AdventureRegion) do
            local l = v.powerLow
            local h = v.powerHigh
            if power > l and power <= h then
                realLow = l
                realHigh = h
                break
            end
        end
        self.tipsTxt.text = lang.trans("adventure_welcome_down", power, realLow, realHigh, regionName, regionName, regionName, regionName)
    end
end

return WelcomePageView
