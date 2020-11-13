local UnityEngine = clr.UnityEngine
local RapidBlurEffect = clr.RapidBlurEffect
local Camera = UnityEngine.Camera
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TipUpgradeView = class(unity.base)

function TipUpgradeView:ctor()
    self.skillHolesMap = self.___ex.skillHolesMap
    self.equipHolesMap = self.___ex.equipHolesMap
    self.linesMap = self.___ex.linesMap
    self.btnClick = self.___ex.btnClick
    self.tips = self.___ex.tips
end

function TipUpgradeView:InitView(cardDetailModel)
    local equipsList = cardDetailModel:GetEquipsList()
    local skillsList = cardDetailModel:GetSkillsList()

    local nextOpenIndex = 1
    for i, v in ipairs(skillsList) do
        if v.isOpen and not v.ptid then
            nextOpenIndex = nextOpenIndex + 1
        end
    end

    local equipNum = #equipsList
    local skillNum = #skillsList

    for i = 1, 6 do
        -- 装备区域
        local equipHole = self.equipHolesMap["s" .. tostring(i)]
        GameObjectHelper.FastSetActive(equipHole.gameObject, i <= equipNum)
        -- 技能区域
        local lineHole = self.skillHolesMap["s" .. tostring(i)]

        local isPoint = tobool((nextOpenIndex <= skillNum) and (i == nextOpenIndex))
        GameObjectHelper.FastSetActive(lineHole.gameObject, isPoint)

        -- 线
        local line = self.linesMap["s" .. tostring(i)]
        local isShow = false
        if i <= equipNum then
            isShow = true
            line:InitView(i, equipNum, nextOpenIndex, skillNum)
        end
        GameObjectHelper.FastSetActive(line.gameObject, isShow)
    end

    self.tips.text = lang.trans("tip_upgrade1")
end

function TipUpgradeView:start()
    local rapidBlurEffect = Camera.main.gameObject:GetComponent(RapidBlurEffect)
    if rapidBlurEffect then
        rapidBlurEffect.enabled = false
    end
    self.btnClick:regOnButtonClick( function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return TipUpgradeView
