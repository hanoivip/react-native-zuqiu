local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalAttrHelper = require("ui.scene.medal.MedalAttrHelper")
local MedalBenedictionBoardView = class(unity.base)

function MedalBenedictionBoardView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.currentIcon = self.___ex.currentIcon
    self.currentStrengthin = self.___ex.currentStrengthin
    self.nameTxt = self.___ex.name
    self.typeName = self.___ex.typeName
    self.title = self.___ex.title
    self.currentArrtMap = self.___ex.currentArrtMap
end

function MedalBenedictionBoardView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
end

function MedalBenedictionBoardView:onBtnConfirm()
    self:Close()
end

function MedalBenedictionBoardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalBenedictionBoardView:InitView(medalSingleModel, isBenediction)
    self.medalSingleModel = medalSingleModel
    local picIndex = medalSingleModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    self.currentIcon:SetNativeSize()
    self:ShowCurrentAttr(medalSingleModel)
    self:ShowStrengthin(medalSingleModel, self.currentStrengthin)
    if isBenediction then 
        self.title.text = lang.trans("benediction_tip1")
    else
        self.title.text = lang.trans("benediction_tip2")
    end
    self.nameTxt.text = medalSingleModel:GetName()
    self.typeName.text = medalSingleModel:GetMedalTypeName()
end

function MedalBenedictionBoardView:ShowStrengthin(medalSingleModel, strengthin)
    local hasStrength = false
    local state = medalSingleModel:GetBenedictionState()
    if state > 0 then
        hasStrength = true
        strengthin.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Benediction" .. state .. ".png")
    end
    GameObjectHelper.FastSetActive(strengthin.gameObject, hasStrength)
end

function MedalBenedictionBoardView:ShowCurrentAttr(medalSingleModel)
    MedalAttrHelper.ShowCurrentAttr(medalSingleModel, self.currentArrtMap)
end

return MedalBenedictionBoardView
