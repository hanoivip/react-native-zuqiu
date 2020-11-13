local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalAttrHelper = require("ui.scene.medal.MedalAttrHelper")
local MedalUpgradeBoardView = class(unity.base)

function MedalUpgradeBoardView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.currentIcon = self.___ex.currentIcon
    self.currentStrengthin = self.___ex.currentStrengthin
    self.nameTxt = self.___ex.name
    self.typeName = self.___ex.typeName
    self.titleIcon = self.___ex.titleIcon
    self.ribbon = self.___ex.ribbon
    self.success = self.___ex.success
    self.fail = self.___ex.fail
    self.currentArrtMap = self.___ex.currentArrtMap
end

function MedalUpgradeBoardView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
end

function MedalUpgradeBoardView:onBtnConfirm()
    self:Close()
end

function MedalUpgradeBoardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalUpgradeBoardView:InitView(medalSingleModel, bChange)
    self.medalSingleModel = medalSingleModel
    self.nameTxt.text = medalSingleModel:GetName()
    self.typeName.text = medalSingleModel:GetMedalTypeName()
    local picIndex = medalSingleModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    self.currentIcon:SetNativeSize()
    self:ShowCurrentAttr(medalSingleModel)
    self:ShowStrengthin(medalSingleModel, self.currentStrengthin)

    local hasBroken = medalSingleModel:HasBroken()
    if hasBroken or not bChange then 
        self.titleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/TrueColor/Title_Icon.png")
        self.ribbon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/Ribbon_2.png")
    else
        self.titleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/TrueColor/SkillIcon.png")
        self.ribbon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/Ribbon_1.png")
    end
    GameObjectHelper.FastSetActive(self.success.gameObject, not hasBroken and bChange)
    GameObjectHelper.FastSetActive(self.fail.gameObject, hasBroken or not bChange)
end

function MedalUpgradeBoardView:ShowStrengthin(medalSingleModel, strengthin)
    local hasStrength = false
    local state = medalSingleModel:GetBenedictionState()
    if state > 0 then
        hasStrength = true
        strengthin.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Benediction" .. state .. ".png")
    end
    GameObjectHelper.FastSetActive(strengthin.gameObject, hasStrength)
end

function MedalUpgradeBoardView:ShowCurrentAttr(medalSingleModel)
    MedalAttrHelper.ShowCurrentAttr(medalSingleModel, self.currentArrtMap, true)
end

return MedalUpgradeBoardView
