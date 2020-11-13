local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")

local EventSystem = require("EventSystem")

local LuckyWheelCtrl = class(ActivityContentBaseCtrl)

function LuckyWheelCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.onDiscountStore = function()
        self:OpenStore()
    end
    self.view.onStartDial = function(reqStartCallback, waitAnimationCallback)
        self:StartDialWheel(reqStartCallback, waitAnimationCallback)
    end
    self.view.resetRestTimes = function(func)
        self:ResetRestTimes(func)
    end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.playerInfoModel = PlayerInfoModel.new()
    self.view:InitView(self.activityModel)
end

function LuckyWheelCtrl:StartDialWheel(reqStartCallback, waitAnimationCallback)
    local restTimes = self.activityModel:GetRestTimes()
    if restTimes <= 0 then
        local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab", "overlay", true, true, nil, nil, 10000)
        local content = { }
        content.title = lang.trans("tips")

        if self.playerInfoModel:GetVipLevel() >= 10 then
            content.content = lang.trans("luckyWheel_timesZeroTips")
            content.button1Text = lang.trans("confirm")
        else
            content.content = lang.trans("luckyWheel_VIPUpTips")
            content.button1Text = lang.trans("charge")
            content.button2Text = lang.trans("cancel")
            content.onButton1Clicked = function()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
            end
        end

        dialogcomp.contentcomp:initData(content)
        return
    end

    if reqStartCallback then
        reqStartCallback()
    end
    clr.coroutine(function()
        local response = req.luckWheelDial()
        if api.success(response) then
            local data = response.val
            self.activityModel:SetRestTimes(data.restTimes)
            self.activityModel:SetCurrentRewardIndex(data.wheelIndex)
            self.activityModel:SetTreasure(data.treasure)
            self.activityModel:SetNormalReward(data.contents)

            while waitAnimationCallback() do
                coroutine.yield()
            end
            
            CongratulationsPageCtrl.new(data.contents)
        end
    end)
end

function LuckyWheelCtrl:OpenStore()
    res.PushScene("ui.controllers.activity.content.DiscountStoreCtrl", self.activityModel)
end

function LuckyWheelCtrl:OnRefresh()
end

function LuckyWheelCtrl:ResetRestTimes(func)
    -- 更新数据
    clr.coroutine(function()
        local response = req.activityList(nil, nil, true)
        if api.success(response) then
            local data = response.val
            local list = data and data.list
            ActivityListModel.new(ActivityRes.new()):RefreshData(list)

            local restTimes = self.activityModel:GetRestTimes()
            if type(func) == "function" then
                func(restTimes)
            end
        end
    end)
end

function LuckyWheelCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function LuckyWheelCtrl:OnExitScene()
    self.view:OnExitScene()
end

return LuckyWheelCtrl

