local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GreenswardMoraleRecieveView = class(unity.base)

function GreenswardMoraleRecieveView:ctor()
    self.closeScript = self.___ex.closeScript
    self.countText = self.___ex.countText
    self.recieveButton = self.___ex.recieveButton
    self.displayArea = self.___ex.displayArea
    self.canvasGroup = self.___ex.canvasGroup
    self.buttonArea = self.___ex.buttonArea
    self.numTxt = self.___ex.numTxt
    self.titleTxt = self.___ex.titleTxt
    self.buyButtonScript = self.___ex.buyButtonScript
    self.couldBuyCount = 0
end

function GreenswardMoraleRecieveView:InitView(buildModel)
    local adventureBaseData = buildModel:GetAdventureBaseData()
    local systemMorale = adventureBaseData.systemMorale or {}
    local recieveStatus = buildModel:GetMoraleRecieveStatus()
    local systemMoraleNum = systemMorale[tonumber(recieveStatus) + 1] or 0
    local systemMoraleTime = adventureBaseData.systemMoraleTime or {}
    local timeStr = systemMoraleTime[tonumber(recieveStatus) + 1] or ""
    local times = string.split(timeStr, "=") or {}
    self.countText.text = lang.trans("recieve_time", times[1], times[2])
    self.numTxt.text = "x" .. systemMoraleNum
    local systemMoraleTitle = adventureBaseData.systemMoraleTitle or {}
    local titles = string.split(systemMoraleTitle, "#")
    self.titleTxt.text = titles[tonumber(recieveStatus) + 1] or ""
end

function GreenswardMoraleRecieveView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeScript:regOnButtonClick(function()
        self:Close()
    end)
    self.buyButtonScript:regOnButtonClick(function()
        if self.onMoraleRecieveClick then
            self.onMoraleRecieveClick()
        end
    end)
end

function GreenswardMoraleRecieveView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return GreenswardMoraleRecieveView