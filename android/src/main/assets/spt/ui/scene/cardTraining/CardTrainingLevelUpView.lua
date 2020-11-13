local UnityEngine = clr.UnityEngine
local Mathf = UnityEngine.Mathf
local Color = UnityEngine.Color
local Time = UnityEngine.Time
local Button = UnityEngine.UI.Button

local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local Timer = require("ui.common.Timer")

local CardTrainingLevelUpView = class(unity.base)

local addUpIntervalTime = 0.3 -- 连续使用经验饮料时的初始时间
local intervalTime = 0.02 -- 连续使用经验饮料时的间隔
local minIntervalTime = 0.001 -- 连续使用经验饮料时的最小时间
local startDurableTime = 1    -- 按下多长时间之后开始连续使用

-- 从低到高品质经验卡的道具ID
local expItemIDMap = {
    1001, 1002, 1003, 1004
}

local AnimatorEffectMap =
{
    "ExpItemLightAnimationLow",
    "ExpItemLightAnimationMiddle",
    "ExpItemLightAnimationHigh",
    "ExpItemLightAnimationSuper"
}

function CardTrainingLevelUpView:ctor()
    self.expItem = self.___ex.expItem
    self.effectMap = self.___ex.effectMap
    self.rateTxt = self.___ex.rateTxt
    self.rateImg = self.___ex.rateImg
    self.confirmBtn = self.___ex.confirmBtn
    self.expItemNum = self.___ex.expItemNum
    self.levelProgress = self.___ex.levelProgress
    self.progressTxt = self.___ex.progressTxt
    self.tipTxt = self.___ex.tipTxt
    self.levelUpAnim = self.___ex.levelUpAnim
    self.priceTxt = self.___ex.priceTxt
    self.coolTimeTxt = self.___ex.coolTimeTxt
    self.coolTimeBtn = self.___ex.coolTimeBtn
end

function CardTrainingLevelUpView:start()
    self.confirmBtn:regOnButtonClick(function ()
        if self.onConfirmBtnClick then
            self.onConfirmBtnClick()
        end
    end)
    self.coolTimeBtn:regOnButtonClick(function ()
        if self.onConfirmBtnClick then
            self.onConfirmBtnClick()
        end
    end)

    for i = 1, 4 do
        self.expItem["level" .. tostring(i)]:regOnButtonDown(function()
            self:OnExpItemLevelDown(i)
        end)
        self.expItem["level" .. tostring(i)]:regOnButtonUp(function()
            self:OnExpItemLevelUp(i)
        end)
    end

    self.levelUpStartAudio = audio.GetPlayer("levelUpStart")
    self.levelUpEndAudio = audio.GetPlayer("levelUpEnd")
    self.levelUpRotationAudio = audio.GetPlayer("levelUpRotation")
    EventSystem.AddEvent("ItemsMapModel_ResetItemNum", self, self.EventResetItemNum)
    EventSystem.AddEvent("CardTraining_RefreshCoolTime", self, self.RefreshCoolTime)
    EventSystem.AddEvent("ToastDestroy", self, self.ToastDestroy)
end

function CardTrainingLevelUpView:InitView(cardTrainingMainModel, itemsMapModel)
    self.cardTrainingMainModel = cardTrainingMainModel or self.cardTrainingMainModel
    self.itemsMapModel = itemsMapModel or self.itemsMapModel
    for i = 1, 4 do
        self.expItemNum["level" .. tostring(i)].text = "x" .. tostring(tonumber(self.itemsMapModel:GetItemNum(expItemIDMap[i])))
    end

    local currExp = self.cardTrainingMainModel:GetExp()
    local needExp = self.cardTrainingMainModel:GetNeedExp()
    local percent = currExp / needExp
    self.levelProgress.fillAmount = math.min(percent, 1)
    self.progressTxt.text = string.format("%.2f" ,math.min(percent, 1) * 100) .. "%"

    self.confirmBtn:onPointEventHandle(currExp >= needExp)
    self.confirmBtn.gameObject:GetComponent(Button).interactable = currExp >= needExp

    local coolTime = self.cardTrainingMainModel:GetCurrLvlCoolTime()
    self.coolDownPrice = self.cardTrainingMainModel:GetCoolDownPrice()
    GameObjectHelper.FastSetActive(self.coolTimeBtn.gameObject, coolTime)
    GameObjectHelper.FastSetActive(self.confirmBtn.gameObject, not coolTime)
    local lvl = self.cardTrainingMainModel:GetCurrLevelSelected()
    self.lvl = lvl
    local subId = self.cardTrainingMainModel:GetSubIdByLevel(lvl)
    self.subId = subId
    local langKey = (tonumber(self.lvl) == 1 and tonumber(self.subId) == 1) and "card_training_levelup_first" or "card_training_levelup"
    self.tipTxt.text = lang.trans(langKey, needExp, self.cardTrainingMainModel:GetColdDownHour())

    if coolTime then
        self:RefreshCoolTime(self.lvl, self.subId, coolTime)
        if self.timer then
            self.timer:Destroy()
            self.timer = nil
        end
        self.timer = Timer.new(coolTime, function (time)
            self.cardTrainingMainModel:SetCurrLvlCoolTime(lvl, subId, toint(time))
        end)
    end

    self:CheckIsFinish()
end

function CardTrainingLevelUpView:EventResetItemNum(id, num)
    if self.resetItemNumCallBack then
        self.resetItemNumCallBack(id, num)
    end
end

