local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalAttrHelper = require("ui.scene.medal.MedalAttrHelper")
local MedalUpgradeView = class(unity.base)

function MedalUpgradeView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.btnClose = self.___ex.btnClose
    self.currentIcon = self.___ex.currentIcon
    self.nextIcon = self.___ex.nextIcon
    self.needItemNum = self.___ex.needItemNum
    self.ownerItemNum = self.___ex.ownerItemNum
    self.currentArrtMap = self.___ex.currentArrtMap
    self.nextArrtMap = self.___ex.nextArrtMap
    self.arrow = self.___ex.arrow
    self.costIcon = self.___ex.costIcon
    self.tglSkipAnim = self.___ex.tglSkipAnim
    self.gradeCondition = self.___ex.gradeCondition
    self.protectCost = self.___ex.protectCost
    self.protect = self.___ex.protect
    self.buttonConfirm = self.___ex.buttonConfirm
    self.needItemNumLabel = self.___ex.needItemNumLabel
    self.ownerItemNumLabel = self.___ex.ownerItemNumLabel
    self.protected = false
end

function MedalUpgradeView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
    self.tglSkipAnim:regOnButtonClick(function()
        self:OnToggleChange()
    end)
end

function MedalUpgradeView:OnToggleChange()
    self.protected = not self.protected
    self:SetProtect()
end

function MedalUpgradeView:SetProtect()
    if self.protected then
        self.tglSkipAnim:selectBtn()
    else
        self.tglSkipAnim:unselectBtn()
    end
end

function MedalUpgradeView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

function MedalUpgradeView:onBtnConfirm()
    if not self.medalSingleModel:IsCanUpGrade() then
        return
    end
    if self.clickConfirm then 
        self.clickConfirm(self.medalSingleModel, self.protected)
    end
end

function MedalUpgradeView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalUpgradeView:InitView(medalSingleModel, playerInfoModel)
    self.medalSingleModel = medalSingleModel
    local picIndex = medalSingleModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    self.currentIcon:SetNativeSize()
    self:ShowCurrentAttr(medalSingleModel)
    local advancedId = medalSingleModel:GetMedalAdvanced()
    local advancedProtect = medalSingleModel:GetAdvancedProtect()
    local isCanUpGrade, condition = medalSingleModel:IsCanUpGrade()
    local hasAdvanced = false
    local typeId, cost = nil, ""
    if advancedId then 
        local nextMedalSingleModel = PlayerMedalModel.new()
        nextMedalSingleModel:InitWithStatic(advancedId)
        if nextMedalSingleModel:GetStatic() then 
            hasAdvanced = true
            self:ShowNextAttr(nextMedalSingleModel)
            picIndex = nextMedalSingleModel:GetPic()
            self.nextIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
            self.nextIcon:SetNativeSize()
            local advancedConsume = medalSingleModel:GetAdvancedConsume()
            typeId, cost = next(advancedConsume) 
        end
    end
    GameObjectHelper.FastSetActive(self.nextIcon.gameObject, hasAdvanced)
    GameObjectHelper.FastSetActive(self.arrow.gameObject, hasAdvanced)
    local ownerItem = 0
    if typeId == '2' then
        ownerItem = playerInfoModel:GetBenedictionCount()
        self.costIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/12.png")
        self.needItemNumLabel.text = lang.trans("need_benediction_item")
        self.ownerItemNumLabel.text = lang.trans("owner_benediction_item")
    else
        ownerItem = playerInfoModel:GetStardustCount()
        self.costIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemIcon/11.png")
        self.needItemNumLabel.text = lang.trans("need_upgrade_item")
        self.ownerItemNumLabel.text = lang.trans("owner_upgrade_item")
    end
    self.needItemNum.text = tostring(cost)
    self.ownerItemNum.text = tostring(ownerItem)
    if isCanUpGrade then
        self.buttonConfirm.interactable = true
        GameObjectHelper.FastSetActive(self.gradeCondition.gameObject, false)
        local typeId, cost = nil, nil
        if next(advancedProtect) then
            typeId, cost = next(advancedProtect)
        end
        if typeId and cost then
            GameObjectHelper.FastSetActive(self.protect, true)
            if typeId == '2' then
                self.protectCost.text = lang.trans("medal_protect_costjq", cost)
            else
                self.protectCost.text = lang.trans("medal_protect_costyz", cost)
            end
        else
            GameObjectHelper.FastSetActive(self.protect, false)
        end
    else
        self.gradeCondition.text = lang.trans("medal_grade_tips", condition/10)
        GameObjectHelper.FastSetActive(self.gradeCondition.gameObject, true)
        GameObjectHelper.FastSetActive(self.protect, false)
        self.buttonConfirm.interactable = false
    end
    self:SetProtect()
end

function MedalUpgradeView:ShowCurrentAttr(medalSingleModel)
    self.currentAttr = MedalAttrHelper.ShowCurrentAttr(medalSingleModel, self.currentArrtMap, true)
end

-- 在进阶的时候如果有原始属性，保持不变
function MedalUpgradeView:ShowNextAttr(medalSingleModel)
    MedalAttrHelper.ShowNextAttr(medalSingleModel, self.currentAttr, self.nextArrtMap)
end

return MedalUpgradeView
