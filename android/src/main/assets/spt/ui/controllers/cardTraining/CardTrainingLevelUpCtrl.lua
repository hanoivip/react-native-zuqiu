local Item = require("data.Item")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local CardTrainingLevelUpCtrl = class()

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

function CardTrainingLevelUpCtrl:ctor(cardTrainingMainModel, parent)
    self:Init(cardTrainingMainModel, parent)
end

function CardTrainingLevelUpCtrl:ShowGameObject()
    GameObjectHelper.FastSetActive(self.levelUpView.gameObject, true)
    self.levelUpView:InitView()
end

function CardTrainingLevelUpCtrl:HideGameObject()
    GameObjectHelper.FastSetActive(self.levelUpView.gameObject, false)
    self.levelUpView:HideAnimatorGO()
end

function CardTrainingLevelUpCtrl:Init(cardTrainingMainModel, parent)
    self.cardTrainingMainModel = cardTrainingMainModel
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/LevelUpContent.prefab")
    pageObject.transform:SetParent(parent, false)
    self.itemsMapModel = ItemsMapModel.new()
    self.levelUpView = pageSpt
    self.levelUpView:InitView(cardTrainingMainModel, self.itemsMapModel)

    self.levelUpView.onConfirmBtnClick = function ()
        self:OnConfirmBtnClick()
    end

    self.levelUpView.clickExpItemDown = function() return self:OnExpItemLevelDown() end
    self.levelUpView.clickExpItemPressing = function(level, itemCount) return self:OnExpItemLevelPressing(level, itemCount) end
    self.levelUpView.clickExpItemUp = function(level, itemCount) self:OnExpItemLevelUp(level, itemCount) end
    self.levelUpView.resetItemNumCallBack = function(id, num) self:ResetItemNumCallBack(id, num) end
end

function CardTrainingLevelUpCtrl:OnExpItemLevelDown()
    self.cardAddExp = self.cardTrainingMainModel:GetExp()
    local needExp = self.cardTrainingMainModel:GetNeedExp()
    local message;
    if self.cardAddExp >= needExp then
        message = "expOverflow"
    end
    return message;
end

function CardTrainingLevelUpCtrl:OnExpItemLevelPressing(level, itemCount)
    local message, tmpExp, overflowCount, beforeItemCount = self:JudgeErrorWhenEatExpItem(level, math.max(1, itemCount))
    itemCount = overflowCount or itemCount
    if message then
        local tip
        if message == "itemNotEnough" then
            tip = lang.trans("tip_exp1")
        elseif message == "expOverflow" then
            tip = lang.trans("tip_exp4")
        end
        self.levelUpView:PopToast(tip)
    end

    self.levelUpView:SetItem(level, beforeItemCount - itemCount)
    self.levelUpView:SetProgress(tmpExp)

    return message
end

function CardTrainingLevelUpCtrl:OnExpItemLevelUp(level, itemCount)
    local message, tmpExp, overflowCount, beforeItemCount = self:JudgeErrorWhenEatExpItem(level, math.max(1, itemCount))
    itemCount = overflowCount or itemCount
    if message then
        local tip
        if message == "itemNotEnough" then
            tip = lang.trans("tip_exp1")
        elseif message == "expOverflow" then
            tip = lang.trans("tip_exp4")
        end
        self.levelUpView:PopToast(tip)
    end

    if itemCount <= 1 then
        self.levelUpView:SetLevelUpEffectOnce()
    end
    self.levelUpView:SetProgress(tmpExp)
    self:RequestAddExp(expItemIDMap[level], math.max(1, itemCount))
end

function CardTrainingLevelUpCtrl:JudgeErrorWhenEatExpItem(level, itemCount)
    local message, judgeCount = nil, itemCount
    -- 道具数量
    local beforeItemCount = self.itemsMapModel:GetItemNum(expItemIDMap[level])
    if itemCount > beforeItemCount then
        judgeCount = beforeItemCount
        message = "itemNotEnough"
    end

    -- 经验
    local itemStaticData = Item[tostring(expItemIDMap[level])]
    local expItemAddExp = itemStaticData["function"].cardExp or 0

    local needTotalExp = self.cardTrainingMainModel:GetNeedExp()
    local currExp = self.cardTrainingMainModel:GetExp()
    -- 加上经验饮料之后的经验总量
    local addedExp = judgeCount * expItemAddExp + currExp

    if addedExp > needTotalExp then
        message = "expOverflow"
        judgeCount = math.ceil((needTotalExp - currExp) / expItemAddExp)
        judgeCount = math.max(0, judgeCount)
        addedExp = needTotalExp
    end

    return message, addedExp, judgeCount, beforeItemCount
end

function CardTrainingLevelUpCtrl:RequestAddExp(itemID, num)
    local pcid = self.cardTrainingMainModel:GetPcid()
    local lvl = self.cardTrainingMainModel:GetCurrLevelSelected()
    local subId = self.cardTrainingMainModel:GetSubIdByLevel(lvl)

    clr.coroutine(function ()
        local respone = req.cardTrainingAddExp(pcid, itemID, num, lvl, subId)
        if api.success(respone) then
            local data = respone.val
            for k, v in pairs(data.subTrain) do
                if type(v) == "table" and v.exp ~= nil then
                    self.cardTrainingMainModel:SetExp(v.exp)
                end
            end
            if data.cost ~= nil then
                self.itemsMapModel:ResetItemNum(data.cost.id, data.cost.curr_num)
            end
        end
    end)
end

function CardTrainingLevelUpCtrl:ResetItemNumCallBack(id, num)
    if not expItemIndexMap[id] then return end
    
    self.levelUpView:SetItem(expItemIndexMap[id], num)
end

function CardTrainingLevelUpCtrl:OnConfirmBtnClick()
    local pcid = self.cardTrainingMainModel:GetPcid()
    local lvl = self.cardTrainingMainModel:GetCurrLevelSelected()
    local subId = self.cardTrainingMainModel:GetSubIdByLevel(lvl)
    local option = self.cardTrainingMainModel:GetOption()

    if not self.levelUpView.isFinish then
        DialogManager.ShowToastByLang("card_training_finish_tip")
        return
    end

    local function server()
        clr.coroutine(function ()
            local respone = req.cardTrainingFinish(pcid, lvl, subId, option)
            if api.success(respone) then
                local data = respone.val
                if data.cost then
                    assert(data.cost.curr_num, "server has problem!")
                    PlayerInfoModel.new():SetDiamond(data.cost.curr_num)
                end
                assert(data.card, "server need return card info")
                if data.card then
                    PlayerCardsMapModel.new():ResetCardData(data.card.pcid, data.card)
                end
                if data.supporterCard and data.supporterCard.pcid then
                    PlayerCardsMapModel.new():ResetCardData(data.supporterCard.pcid, data.supporterCard)
                end
                EventSystem.SendEvent("CardTraining_RefreshMainView")
            end
        end)
    end

    local coolTime = self.cardTrainingMainModel:GetCurrLvlCoolTime()
    if coolTime and coolTime > 0 then
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("card_training_cooltime_tip", math.ceil(coolTime / 1800) * 50), function ()
            server()
        end)
    else
        server()
    end
end

return CardTrainingLevelUpCtrl
