local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local DialogManager = require("ui.control.manager.DialogManager")
local CourtBuildEvent = class()
local UnityEngine = clr.UnityEngine
local Input = UnityEngine.Input
CourtBuildEvent.isCourtTouchEventOpen = true

function CourtBuildEvent:ctor()
    self.cameraTouchEvent = self.___ex.cameraTouchEvent
    self.mobileTouchEvent = self.___ex.mobileTouchEvent
end

function CourtBuildEvent:start()
    EventSystem.AddEvent("BuildDialogClose", self, self.BuildDialogClose)
    EventSystem.AddEvent("CourtMobileTouchEventSwitch", self, self.MobileTouchEventSwitch)
    Input.multiTouchEnabled = true

    self:TouchEventSwitch(CourtBuildEvent.isCourtTouchEventOpen)
end

function CourtBuildEvent:onDestroy()
    EventSystem.RemoveEvent("BuildDialogClose", self, self.BuildDialogClose)
    EventSystem.RemoveEvent("CourtMobileTouchEventSwitch", self, self.MobileTouchEventSwitch)
    Input.multiTouchEnabled = false
end

function CourtBuildEvent:pickBuild(pickObj)
    local isDialogShow = false
    local pickName = pickObj.name
    if pickName == "Stadium" then 
        res.PushDialog("ui.controllers.court.CourtStadiumBuildCtrl")
        GuideManager.Show(self)
        isDialogShow = true
    elseif pickName == "Scouting" then  
        res.PushDialog("ui.controllers.court.CourtScoutBuildCtrl")
        GuideManager.Show(self)
        isDialogShow = true
    elseif pickName == "TechnologyHall" then 
        res.PushDialog("ui.controllers.court.technologyHall.TechnologyHallCtrl")
        isDialogShow = true
    elseif pickName == "Park" then 
        res.PushDialog("ui.controllers.court.CourtParkingBuildCtrl")
        GuideManager.Show(self)
        isDialogShow = true
	elseif pickName == "Communication" then
		DialogManager.ShowToast(lang.trans("not_open"))
    end

    self:TouchEventSwitch(not isDialogShow)
end

function CourtBuildEvent:MobileTouchEventSwitch(isOpen)
    self.mobileTouchEvent.enabled = isOpen
end

function CourtBuildEvent:TouchEventSwitch(isOpen)
    CourtBuildEvent.isCourtTouchEventOpen = isOpen
    self.cameraTouchEvent.enabled = isOpen
end

function CourtBuildEvent:BuildDialogClose(courtBuildType)
    self:TouchEventSwitch(true)
end

return CourtBuildEvent
