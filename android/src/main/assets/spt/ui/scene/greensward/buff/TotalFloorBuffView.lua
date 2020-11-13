local FloorBuffView = require("ui.scene.greensward.buff.FloorBuffView")
local TotalFloorBuffView = class(FloorBuffView)

function TotalFloorBuffView:ctor()
    TotalFloorBuffView.super.ctor(self)
end

local Space = 20 -- 与提示框隔离距离
function TotalFloorBuffView:OnBuffDown()
    local transVec = self.transform.root:InverseTransformPoint(self.transform.position)
    local selfWidth = self.transform.rect.width
    local selfHeight = self.transform.rect.height
    local rootWidth = self.transform.root.rect.width
    local rootHeight = self.transform.root.rect.height
    local half = rootWidth / 2
    local fixPosX = half + transVec.x + selfWidth / 2 + Space
    local fixPosY = transVec.y + rootHeight / 2 - selfHeight + Space

    local title = lang.trans("buff_fixed_total")
    local symbol = self.buffValue >= 0 and "+" or ""
    local colorHex = self.buffValue >= 0 and "#D1F701FF" or "red"
    local attributeTxt = lang.transstr("allAttribute") .. ": " .. "<color=" .. colorHex .. ">" .. symbol .. self.buffValue .. "%" .. "</color>"
    local activeDesc = lang.transstr("buff_active", "<color=yellow>" .. self.currentFloor .. "</color>")
    local desc = attributeTxt .. "\n" .. activeDesc
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/BuffInfo.prefab", "camera", true, false)
    dialogcomp.contentcomp:InitView(fixPosX, fixPosY, title, desc)
    self.dialogcomp = dialogcomp
end

function TotalFloorBuffView:InitView(currentFloor, data, greenswardResourceCache)
    self.currentFloor = currentFloor
    local buff = 0
    local buffNum = 0
    for floor, v in pairs(data) do
        if tonumber(floor) <= currentFloor then
            for value, num in pairs(v) do
                buff = buff + value * num
                buffNum = buffNum + num
            end
        end
    end
    self.buffValue = tonumber(buff)
    self.buffNum = buffNum

    self.arrow.overrideSprite = greenswardResourceCache:GetArrowRes(buff)
    self.BuffValueTxt.text = tostring(buff) .. "%"
    self.floorTxt.text = "Buff"
end

return TotalFloorBuffView