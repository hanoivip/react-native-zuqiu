local GameObjectHelper = require("ui.common.GameObjectHelper")
local BuildDevelopView = class(unity.base)

function BuildDevelopView:ctor()
    self.click = self.___ex.click
    self.icon = self.___ex.icon
    self.lvl = self.___ex.lvl
    self.isBuilding = self.___ex.isBuilding
    self.nameTxt = self.___ex.name
    self.unlock = self.___ex.unlock
    self.unlockText = self.___ex.unlockText

    self.click:regOnButtonClick(function() self:ClickBuildDevelop() end)
end

function BuildDevelopView:ClickBuildDevelop()
    if self.isOpen then 
        if self.clickBuild then 
            self.clickBuild(self.courtBuildType)
        end
    end
end

function BuildDevelopView:InitView(courtBuildModel, courtBuildType)
    self.courtBuildType = courtBuildType
    self.nameTxt.text = courtBuildModel:GetBuildShowName(courtBuildType)
    self.lvl.text = "Lv" .. courtBuildModel:GetBuildLevel(courtBuildType)
    local currentUpgradingType = courtBuildModel:HasBuildUpgrading() and courtBuildModel:GetBuildUpgradingType() or ""
    GameObjectHelper.FastSetActive(self.isBuilding, currentUpgradingType == courtBuildType)

    local isOpen, needLvl, needBuildName = courtBuildModel:IsBuildUnlock(courtBuildType)
    if not isOpen then
        if needBuildName == "League" then
            self.unlockText.text = lang.trans("league_unlock", needLvl)
        end
    end
    self.isOpen = isOpen
    GameObjectHelper.FastSetActive(self.unlock, not isOpen)
end

return BuildDevelopView
