local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MedalTipView = class(unity.base)

function MedalTipView:ctor()
    self.title = self.___ex.title
    self.content = self.___ex.content
    self.close = self.___ex.close
    self.cancel = self.___ex.cancel
    self.confirm = self.___ex.confirm
    self.tip = self.___ex.tip
    self.tipObject = self.___ex.tipObject
end

function MedalTipView:start()
    self.cancel:regOnButtonClick(function()
        self:OnBtnCancel()
    end)
    self.confirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.close:regOnButtonClick(function()
        self:Close()
    end)

    DialogAnimation.Appear(self.transform)
end

function MedalTipView:OnBtnConfirm()
    if self.clickConfirm then
        self.clickConfirm()
        self:Close()
    end
end

function MedalTipView:OnBtnCancel()
    self:Close()
end

function MedalTipView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

local SignQuality = 4 -- s品质以上勋章会有标记提醒
function MedalTipView:InitView(selectModels)
    local stardust = 0
    local tip = ""
    local selectQualityMap = {}
    local hasBenediction = false
    for i, model in ipairs(selectModels) do
        local splitStardust = model:GetMedalStardust()
        stardust = stardust + splitStardust
        local quality = model:GetQuality() 
        if tonumber(quality) >= SignQuality and not selectQualityMap[tostring(quality)] then 
            if tip ~= "" then 
                tip = tip .. "、"
            end
            tip = tip .. CardHelper.GetQualitySign(tonumber(quality) + 1)
            selectQualityMap[tostring(quality)] = true
        end

        if not hasBenediction and next(model:GetBenediction()) then 
            hasBenediction = true
        end
    end

    if hasBenediction then 
        if tip ~= "" then
            tip = tip .. "、"
        end
        tip = tip .. lang.transstr("benediction")
    end

    local hasSign = hasBenediction or next(selectQualityMap)
    GameObjectHelper.FastSetActive(self.tipObject, hasSign)
    self.title.text = lang.trans("medal_split_title", stardust)
    self.tip.text = lang.transstr("medal_split_tip2") .. tip .. lang.transstr("medal")
end

return MedalTipView