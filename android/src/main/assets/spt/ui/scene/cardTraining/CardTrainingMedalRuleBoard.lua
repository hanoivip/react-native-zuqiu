local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Skills = require("data.Skills")
local CardTrainingMedalRuleBoard = class(unity.base)

function CardTrainingMedalRuleBoard:ctor()
    self.btnClose = self.___ex.btnClose
    self.mName = self.___ex.mName
    self.mValue = self.___ex.mValue
    self.mItem = self.___ex.mItem

    DialogAnimation.Appear(self.transform, nil)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

local Order = {"base", "extra", "skill"}
function CardTrainingMedalRuleBoard:InitView(data)
    for k,v in pairs(self.mItem) do
        GameObjectHelper.FastSetActive(v.gameObject, not not data[k])
    end
    local index = 1
    for k,v in pairs(data) do
        self.mValue[Order[index]].text = self:GetItemStr(Order[index], data[Order[index]])
        index = index + 1
    end
end

function CardTrainingMedalRuleBoard:GetItemStr(name, value)
    local  str = ""
    if name == "extra" then
        str = self.mValue["base"].text .. lang.transstr("card_training_attr_add", (tonumber(value.min) * 0.1) .. "%")
        return str
    end
    if name == "base" then
        for k,v in pairs(value) do
            str = str .. lang.transstr(v) .. "/"
        end
        return string.sub(str, 1, #str - 1)
    end
    if name == "skill" then
        for k,v in pairs(value) do
            str = str .. Skills[v.skillName].skillName .. "(Lv" .. v.lvl ..")/"
        end
        return string.sub(str, 1, #str - 1)
    end
    return str
end

function CardTrainingMedalRuleBoard:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return CardTrainingMedalRuleBoard