function CardTrainingLevelUpView:RefreshCoolTime(lvl, subId, time)
    if self.lvl ~= lvl or self.subId ~= subId then
        return
    end
    local hour = math.floor(time / 3600)
    local min = time - hour * 60 * 60
    local min = math.floor(min / 60)
    local sec = time - hour * 3600 - min * 60
    self.coolTimeTxt.text = string.format("%02d", hour) .. ":" .. string.format("%02d", min) .. ":" .. string.format("%02d", sec)
    self.priceTxt.text = "x " .. (self.coolDownPrice or 0)  * math.ceil(time / 1800)

    if time <= 0 then
        GameObjectHelper.FastSetActive(self.coolTimeBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.confirmBtn.gameObject, true)
    end
end

function CardTrainingLevelUpView:HideAnimatorGO()
    for k, v in pairs(self.effectMap) do
         GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    self.levelUpAnim.enabled = false
end

function CardTrainingLevelUpView:SetItem(level, num)
    self.expItemNum["level" .. tostring(level)].text = "x" .. tostring(num)
end

function CardTrainingLevelUpView:OnExpItemLevelDown(level)
    self.isTouching = true
    self.lastPressItemIndex = nil
    self.touchStartTime = Time.time
    self.consumeCount = 1
    self.addUpIntervalTime = addUpIntervalTime
    if self.clickExpItemDown then
        local message = self.clickExpItemDown()
        if message and type(message) == "string" then
            return
        end
    end

    -- 按住超过startDurableTime，开始pressing
    local acceleration = 1
    self:coroutine(function()
        while self.isTouching do
            if Time.time - self.touchStartTime > startDurableTime then
                if self.clickExpItemPressing then
                    self:SetEveryTimeEffect(level)
                    local message = self.clickExpItemPressing(level, self.consumeCount)

                    if message and type(message) == "string" then
                        self.errorMessage = message
                        return
                    end
                    self:SetLevelUpEffectOnce()
                    -- 每次使用数量逐渐增大，且加速度逐渐增大
                    self.consumeCount = self.consumeCount + acceleration
                    acceleration = acceleration + 1
                end
            end
            coroutine.yield(UnityEngine.WaitForSeconds(self.addUpIntervalTime))
            -- 使用时间间隔逐渐变小，不小于minIntervalTime
            self.addUpIntervalTime = self.addUpIntervalTime - intervalTime
            Mathf.Clamp(self.addUpIntervalTime, minIntervalTime, self.addUpIntervalTime)
        end
    end)
end

function CardTrainingLevelUpView:OnExpItemLevelUp(level)
    self.isTouching = false
    self.lastPressItemIndex = level
    if self.clickExpItemUp then
        self.clickExpItemUp(level, self.consumeCount)
    end
    self:SetLevelUpEffectLast()
end

function CardTrainingLevelUpView:SetProgress(currExp)
    local needExp = self.cardTrainingMainModel:GetNeedExp()
    local percent = currExp / needExp
    self.levelProgress.fillAmount = math.min(percent, 1)
    self.progressTxt.text = string.format("%.2f" ,math.min(percent, 1) * 100) .. "%"

    if math.min(percent, 1) == 1 then
        self.levelUpAnim.enabled = true
    end

    self.confirmBtn:onPointEventHandle(currExp >= needExp)
    if currExp >= needExp then
        self.isFinish = true
    end
    self.confirmBtn.gameObject:GetComponent(Button).interactable = currExp >= needExp
end

-- 单次点击特效
function CardTrainingLevelUpView:SetEveryTimeEffect(level)
    if not level then return end
    self.currentUseItem = level
    local effectAnimator = self.effectMap["level" .. level]
    GameObjectHelper.FastSetActive(effectAnimator.gameObject, true)
    effectAnimator:Play(AnimatorEffectMap[level], 0, 0)  --Lua assist checked flag
end

function CardTrainingLevelUpView:SetLevelUpEffectOnce()
    if not self.levelUpRotationAudio.isPlaying then
        self.levelUpStartAudio.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/CardLevelUp/levelUpStart.wav", 0.5)
    end
end

function CardTrainingLevelUpView:SetLevelUpEffectLast()
    self:SetEveryTimeEffect(self.lastPressItemIndex)
    self.levelUpEndAudio.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/CardLevelUp/levelUpEnd.wav", 0.5)
end

function CardTrainingLevelUpView:PopToast(msg)
    if not self.currentToast then 
        self.currentToast = DialogManager.ShowToast(msg)
    end
end

function CardTrainingLevelUpView:CheckIsFinish()
    local pcid = self.cardTrainingMainModel:GetPcid()
    local lvl = self.cardTrainingMainModel:GetCurrLevelSelected()
    local subId = self.cardTrainingMainModel:GetSubIdByLevel(lvl)
    self:coroutine(function ()
        local response = req.cardTrainingCheckSubTrainComplete(pcid, lvl, subId)
        if api.success(response) then
            local data = response.val
            self.isFinish = data.complete
            self.confirmBtn:onPointEventHandle(data.complete)
            self.confirmBtn.gameObject:GetComponent(Button).interactable = data.complete
        end
    end)
end

function CardTrainingLevelUpView:ToastDestroy()
    self.currentToast = nil
end

function CardTrainingLevelUpView:onDestroy()
    EventSystem.RemoveEvent("ItemsMapModel_ResetItemNum", self, self.EventResetItemNum)
    EventSystem.RemoveEvent("CardTraining_RefreshCoolTime", self, self.RefreshCoolTime)
    EventSystem.RemoveEvent("ToastDestroy", self, self.ToastDestroy)
    if self.timer then
        self.timer:Destroy()
        self.timer = nil
    end
end

return CardTrainingLevelUpView

