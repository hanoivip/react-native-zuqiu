local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local SettingBarDisplayView = require("ui.scene.court.technologyHall.SettingBarDisplayView")
local TechnologyBarView = class(SettingBarDisplayView)

function TechnologyBarView:ctor()
	TechnologyBarView.super.ctor(self)
end

function TechnologyBarView:start()

end

function TechnologyBarView:InitView(typeName, courtBuildModel)
    self.typeName = typeName
    self.courtBuildModel = courtBuildModel

    local isDefaultDevelop = courtBuildModel:IsDefaultType(typeName)
    GameObjectHelper.FastSetActive(self.defaultArea, isDefaultDevelop)
    GameObjectHelper.FastSetActive(self.descArea, not isDefaultDevelop)
    GameObjectHelper.FastSetActive(self.lvlObj, not isDefaultDevelop)

    local developLvl = courtBuildModel:GetBuildLevel(typeName)
    self.iconName.text = courtBuildModel:GetBuildShowName(typeName)
    self.lvl.text = "Lv" .. developLvl
    self.icon.overrideSprite = CourtAssetFinder.GetTechnologyFixIcon(typeName)
    self.icon:SetNativeSize()

	local isDefaultDevelop = courtBuildModel:IsDefaultType(typeName)
	if not isDefaultDevelop then 
		self:SetEffect(courtBuildModel, typeName, developLvl, self.skillArea, self.reduceNum, self.attributeText, self.reduceDesc)
	end
end

return TechnologyBarView