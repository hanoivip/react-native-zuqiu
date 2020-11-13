local Skills = require("data.Skills")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalBenedictionReplaceView = class(unity.base)

function MedalBenedictionReplaceView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.btnClose = self.___ex.btnClose
    self.arrow = self.___ex.arrow
    self.currentIcon = self.___ex.currentIcon
    self.nextIcon = self.___ex.nextIcon
    self.needItemNum = self.___ex.needItemNum
    self.ownerItemNum = self.___ex.ownerItemNum
    self.currentTip = self.___ex.currentTip
    self.nextTip = self.___ex.nextTip
    self.curentName = self.___ex.curentName
    self.nextName = self.___ex.nextName
    self.curentLvl = self.___ex.curentLvl
    self.nextLvl = self.___ex.nextLvl
    self.currentArrt = self.___ex.currentArrt
    self.nextArrt = self.___ex.nextArrt
    self.currentStrengthin = self.___ex.currentStrengthin
    self.nextStrengthin = self.___ex.nextStrengthin
end

function MedalBenedictionReplaceView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
end

function MedalBenedictionReplaceView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

function MedalBenedictionReplaceView:onBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm(self.medalSingleModel)
    end
end

function MedalBenedictionReplaceView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalBenedictionReplaceView:InitView(medalSingleModel, playerInfoModel)
    self.medalSingleModel = medalSingleModel
    local picIndex = medalSingleModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    self.currentIcon:SetNativeSize()
    self:ShowCurrentAttr(medalSingleModel)
    self:ShowStrengthin(medalSingleModel, self.currentStrengthin)

    self:ShowNextAttr(medalSingleModel)
    self:ShowStrengthin(medalSingleModel, self.nextStrengthin)
    picIndex = medalSingleModel:GetPic()
    self.nextIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex .. ".png")
    self.nextIcon:SetNativeSize()
    local replaceConsume = medalSingleModel:GetBenedictionReplaceConsume()
    self.needItemNum.text = tostring(replaceConsume)
    self.ownerItemNum.text = tostring(playerInfoModel:GetBenedictionCount())
end

function MedalBenedictionReplaceView:ShowStrengthin(medalSingleModel, strengthin)
    local hasStrength = false
    local state = medalSingleModel:GetBenedictionState()
    if state > 0 then
        hasStrength = true
        strengthin.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Benediction" .. state .. ".png")
    end
    GameObjectHelper.FastSetActive(strengthin.gameObject, hasStrength)
end

function MedalBenedictionReplaceView:ShowCurrentAttr(medalSingleModel)
    local tip, desc = ""
    local benediction = medalSingleModel:GetBenediction()
    local name, lvl, sid = medalSingleModel:GetBenedictionNameAndLvl()
    if sid then 
        local medalSkill = Skills[tostring(sid)]
        desc = medalSkill.desc
        lvl = "Lv" .. lvl
    else
        tip = lang.trans("no_benediction")
    end
    self.currentTip.text = tip
    self.currentArrt.text = desc
    self.curentName.text = name
    self.curentLvl.text = lvl
end

function MedalBenedictionReplaceView:ShowNextAttr(medalSingleModel)
    local tip = ""
    local benediction = medalSingleModel:GetMedalBlessAdvanced()
    if benediction then 
        tip = lang.trans("replace_benediction")
    else
        tip = lang.trans("no_benediction")
    end
    self.nextTip.text = tip
end

return MedalBenedictionReplaceView
