local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local FloorBuffView = class(LuaButton)

function FloorBuffView:ctor()
    FloorBuffView.super.ctor(self)
	self.arrow = self.___ex.arrow
	self.sign = self.___ex.sign
	self.buffNumTxt = self.___ex.buffNum
	self.BuffValueTxt = self.___ex.value
    self.floorTxt = self.___ex.floorTxt
    self.bg = self.___ex.bg
    self:regOnButtonDown(function()
        self:OnBuffDown()
    end)
    self:regOnButtonUp(function()
        self:OnBuffUp()
    end)
end

function FloorBuffView:DisableBg()
    GameObjectHelper.FastSetActive(self.bg.gameObject, false)
end

local Space = 20 -- 与提示框隔离距离
function FloorBuffView:OnBuffDown()
    local transVec = self.transform.root:InverseTransformPoint(self.transform.position)
    local selfWidth = self.transform.rect.width
    local selfHeight = self.transform.rect.height
    local rootWidth = self.transform.root.rect.width
    local rootHeight = self.transform.root.rect.height
    local half = rootWidth / 2
    local fixPosX = half + transVec.x + selfWidth / 2 + Space
    local fixPosY = transVec.y + rootHeight / 2 - selfHeight + Space

    local title = lang.trans("buff_fixed")
    local symbol = self.buffValue >= 0 and "+" or ""
    local colorHex = self.buffValue >= 0 and "#D1F701FF" or "red"
    local attributeTxt = lang.transstr("allAttribute") .. ": " .. "<color=" .. colorHex .. ">" .. symbol .. self.buffValue .. "%" .. "</color>"
    local numTxt = lang.transstr("buff_nums") .. ": " .. "<color=yellow>" .. self.buffNum .. "</color>"
    local floorTxt = lang.transstr("buff_get", self.floor)
    local desc = attributeTxt .. "\n" .. numTxt .. "\n" .. floorTxt
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/BuffInfo.prefab", "camera", true, false)
    dialogcomp.contentcomp:InitView(fixPosX, fixPosY, title, desc)
    self.dialogcomp = dialogcomp
end

function FloorBuffView:OnBuffUp()
    if self.dialogcomp then
        self.dialogcomp:closeDialog()
        self.dialogcomp = nil
    end
end

function FloorBuffView:InitView(floor, data, greenswardResourceCache)
    self.floor = floor
    local buff = 0
    local num = 1
    for k, v in pairs(data) do
        buff = k
        num = v
    end
    self.buffValue = tonumber(buff)
    self.buffNum = tonumber(num)

    self.arrow.overrideSprite = greenswardResourceCache:GetArrowRes(buff)
    self.buffNumTxt.text = "x" .. tostring(num)
    self.BuffValueTxt.text = tostring(buff) .. "%"
    self.floorTxt.text = "F" .. floor
end

return FloorBuffView