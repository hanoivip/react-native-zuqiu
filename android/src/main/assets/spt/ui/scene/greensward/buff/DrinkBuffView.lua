local LuaButton = require("ui.control.button.LuaButton")
local DrinkBuffView = class(LuaButton)

function DrinkBuffView:ctor()
    DrinkBuffView.super.ctor(self)
	self.arrow = self.___ex.arrow
	self.sign = self.___ex.sign
    self.buffNumTxt = self.___ex.buffNum
    self.BuffValueTxt = self.___ex.value
    self:regOnButtonDown(function()
        self:OnBuffDown()
    end)
    self:regOnButtonUp(function()
        self:OnBuffUp()
    end)
end

local Space = 20 -- 与提示框隔离距离
function DrinkBuffView:OnBuffDown()
    local transVec = self.transform.root:InverseTransformPoint(self.transform.position)
    local selfWidth = self.transform.rect.width
    local selfHeight = self.transform.rect.height
    local rootWidth = self.transform.root.rect.width
    local rootHeight = self.transform.root.rect.height
    local half = rootWidth / 2
    local fixPosX = half + transVec.x + selfWidth / 2 + Space
    local fixPosY = transVec.y + rootHeight / 2 - selfHeight + Space

    local title = lang.trans("buff_temp")
    local symbol = self.buffValue >= 0 and "+" or ""
    local colorHex = self.buffValue >= 0 and "#D1F701FF" or "red"
    local attributeTxt = lang.transstr("allAttribute") .. ": " .. "<color=" .. colorHex .. ">" .. symbol .. self.buffValue .. "%" .. "</color>"
    local roundTxt = lang.transstr("round_remain", self.buffRound)
    local desc = attributeTxt .. "\n" .. roundTxt
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/BuffInfo.prefab", "camera", true, false)
    dialogcomp.contentcomp:InitView(fixPosX, fixPosY, title, desc)
    self.dialogcomp = dialogcomp
end

function DrinkBuffView:OnBuffUp()
    if self.dialogcomp then
        self.dialogcomp:closeDialog()
        self.dialogcomp = nil
    end
end

function DrinkBuffView:InitView(data, greenswardResourceCache)
    local buff = data.buff or 0
    self.arrow.overrideSprite = greenswardResourceCache:GetArrowRes(buff)
    local num = data.round or 1
    self.buffNumTxt.text = tostring(num)
    self.BuffValueTxt.text = tostring(buff) .. "%"

    self.buffValue = tonumber(buff)
    self.buffRound = tonumber(num)
end

return DrinkBuffView