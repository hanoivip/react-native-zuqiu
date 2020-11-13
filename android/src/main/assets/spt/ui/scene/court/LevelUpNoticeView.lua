local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local Skills = require("data.Skills")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LevelUpNoticeView = class(unity.base)

function LevelUpNoticeView:ctor()
    self.optionIcon = self.___ex.optionIcon
    self.optionDescText = self.___ex.optionDescText
    self.comfirm = self.___ex.comfirm
    self.lvl = self.___ex.lvl
    self.normal = self.___ex.normal
    self.max = self.___ex.max
end

function LevelUpNoticeView:start()
    self.comfirm:regOnButtonClick(function()
        self:Close()
    end)
end

function LevelUpNoticeView:Close()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
    GuideManager.Show(self)
end

function LevelUpNoticeView:InitView(courtBuildModel, courtBuildType, lvl)
    local isMax = courtBuildModel:IsBuildMaxLvl(courtBuildType, lvl)
    if not isMax then 
        local icon = courtBuildModel:GetBuildIcon(courtBuildType, lvl)
        self.optionIcon.overrideSprite = CourtAssetFinder.GetCourtIcon(courtBuildType, icon)
        self.lvl.text = "Lv" .. tostring(lvl)
        local conditionDesc = courtBuildModel:GetBuildUpgradeEffectDesc(courtBuildType)

        local isEffectSkill, effect, point = courtBuildModel:GetEffect(courtBuildType, lvl)
        if isEffectSkill then 
            local descStr = string.split(conditionDesc, "#")
            local skillDesc = ""
            for i, sid in ipairs(effect) do
                local symbol = ""
                if i < #effect then 
                    symbol = "、"
                end
                local name = Skills[tostring(sid)].skillName
                skillDesc = skillDesc .. name .. symbol
            end
            conditionDesc = descStr[1] .. " <color=#66bcf2>" .. skillDesc .. "</color>".. descStr[2] .. " <color=red>" .. lang.transstr("reduce_num", point) .. "</color>"
        elseif point then 
            conditionDesc = conditionDesc .. " <color=red>" .. lang.transstr("reduce_point", point) .. "</color>"
        end
        self.optionDescText.text = tostring(conditionDesc)
    end
    GameObjectHelper.FastSetActive(self.normal, not isMax)
    GameObjectHelper.FastSetActive(self.max, isMax)
end

return  LevelUpNoticeView
