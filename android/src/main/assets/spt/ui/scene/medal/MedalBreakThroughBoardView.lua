local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalAttrHelper = require("ui.scene.medal.MedalAttrHelper")
local MedalBreakThroughBoardView = class(unity.base)

function MedalBreakThroughBoardView:ctor()
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

function MedalBreakThroughBoardView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
end

function MedalBreakThroughBoardView:onBtnConfirm()
    self:Close()
end

function MedalBreakThroughBoardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalBreakThroughBoardView:InitView(currMedalSingleModel, oldMedalSingleModel)
    self.currMedalSingleModel = currMedalSingleModel
    self.nameTxt.text = currMedalSingleModel:GetName()
    self.typeName.text = currMedalSingleModel:GetMedalTypeName()
    local picIndex = currMedalSingleModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    self.currentIcon:SetNativeSize()
    local medalName, currAttr = next(currMedalSingleModel:GetExAttr())
    local _, oldAttr = next(oldMedalSingleModel:GetExAttr())
    self:ShowCurrentAttr(currMedalSingleModel)
    local isSuccess = tonumber(currAttr) - tonumber(oldAttr) > 0
    if not isSuccess then 
        self.titleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/TrueColor/Title_Icon.png")
        self.ribbon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/Ribbon_2.png")
    else
        self.titleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/TrueColor/SkillIcon.png")
        self.ribbon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/Ribbon_1.png")
    end
    GameObjectHelper.FastSetActive(self.success.gameObject, isSuccess)
    GameObjectHelper.FastSetActive(self.fail.gameObject, not isSuccess)
end

function MedalBreakThroughBoardView:ShowCurrentAttr(currMedalSingleModel)
    MedalAttrHelper.ShowCurrentAttr(currMedalSingleModel, self.currentArrtMap, true)
end

return MedalBreakThroughBoardView
