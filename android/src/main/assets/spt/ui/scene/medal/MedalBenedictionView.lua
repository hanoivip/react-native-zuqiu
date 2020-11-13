local Skills = require("data.Skills")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalBenedictionView = class(unity.base)

function MedalBenedictionView:ctor()
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

function MedalBenedictionView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
end

function MedalBenedictionView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

function MedalBenedictionView:onBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm(self.medalSingleModel)
    end
end

function MedalBenedictionView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalBenedictionView:InitView(medalSingleModel, playerInfoModel)
    self.medalSingleModel = medalSingleModel
    local picIndex = medalSingleModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    self.currentIcon:SetNativeSize()
    self:ShowCurrentAttr(medalSingleModel)
    self:ShowStrengthin(medalSingleModel, self.currentStrengthin)
    local advancedId = medalSingleModel:GetMedalBlessAdvanced()
    local hasAdvanced = false
    if advancedId then 
        local nextMedalSingleModel = PlayerMedalModel.new()
        nextMedalSingleModel:InitWithStatic(advancedId)
        if nextMedalSingleModel:GetStatic() then 
            hasAdvanced = true
            self:ShowNextAttr(nextMedalSingleModel)
            self:ShowStrengthin(nextMedalSingleModel, self.nextStrengthin)
            picIndex = nextMedalSingleModel:GetPic()
            self.nextIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
            self.needItemNum.text = tostring(medalSingleModel:GetBenedictionConsume())
            self.nextIcon:SetNativeSize()
        end
    end
    self.ownerItemNum.text = tostring(playerInfoModel:GetBenedictionCount())
    GameObjectHelper.FastSetActive(self.nextIcon.gameObject, hasAdvanced)
    GameObjectHelper.FastSetActive(self.arrow.gameObject, hasAdvanced)
end

function MedalBenedictionView:ShowStrengthin(medalSingleModel, strengthin)
    local hasStrength = false
    local state = medalSingleModel:GetBenedictionState()
    if state > 0 then
        hasStrength = true
        strengthin.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Benediction" .. state .. ".png")
    end
    GameObjectHelper.FastSetActive(strengthin.gameObject, hasStrength)
end

function MedalBenedictionView:ShowCurrentAttr(medalSingleModel)
    local tip, desc = ""
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

function MedalBenedictionView:ShowNextAttr(medalSingleModel)
    local tip = ""
    local benediction = medalSingleModel:GetMedalBlessAdvanced()
    if benediction then -- 未达到最大进阶时显示信息
        local benediction = self.medalSingleModel:GetBenediction()
        if next(benediction) then -- 在当前勋章有祝福时，下一等级祝福需要显示描述
            self.nextArrt.text = self.currentArrt.text
            self.nextName.text = self.curentName.text
            self.nextLvl.text = "Lv" .. medalSingleModel:GetRandomBenediction()
        else
            tip = lang.trans("find_benediction")
        end
    else
        tip = lang.trans("no_benediction")
    end
    self.nextTip.text = tip
end

return MedalBenedictionView
