local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local TechnologyDevelopType = require("ui.scene.court.technologyHall.TechnologyDevelopType")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local SettingBarDisplayView = class(unity.base)

function SettingBarDisplayView:ctor()
    self.iconName = self.___ex.iconName
    self.lvlObj = self.___ex.lvlObj
    self.lvl = self.___ex.lvl
    self.useButton = self.___ex.useButton
    self.icon = self.___ex.icon
    self.defaultArea = self.___ex.defaultArea
    self.descArea = self.___ex.descArea
    self.skillArea = self.___ex.skillArea
    self.attrArea = self.___ex.attrArea
    self.attributeText = self.___ex.attributeText
    self.reduceDesc = self.___ex.reduceDesc
    self.reduceNum = self.___ex.reduceNum
    self.useSign = self.___ex.useSign
    self.unlock = self.___ex.unlock
    self.unlockText = self.___ex.unlockText
    self.matchDesc = self.___ex.matchDesc

    self.skillMap = { }
end

function SettingBarDisplayView:start()
    self.useButton:regOnButtonClick( function()
        self:OnBtnUse()
    end )

    EventSystem.AddEvent("ChangeTechnologySetting", self, self.ChangeTechnologySetting)
end

function SettingBarDisplayView:OnBtnUse()
    if self.clickUse then
        self.clickUse(self.typeName)
    end
end

function SettingBarDisplayView:onDestroy()
    EventSystem.RemoveEvent("ChangeTechnologySetting", self, self.ChangeTechnologySetting)
end

function SettingBarDisplayView:ChangeTechnologySetting()
    self:SetButtonState(self.settingType, self.technologyType, self.typeName, self.courtBuildModel)
end

function SettingBarDisplayView:SetEffect(courtBuildModel, buildType, buildLevel, contentArea, reduceText, attrText, reduceDesc)
    local isEffectSkill, effect, point = courtBuildModel:GetEffect(buildType, buildLevel)
    if isEffectSkill then
        for i, v in ipairs(self.skillMap) do
            GameObjectHelper.FastSetActive(v.gameObject, false)
        end
        for i, sid in ipairs(effect) do
            if not self.skillMap[i] then
                local obj = Object.Instantiate(self:GetEffetSkillRes())
                obj.transform:SetParent(contentArea, false)
                local spt = res.GetLuaScript(obj)
                self.skillMap[i] = spt
            end
            self.skillMap[i]:InitView(sid)
            GameObjectHelper.FastSetActive(self.skillMap[i].gameObject, true)
        end
        reduceText.text = lang.trans("reduce_num", point)
        reduceDesc.text = lang.trans("lvl_reduce")
    else
        local textStr = ''
        for i, attr in ipairs(effect) do
            local symbol = ''
            if i < #effect then
                symbol = '、'
            end
            textStr = textStr .. lang.transstr(attr) .. symbol
        end
        attrText.text = textStr
        reduceText.text = lang.trans("reduce_point", point)
        reduceDesc.text = lang.trans("attr_reduce")
    end
    GameObjectHelper.FastSetActive(self.skillArea.gameObject, isEffectSkill)
    GameObjectHelper.FastSetActive(self.attrArea.gameObject, not isEffectSkill)

    local matchDesc
    if courtBuildModel:IsGrass(buildType) then 
        matchDesc = lang.trans("match_desc1")
    elseif courtBuildModel:IsWeather(buildType) then 
        matchDesc = lang.trans("match_desc2")
    end
    self.matchDesc.text = matchDesc
end

-- settingType 竞技场，冠军联赛等
-- technologyType 草皮，天气等
-- typeName 草皮天气类型
function SettingBarDisplayView:InitView(settingType, technologyType, typeName, courtBuildModel)
    self.settingType = settingType
    self.typeName = typeName
    self.technologyType = technologyType
    self.courtBuildModel = courtBuildModel

    local isDefaultDevelop = courtBuildModel:IsDefaultType(typeName)
    GameObjectHelper.FastSetActive(self.defaultArea, isDefaultDevelop)
    GameObjectHelper.FastSetActive(self.descArea, not isDefaultDevelop)
    GameObjectHelper.FastSetActive(self.lvlObj, not isDefaultDevelop)

    local developLvl = courtBuildModel:GetBuildLevel(typeName)
    self.iconName.text = courtBuildModel:GetBuildShowName(typeName)
    self.lvl.text = "Lv" .. developLvl
    self.icon.overrideSprite = CourtAssetFinder.GetTechnologyIcon(typeName)
    self.icon:SetNativeSize()

	local isOpen = false
    if isDefaultDevelop then
        isOpen = true
    else
		local isUnlock, needLvl, needBuildName, desc = courtBuildModel:IsBuildUnlock(typeName)
		isOpen = isUnlock
		self.unlockText.text = desc
        self:SetEffect(courtBuildModel, typeName, developLvl, self.skillArea, self.reduceNum, self.attributeText, self.reduceDesc)
    end
    self.isOpen = isOpen
    GameObjectHelper.FastSetActive(self.unlock, not isOpen)
    self:SetButtonState(settingType, technologyType, typeName, courtBuildModel)
end

function SettingBarDisplayView:SetButtonState(settingType, technologyType, typeName, courtBuildModel)
    local isBeUsed = courtBuildModel:IsBuildBeUsed(settingType, technologyType, typeName)
    GameObjectHelper.FastSetActive(self.useSign, isBeUsed and self.isOpen)
    GameObjectHelper.FastSetActive(self.useButton.gameObject, not isBeUsed and self.isOpen)
end

function SettingBarDisplayView:GetEffetSkillRes()
    if not self.skillRes then
        self.skillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/EffectSkill.prefab")
    end

    return self.skillRes
end

return SettingBarDisplayView
