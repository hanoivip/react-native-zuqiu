local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardTrainingConstant = require("ui.scene.cardTraining.CardTrainingConstant")

local CardTrainingLevelStateView = class(unity.base)

function CardTrainingLevelStateView:ctor()
    self.finishTitleTxt = self.___ex.finishTitleTxt
    self.openTitleTxt = self.___ex.openTitleTxt
    self.notOpenTitleTxt = self.___ex.notOpenTitleTxt
    self.plusAttribute = self.___ex.plusAttribute
    self.lockTxt = self.___ex.lockTxt
    self.levelView = self.___ex.levelView
    self.finish = self.___ex.finish
    self.notOpen = self.___ex.notOpen
    self.open = self.___ex.open
    self.skillInfo = self.___ex.skillInfo
    self.levelUpAnim = self.___ex.levelUpAnim
end

function CardTrainingLevelStateView:start()
end

function CardTrainingLevelStateView:InitView(cardTrainingMainModel)
    local lvl = cardTrainingMainModel:GetCurrLevelSelected()
    local name = cardTrainingMainModel:GetNameByLevel(lvl)
    self.finishTitleTxt.text = name
    self.openTitleTxt.text = name
    self.notOpenTitleTxt.text = name
    self.lockTxt.text = lang.trans("card_training_not_open", name, name)

    local tag = cardTrainingMainModel:GetCurrLevelSelected()
    local isLock = cardTrainingMainModel:GetIsLockByLevel(tag)
    local isFinish = cardTrainingMainModel:GetIsFinishByLevel(tag)

    GameObjectHelper.FastSetActive(self.notOpen, isLock)
    GameObjectHelper.FastSetActive(self.finish, isFinish)
    GameObjectHelper.FastSetActive(self.open, (not isLock) and (not isFinish))

    local subId = cardTrainingMainModel:GetSubIdByLevel(tag)
    -- 
    if subId and subId <= CardTrainingConstant.MaxSubId then
        self.levelView:InitView(subId, tag % 2 ~= 0)
        local attributeName, attributeImprove = cardTrainingMainModel:GetAttributePlusByLevel(lvl)

        for k, v in pairs(self.plusAttribute) do
            if attributeName[tonumber(k)] then
                GameObjectHelper.FastSetActive(v.gameObject, true)
                v.text = attributeName[tonumber(k)] .. "  " .. "<color=#FCFEBC>" .. "+" .. (attributeImprove[#attributeName] or attributeImprove[tonumber(1)]) .. "</color>"
            else
                GameObjectHelper.FastSetActive(v.gameObject, false)
            end
        end
        GameObjectHelper.FastSetActive(self.skillInfo.gameObject, false)
        -- 技能描述
        if not next(attributeName) then
            self.skillInfo.text = cardTrainingMainModel:GetSkillDescData(lvl)
            GameObjectHelper.FastSetActive(self.skillInfo.gameObject, true)
        end
    end
end

function CardTrainingLevelStateView:PlayLevelUpAnim()
    self.levelUpAnim:Play("CardTrainingCanvasDetailBg")  --Lua assist checked flag
end

function CardTrainingLevelStateView:onDestroy()

end

return CardTrainingLevelStateView

