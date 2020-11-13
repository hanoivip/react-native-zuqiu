local AdventureEventCount = require("data.AdventureEventCount")
local GreenswardEvnetEnum = require("ui.scene.greensward.GreenswardEvnetEnum")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local BuffFrameView = class(unity.base)

function BuffFrameView:ctor()
    self.floor = self.___ex.floor
    self.buffValue = self.___ex.buffValue
    self.buffNum = self.___ex.buffNum
    self.statueTxt = self.___ex.statueTxt
    self.sign = self.___ex.sign
    self.bg = self.___ex.bg
end

local function GetBuffMaxNumByCurrentFloor(currentFloor)
    local buffCountData = AdventureEventCount[tostring(GreenswardEvnetEnum.Fitness)] or {}
    local key = "f" .. tostring(currentFloor) .. "Count"
    local currentBuffData = buffCountData[tostring(key)] or {}
    currentBuffData = currentBuffData[1] or {} --根据表的数据格式解析
    local maxCount = currentBuffData[2] or 1
    return maxCount
end

function BuffFrameView:InitView(greenswardBuildModel, index, data, greenswardResourceCache)
    self.floor.text = tostring(index)

    local currentFloor = greenswardBuildModel:GetCurrentFloor()
    local openFloor = greenswardBuildModel:GetOpenFloor()
    local color = ColorConversionHelper.ConversionColor(255, 255, 255)
    local buffValueTxt, buffNumTxt, statueTxt = "", "", ""
    local buffValue = data.buffValue
    if openFloor >= index then
        local hasActive = tobool(currentFloor >= index)
        if buffValue then
            self.sign.overrideSprite = greenswardResourceCache:GetArrowRes(buffValue)
            buffValueTxt = lang.transstr("allAttribute") .. "+" .. buffValue .. "%"
            local maxCount = GetBuffMaxNumByCurrentFloor(index)
            local currentBuffNum = tostring(data.buffNum)
            buffNumTxt = currentBuffNum .. "/" .. tostring(maxCount)
            color = hasActive and ColorConversionHelper.ConversionColor(252, 252, 151) or color
            statueTxt = hasActive and lang.trans("assistant_coach_info_used_1") or lang.trans("isInvalid")
        else
            buffValueTxt = lang.trans("buff_not_owned")
            statueTxt = ""
        end
    else
        statueTxt = ""
        buffValueTxt = lang.trans("floor_not_open")
    end

    self.statueTxt.text = statueTxt
    self.buffValue.text = buffValueTxt
    self.buffNum.text = buffNumTxt
    self.statueTxt.color = color
    self.buffValue.color = color
    self.buffNum.color = color
    GameObjectHelper.FastSetActive(self.bg, tobool(index % 2 == 1))
    GameObjectHelper.FastSetActive(self.sign.gameObject, buffValue)
end

return BuffFrameView