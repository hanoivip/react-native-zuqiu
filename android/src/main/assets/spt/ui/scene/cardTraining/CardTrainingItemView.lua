local AssetFinder = require("ui.common.AssetFinder")
local CardTrainingItemDataCtrl = require("ui.controllers.cardTraining.CardTrainingItemDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Timer = require("ui.common.Timer")

local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button

local CardTrainingItemView = class(unity.base)

function CardTrainingItemView:ctor()
    self.areaRect = self.___ex.areaRect
    self.confirmBtn = self.___ex.confirmBtn
    self.tipTxt = self.___ex.tipTxt
    self.priceTxt = self.___ex.priceTxt
    self.coolTimeTxt = self.___ex.coolTimeTxt
    self.coolTimeBtn = self.___ex.coolTimeBtn
end

function CardTrainingItemView:start()
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
    EventSystem.AddEvent("CardTraining_RefreshCoolTime", self, self.RefreshCoolTime)
end

function CardTrainingItemView:InitView(cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel or self.cardTrainingMainModel
    self.tipTxt.text = lang.trans("card_training_skill", self.cardTrainingMainModel:GetName(), self.cardTrainingMainModel:GetColdDownHour())

    local info = self.cardTrainingMainModel:GetNeedItemInfo()
    res.ClearChildren(self.areaRect)
    local rewardParams = {
        parentObj = self.areaRect,
        rewardData = info,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = true,
    }
    CardTrainingItemDataCtrl.new(rewardParams, self.cardTrainingMainModel)

    local coolTime = self.cardTrainingMainModel:GetCurrLvlCoolTime()
    self.coolDownPrice = self.cardTrainingMainModel:GetCoolDownPrice()
    GameObjectHelper.FastSetActive(self.coolTimeBtn.gameObject, coolTime)
    GameObjectHelper.FastSetActive(self.confirmBtn.gameObject, not coolTime)
    local lvl = self.cardTrainingMainModel:GetCurrLevelSelected()
    self.lvl = lvl
    local subId = self.cardTrainingMainModel:GetSubIdByLevel(lvl)
    self.subId = subId

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

function CardTrainingItemView:RefreshCoolTime(lvl, subId, time)
    if self.lvl ~= lvl or self.subId ~= subId then
        return
    end
    local hour = math.floor(time / 3600)
    local min = time - hour * 60 * 60
    local min = math.floor(min / 60)
    local sec = time - hour * 3600 - min * 60
    self.coolTimeTxt.text = string.format("%02d", hour) .. ":" .. string.format("%02d", min) .. ":" .. string.format("%02d", sec)
    self.priceTxt.text = "x " .. self.coolDownPrice * math.ceil(time / 1800)

    if time <= 0 then
        GameObjectHelper.FastSetActive(self.coolTimeBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.confirmBtn.gameObject, true)
    end
end

function CardTrainingItemView:onDestroy()
    EventSystem.RemoveEvent("CardTraining_RefreshCoolTime", self, self.RefreshCoolTime)
    if self.timer then
        self.timer:Destroy()
        self.timer = nil
    end
end

function CardTrainingItemView:CheckIsFinish()
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

function CardTrainingItemView:OnEnterScene()

end

function CardTrainingItemView:OnExitScene()
    if self.timer then
        self.timer:Destroy()
        self.timer = nil
    end
end

return CardTrainingItemView