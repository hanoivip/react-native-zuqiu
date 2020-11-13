local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local MedalEquipPageView = class(unity.base)

function MedalEquipPageView:ctor()
    self.listScrollView = self.___ex.listScrollView
    self.medalView = self.___ex.medalView
    self.infoBoard = self.___ex.infoBoard
    self.nameTxt = self.___ex.name
    self.medalType = self.___ex.medalType
    self.btnEquip = self.___ex.btnEquip
    self.benedictionName = self.___ex.benedictionName
    self.benedictionBar = self.___ex.benedictionBar
    self.medalAttrMap = self.___ex.medalAttrMap
    self.btnClose = self.___ex.btnClose
    self.buttonText = self.___ex.buttonText
    self.buttonEquip = self.___ex.buttonEquip
end

function MedalEquipPageView:start()
    self.listScrollView.clickMedal = function(medalModel) self:OnClickMedal(medalModel) end
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnEquip:regOnButtonClick(function()
        self:OnClickEquip()
    end)
end

function MedalEquipPageView:OnClickEquip()
    if self.clickEquip then 
        self.clickEquip(self.medalModel, self.isSelectModel)
    end
end

function MedalEquipPageView:InitView(pos, medalSelectModel)
    local playerMedalsMapModel = PlayerMedalsMapModel.new()
    self.listScrollView:InitView(pos, medalSelectModel, playerMedalsMapModel)
    GameObjectHelper.FastSetActive(self.infoBoard, false)
    -- 将被替换的勋章model
    self.beReplacedMedalModel = medalSelectModel
    if medalSelectModel then
        self:OnClickMedal(medalSelectModel, true)
    end
end

function MedalEquipPageView:OnClickMedal(medalModel, isSelectModel)
    self.isSelectModel = isSelectModel or (self.beReplacedMedalModel ~= nil and self.beReplacedMedalModel:GetPmid() == medalModel:GetPmid() or false)
    self.buttonText.text = self.beReplacedMedalModel == nil and lang.trans("equip") or (self.isSelectModel and lang.trans("unload") or lang.trans("replace"))
    local hasBenediction = false
    local medalName, benedictionName = "", ""
    self.medalView:InitView(medalModel)
    self.medalView:ClearName()
    medalName = medalModel:GetName()
    self.medalModel = medalModel
    local benediction = medalModel:GetBenediction()
    if next(benediction) then
        hasBenediction = true
        local name, lvl = medalModel:GetBenedictionNameAndLvl()
        benedictionName = name .. "Lv" .. lvl
    end
    self.benedictionName.text = benedictionName
    self.nameTxt.text = medalName
    self.medalType.text = medalModel:GetMedalTypeName()
    local hasBaseAttr, hasExaAttr, hasSkillAttr = false, false, false
    local baseAttr = medalModel:GetBaseAttr()
    if next(baseAttr) then
        local title = lang.transstr("breakThrough_baseAttr")
        local name, lvl = next(baseAttr)
        name = lang.transstr(name)
        lvl = "+" .. lvl
        local data = { title = title, name = name, lvl = lvl }
        self.medalAttrMap["s1"]:InitView(data)
        hasBaseAttr = true
    end
    local exaAttr = medalModel:GetExAttr()
    if next(exaAttr) then
        local title = lang.transstr("extra_attr")
        local name, plus = next(exaAttr)
        name = lang.transstr(name)
        plus = plus * 100
        plus = "+" .. plus .. "%"
        local data = { title = title, name = name, lvl = plus }
        self.medalAttrMap["s2"]:InitView(data)
        hasExaAttr = true
    end
    local skillAttr = medalModel:GetSkill()
    if next(skillAttr) then
        local title = lang.transstr("skill_attr")
        local name, lvl = medalModel:GetSkillNameAndLvl()
        lvl = "+" .. "Lv" .. lvl
        local data = { title = title, name = name, lvl = lvl }
        self.medalAttrMap["s3"]:InitView(data)
        hasSkillAttr = true
    end
    -- 是我自己装备的勋章或者没有被装备
    self.buttonEquip.interactable = self.isSelectModel or not medalModel:HasEquiped()

    GameObjectHelper.FastSetActive(self.medalAttrMap["s1"].gameObject, hasBaseAttr)
    GameObjectHelper.FastSetActive(self.medalAttrMap["s2"].gameObject, hasExaAttr)
    GameObjectHelper.FastSetActive(self.medalAttrMap["s3"].gameObject, hasSkillAttr)
    GameObjectHelper.FastSetActive(self.infoBoard, true)
    GameObjectHelper.FastSetActive(self.benedictionBar.gameObject, hasBenediction)
end

function MedalEquipPageView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

return MedalEquipPageView
