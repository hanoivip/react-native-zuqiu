local PlayerLevelUpCtrl = class()
local Item = require("data.Item")
local CustomEvent = require("ui.common.CustomEvent")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local abilityNameMap = {
    "pass", "dribble", "shoot", "intercept", "steal", "save",
}
-- 从低到高品质经验卡的道具ID
local expItemIDMap = {
    1001, 1002, 1003, 1004
}
local expItemIndexMap = {
    [1001] = 1,
    [1002] = 2,
    [1003] = 3,
    [1004] = 4    
}

function PlayerLevelUpCtrl:ctor(cardDetailModel)
    assert(cardDetailModel)
    self.cardDetailModel = cardDetailModel

    local viewObject, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/PlayerLevelup.prefab", "camera", false, true)
    self.levelUpView = dialogcomp.contentcomp

    self:InitView()

    self.levelUpView.clickExpItemDown = function()
        self.cacheExp = self.cardDetailModel:GetCardModel():GetExp()
    end
    self.levelUpView.clickExpItemPressing = function(level, itemCount) return self:OnExpItemLevelPressing(level, itemCount) end
    self.levelUpView.clickExpItemUp = function(level, itemCount) self:OnExpItemLevelUp(level, itemCount) end

    self.levelUpView.levelUpCallBack = function() self:LevelUpCallBack() end
    self.levelUpView.addExpCallBack = function() self:AddExpCallBack() end
	self.levelUpView.resetItemNumCallBack = function(id, num) self:ResetItemNumCallBack(id, num) end
    self.levelUpView.onClickArea =  function()
        -- 关闭升级界面
        GuideManager.Show(res.curSceneInfo.ctrl)
    end
end

function PlayerLevelUpCtrl:InitView(cardDetailModel)
    if cardDetailModel then
        self.cardDetailModel = cardDetailModel
    end

    self.levelUpView.gameObject:SetActive(true)
    self.levelUpView:InitView(self.cardDetailModel:GetCardModel(), self.cardDetailModel:GetItemsMapModel())

    return true
end

function PlayerLevelUpCtrl:HideView()
    self.levelUpView.gameObject:SetActive(false)
end

function PlayerLevelUpCtrl:HideParticle()
    self.levelUpView:HideParticle()
end

function PlayerLevelUpCtrl:LevelUpCallBack()
    self.levelUpView:ShowAbilityIncrease(self:GetCardAbility(), self.cacheAbility)
end

function PlayerLevelUpCtrl:AddExpCallBack()
    self.levelUpView:ExecuteAddExpAnimation(self.cardDetailModel:GetCardModel():GetExp())
end

function PlayerLevelUpCtrl:ResetItemNumCallBack(id, num)
    if not expItemIndexMap[id] then return end
    
    self.levelUpView:SetItem(expItemIndexMap[id], num)
end

function PlayerLevelUpCtrl:OnExpItemLevelPressing(level, itemCount)
    local message, tmpExp, tmpLevel = self:JudgeErrorWhenEatExpItem(level, itemCount)
    if message then
        local tip 
        if message == "itemNotEnough" then 
            tip = lang.trans("tip_exp1")
        else
            if self.cardDetailModel:GetCardModel():IsMaxLevel() then
                tip = lang.trans("tip_exp3")
            else 
                tip = lang.trans("tip_exp2")
            end
        end
        self.levelUpView:POpToast(tip)
        return message
    else
        self.cacheExp = tmpExp
    end

    local beforeItemCount = self.cardDetailModel:GetItemsMapModel():GetItemNum(expItemIDMap[level])
    local cardModel = self.cardDetailModel:GetCardModel()
    
    self.levelUpView:SetItem(level, beforeItemCount - itemCount)
    self.levelUpView:ExecuteAddExpAnimation(tmpExp)
end

function PlayerLevelUpCtrl:OnExpItemLevelUp(level, itemCount)
    local message, tmpExp, tmpLevel = self:JudgeErrorWhenEatExpItem(level, math.max(1, itemCount))
    if tmpExp <= self.cardDetailModel:GetCardModel():GetExp() or message == "itemNotEnough" then
        print(message)
        local tip 
        if message == "itemNotEnough" then 
            tip = lang.trans("tip_exp1")
        else
            if self.cardDetailModel:GetCardModel():IsMaxLevel() then
                tip = lang.trans("tip_exp3")
            else 
                tip = lang.trans("tip_exp2")
            end
        end
        self.levelUpView:POpToast(tip)
        return 
    end
    if itemCount < 1 then
        self.levelUpView:SetLevelUpEffectOnce()
    end

    self:RequestAddExp(expItemIDMap[level], math.max(1, itemCount))
end

function PlayerLevelUpCtrl:JudgeErrorWhenEatExpItem(level, itemCount)
    local message
    -- 道具数量
    local beforeItemCount = self.cardDetailModel:GetItemsMapModel():GetItemNum(expItemIDMap[level])
    if itemCount > beforeItemCount then
        message = "itemNotEnough"
    end

    -- 经验，等级
    local cardModel = self.cardDetailModel:GetCardModel()
    local itemStaticData = Item[tostring(expItemIDMap[level])]
    local expItemAddExp = itemStaticData["function"].cardExp or 0
    local tmpExp, tmpLevel = cardModel:GetIfAddExp(itemCount * expItemAddExp)

    if tmpExp > self.cacheExp then
        -- 大于当前缓存的exp表示可以吃经验道具
    else
        message = "expOverflow"
    end

    return message, tmpExp, tmpLevel
end

function PlayerLevelUpCtrl:RequestAddExp(itemID, num)
    self:CacheBeforeAddExpAbility()

    local pcid = self.cardDetailModel:GetCardModel():GetPcid()
    clr.coroutine(function()
        local respone = req.cardAddExp(pcid, itemID, num)
        if api.success(respone) then
            local data = respone.val
            self.cardDetailModel:UpdateLevelUp(data)
            if data.isLevel == true then
                CustomEvent.CardLevelUp()
                self.levelUpView:SetLevelUpEffectLast()
            end
            -- 使用第二个经验药水
            GuideManager.Show(self)
        end
    end)    
end

-- 记录吃经验卡之前的各项能力值
function PlayerLevelUpCtrl:CacheBeforeAddExpAbility()
    self.cacheAbility = self:GetCardAbility()
end

function PlayerLevelUpCtrl:GetCardAbility()
    local ret = {}
    local cardModel = self.cardDetailModel:GetCardModel()
    for i, name in ipairs(abilityNameMap) do
        local base, plus = cardModel:GetAbility(name)
        ret[name] = base + plus
    end
    return ret
end

return PlayerLevelUpCtrl
