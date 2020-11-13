local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local RenderTexture = UnityEngine.RenderTexture
local DialogManager = require("ui.control.manager.DialogManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local LotteryDialog = class(unity.base)

function LotteryDialog:ctor()
--------Start_Auto_Generate--------
    self.unlockTxt = self.___ex.unlockTxt
    self.titleTxt = self.___ex.titleTxt
    self.openTipGo = self.___ex.openTipGo
    self.emptyGo = self.___ex.emptyGo
    self.rewardTitleTxt = self.___ex.rewardTitleTxt
    self.rewardContentTxt = self.___ex.rewardContentTxt
    self.dragMaskSpt = self.___ex.dragMaskSpt
    self.closeBtnSpt = self.___ex.closeBtnSpt
    self.closeBtn = self.___ex.closeBtn
    self.openGo = self.___ex.openGo
    self.consumeCountTxt = self.___ex.consumeCountTxt
    self.openBtn = self.___ex.openBtn
    self.detailBtn = self.___ex.detailBtn
--------End_Auto_Generate----------
    self.maskRawImg = self.___ex.maskRawImg
    self.posArea = self.___ex.posArea
    self.maskObj = nil
    self.maskSpt = nil
    self.maskObjPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Lottery/LotteryMask.prefab"
end

function LotteryDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.openBtn:regOnButtonClick(function()
        self:OnOpenClick()
    end)
    self.detailBtn:regOnButtonClick(function()
        self:OnDetailClick()
    end)
end

function LotteryDialog:Close()
    if not self.isAlreadyShowReward then
        self:OnShowReward()
    end
    DialogAnimation.Disappear(self.transform, nil, function() self:Clear() end)
end

function LotteryDialog:InitView(eventModel)
    self.eventModel = eventModel
    self:ClearColor()
    self.titleTxt.text = eventModel:GetEventName()
    local blockPoint = eventModel:GetBlockPoint()
    self.unlockTxt.text = lang.trans("unlock_terrain_condition", blockPoint)

    local consumeMorale, starSymbol = eventModel:GetConsumeMorale()
    self.consumeCountTxt.text = "x" .. tostring(consumeMorale or 0)
    local r, g, b = eventModel:GetConvertColor(starSymbol)
    self.consumeCountTxt.color = ColorConversionHelper.ConversionColor(r, g, b)
    GameObjectHelper.FastSetActive(self.openTipGo, false);
end

-- 弹出奖励 刮完弹出  或者  没刮关闭页面后弹出
function LotteryDialog:OnShowReward()
    if self.isAlreadyOpen then
        local reward = self.eventModel:GetRewardData()
        if reward and next(reward.contents) then -- 有可能没有奖励
            CongratulationsPageCtrl.new(reward.contents)
        else
            DialogManager.ShowToastByLang("adventure_lottery_miss")
        end
        GameObjectHelper.FastSetActive(self.dragMaskSpt.gameObject, false)
    end
    self.isAlreadyShowReward = true
end

function LotteryDialog:ClearColor()
    GameObjectHelper.FastSetActive(self.dragMaskSpt.gameObject, true)
    if not self.maskObj then
        local obj, spt = res.Instantiate(self.maskObjPath);
        self.maskObj = obj
        self.maskSpt = spt
        self.dragMaskSpt:SetMaskTransAndRawImage(self.maskSpt.moveRectTrans, self.maskRawImg);
    end
    local camRT = RenderTexture(503, 138, 0);
    self.maskSpt.cam.targetTexture = camRT;
    self.maskRawImg.texture = camRT;
    self.maskRawImg.enabled = true;
    self.dragMaskSpt:OnCheckPosArea(self.posArea)
    self.dragMaskSpt:SetOpenCallBack(function() self:OnShowReward() end)
end

function LotteryDialog:OnOpenClick()
    if self.openClick then
        self.openClick()
    end
end

function LotteryDialog:OnDetailClick()
    local detailPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Lottery/LotteryReward.prefab"
    local dialog, dialogcomp = res.ShowDialog(detailPath, "camera", false, true)
    dialogcomp.contentcomp:InitView(self.eventModel)
end

function LotteryDialog:RefreshRewardArea()
    self.isAlreadyOpen = true
    local rewardTitleStr = self.eventModel:GetRewardTitle()
    local isEmpty = rewardTitleStr == nil
    if not isEmpty then
        local rewardContentStr = self.eventModel:GetRewardContent()
        self.rewardTitleTxt.text = lang.trans(rewardTitleStr)
        self.rewardContentTxt.text = rewardContentStr
    end
    GameObjectHelper.FastSetActive(self.openGo, false);
    GameObjectHelper.FastSetActive(self.openTipGo, true);
    GameObjectHelper.FastSetActive(self.emptyGo, isEmpty)
end

function LotteryDialog:Clear()
    self.closeDialog()
    Object.Destroy(self.maskObj)
    self.maskObj = nil
    self.maskSpt = nil
end

return LotteryDialog
