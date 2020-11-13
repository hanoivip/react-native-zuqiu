local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local UI = UnityEngine.UI
local Text = UI.Text

local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local TrainingUnlock = require("data.TrainingUnlock")

local CardTrainingResultView = class(unity.base)

function CardTrainingResultView:ctor()
    self.tipTxt = self.___ex.tipTxt
    self.vertialRect = self.___ex.vertialRect
    self.finishArea = self.___ex.finishArea
    self.gridRect = self.___ex.gridRect
    self.skillImg = self.___ex.skillImg
    self.skillNameTxt = self.___ex.skillNameTxt
    self.skillDescTxt = self.___ex.skillDescTxt
    self.noGain = self.___ex.noGain
    self.lock = self.___ex.lock
end

function CardTrainingResultView:start()
end

function CardTrainingResultView:InitView(cardTrainingMainModel)
    self.tipTxt.text = lang.trans("card_training_achievement", cardTrainingMainModel:GetName())
    local option = cardTrainingMainModel:GetOption()

    local lvl = cardTrainingMainModel:GetCurrLevelSelected()
    local subId = cardTrainingMainModel:GetSubIdByLevel(lvl)
    GameObjectHelper.FastSetActive(self.finishArea, tonumber(subId) > CardTrainingConstant.MaxSubId and tonumber(option) == 2)
    GameObjectHelper.FastSetActive(self.vertialRect.gameObject, tonumber(subId) <= CardTrainingConstant.MaxSubId or tonumber(option) == 1)
    GameObjectHelper.FastSetActive(self.lock, false)

    local effect = cardTrainingMainModel:GetFinishAttribute()
    GameObjectHelper.FastSetActive(self.noGain, not effect)

    if effect then
        local txtList = clr.table(self.gridRect:GetComponentsInChildren(Text))  --Lua assist checked flag
        local index = 1
        if effect.advanceAttr then
            for k, v in pairs(effect.advanceAttr) do
                txtList[index].text = lang.transstr(k) .. "<color=#FCFEBC>" .. " +" .. v .. "</color>"
                index = index + 1
            end
        end
        txtList = clr.table(self.vertialRect:GetComponentsInChildren(Text))  --Lua assist checked flag
        local index = 1
        if effect.advanceAttr then
            for k, v in pairs(effect.advanceAttr) do
                txtList[index].text = lang.transstr(k) .. "<color=#FCFEBC>" .. " +" .. v .. "</color>"
                index = index + 1
            end
        end
    else
        GameObjectHelper.FastSetActive(self.vertialRect.gameObject, false)
        GameObjectHelper.FastSetActive(self.finishArea, false)
    end

    local exSkillName, isLock, isOpen = cardTrainingMainModel:GetExSkillInfo()
    if not self.skillModel then
        self.skillModel = SkillItemModel.new()
        self.skillModel:InitByID(exSkillName)
    else
        self.skillModel:InitByID(exSkillName)
    end
    if exSkillName then
        self.skillImg.overrideSprite = AssetFinder.GetSkillIcon(self.skillModel:GetIconIndex())
        self.skillNameTxt.text = self.skillModel:GetName()
        self.skillDescTxt.text = self.skillModel:GetDesc() or ""
        if not isLock then
            GameObjectHelper.FastSetActive(self.lock, true)
            -- 有可能没有勋章要求
            if TrainingUnlock[tostring(lvl)].medalCondition then
                local qualityNo
                local num
                for k, v in pairs(TrainingUnlock[tostring(lvl)].medalCondition) do
                    qualityNo = k
                    num = v
                end
                self.skillDescTxt.text = lang.trans("card_training_skill_lock", num, string.convertMedalNoToQuality(qualityNo))
            end
        end
        if not isOpen then
            self.skillDescTxt.text = lang.trans("commingSoon")
        end
    end
end

function CardTrainingResultView:onDestroy()

end

return CardTrainingResultView

