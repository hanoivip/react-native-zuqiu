local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local RewardCurrencyDialogView = class(unity.base)

function RewardCurrencyDialogView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.tipTxt = self.___ex.tipTxt
    self.closeBtn = self.___ex.closeBtn
    self.addTxt = self.___ex.addTxt
    self.minusTxt = self.___ex.minusTxt
    self.currencyImg = self.___ex.currencyImg
--------End_Auto_Generate----------
end

function RewardCurrencyDialogView:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function RewardCurrencyDialogView:Close()
    DialogAnimation.Disappear(self.transform, nil, function() self.closeDialog() end)
end

function RewardCurrencyDialogView:InitView(title, tip, isPlus, contents)
    self.titleTxt.text = title
    self.tipTxt.text = tip
    local num = contents.morale or contents.fight or contents.num
    local crrencyType = contents.type or next(contents)
    local currencyPath = CurrencyImagePath[crrencyType]
    if isPlus then
        self.addTxt.text = "+" .. num
    else
        self.minusTxt.text = "-" .. num
    end
    self.currencyImg.overrideSprite = res.LoadRes(currencyPath)
    GameObjectHelper.FastSetActive(self.addTxt.gameObject, isPlus)
    GameObjectHelper.FastSetActive(self.minusTxt.gameObject, not isPlus)
end

return RewardCurrencyDialogView
