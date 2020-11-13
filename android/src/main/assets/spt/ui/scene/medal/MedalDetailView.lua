local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalAttrHelper = require("ui.scene.medal.MedalAttrHelper")
local MedalDetailView = class(unity.base)

function MedalDetailView:ctor()
    self.btnClose = self.___ex.btnClose
    self.currentIcon = self.___ex.currentIcon
    self.currentArrtMap = self.___ex.currentArrtMap
    self.currentStrengthin = self.___ex.currentStrengthin
    self.nameTxt = self.___ex.name
    self.typeName = self.___ex.typeName
end

function MedalDetailView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function MedalDetailView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

function MedalDetailView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalDetailView:InitView(medalModel)
    self.medalModel = medalModel
    self.nameTxt.text = medalModel:GetName()
    self.typeName.text = medalModel:GetMedalTypeName()
    local picIndex = medalModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    
    local hasStrength = false
    local state = medalModel:GetBenedictionState()
    if state > 0 then
        hasStrength = true
        self.currentStrengthin.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Benediction" .. state .. ".png")
    end
    GameObjectHelper.FastSetActive(self.currentStrengthin.gameObject, hasStrength)

    if medalModel:GetPmid() then -- 自身拥有需要显示自身勋章数据
        self:ShowOwnerAttr(medalModel)
    else
        self:ShowStaticAttr(medalModel)
    end
end

function MedalDetailView:ShowOwnerAttr(medalModel)
    MedalAttrHelper.ShowCurrentAttr(medalModel, self.currentArrtMap)
end

function MedalDetailView:ShowStaticAttr(medalSingleModel)
    MedalAttrHelper.ShowStaticAttr(medalSingleModel, self.currentArrtMap)
end

return MedalDetailView
