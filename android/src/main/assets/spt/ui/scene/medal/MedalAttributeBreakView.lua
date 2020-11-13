local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local MedalAttributeBreakView = class(unity.base)

function MedalAttributeBreakView:ctor()
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

function MedalAttributeBreakView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
end

function MedalAttributeBreakView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

function MedalAttributeBreakView:onBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm(self.medalSingleModel)
    end
end

function MedalAttributeBreakView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

local medalTicket = 15
function MedalAttributeBreakView:InitView(medalSingleModel, playerInfoModel)
    self.medalSingleModel = medalSingleModel
    local picIndex = medalSingleModel:GetPic()
    self.currentIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
    self.currentIcon:SetNativeSize()
    self:ShowAttr(medalSingleModel)
    picIndex = medalSingleModel:GetPic()
    self.nextIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex .. ".png")
    self.nextIcon:SetNativeSize()
    self.needItemNum.text = "1"
    local itemsMapModel = ItemsMapModel.new()
    self.ownerItemNum.text = tostring(itemsMapModel:GetItemNum(medalTicket))
end

function MedalAttributeBreakView:ShowAttr(medalSingleModel)
    local tip, desc = ""
    local name, plus = next(medalSingleModel:GetExAttr())
    self.currentTip.text = tip
    self.currentArrt.text = desc
    name = lang.transstr(name)
    self.curentName.text = name
    local max = tobool(plus >= medalSingleModel:GetBreakTroughMaxPercent()) and "\n(MAX)" or ""
    plus = plus * 100
    plus = "+" .. plus .. "%" .. max
    self.curentLvl.text = plus
    self.nextName.text = name
    plus = medalSingleModel:GetBreakTroughMinPercent() * 100 .. "%-" .. medalSingleModel:GetBreakTroughMaxPercent() * 100 .. "%"
    self.nextLvl.text = plus
end

return MedalAttributeBreakView
