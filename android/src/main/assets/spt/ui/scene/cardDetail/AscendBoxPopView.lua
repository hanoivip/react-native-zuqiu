local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AscendBoxPopView = class(unity.base)

function AscendBoxPopView:ctor()
    self.ascendTitle = self.___ex.ascendTitle
    self.abilityMap = self.___ex.abilityMap
    self.skillLimit = self.___ex.skillLimit
    self.confirm = self.___ex.confirm
    self.anim = self.___ex.anim
end 

function AscendBoxPopView:start()
    DialogAnimation.Appear(self.transform)
    self.confirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function AscendBoxPopView:OnBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function AscendBoxPopView:Close()
    self.anim:Play("AscendPopAnimationLeave")
end

function AscendBoxPopView:OnLeaveAnimEnd()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

local normalPlayerOrder = {
    "shoot",
    "intercept",
    "steal",
    "dribble",
    "pass"
}
local goalKeeperOrder = {
    "goalkeeping",  -- 门线技术
    "anticipation", -- 球路判断
    "commanding",   -- 防线指挥
    "composure",    -- 心理素质
    "launching"     -- 发起进攻
}

local function GetAbility(cardModel)
    local pentagonOrder
    if cardModel:IsGKPlayer() then
        pentagonOrder = goalKeeperOrder
    else
        pentagonOrder = normalPlayerOrder
    end

    local fiveAbilityValueList = {}
    for i, abilityIndex in ipairs(pentagonOrder) do
        local base, plus = cardModel:GetAbility(abilityIndex)
        local totalValue = base + plus
        table.insert(fiveAbilityValueList, {value = totalValue, key = abilityIndex})
    end

    return fiveAbilityValueList
end

function AscendBoxPopView:InitView(oldCardModel, newCardModel)
    local ascend = newCardModel:GetAscend()
    self.ascendTitle.text = lang.trans("max_ascend_num", ascend) 
    local oldSkillMaxLvl = oldCardModel:GetMaxSkillLevel(ascend - 1) or 0
    local newSkillMaxLvl = newCardModel:GetMaxSkillLevel(ascend) or 0
    local skillAdd = " +" .. (newSkillMaxLvl - oldSkillMaxLvl)
    self.skillLimit.text = lang.trans("skill_level_limit", skillAdd)

    local oldfiveAbilityValueList = GetAbility(oldCardModel)
    local newfiveAbilityValueList = GetAbility(newCardModel)
    for k, view in pairs(self.abilityMap) do
        local index = tonumber(string.sub(k, 2))
        view:InitView(oldfiveAbilityValueList[index], newfiveAbilityValueList[index])
    end
end

return AscendBoxPopView
