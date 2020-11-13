local DialogManager = require("ui.control.manager.DialogManager")

local CareerDoubleView = class(unity.base)

function CareerDoubleView:ctor()
    -- 活动说明
    self.activityDesc = self.___ex.activityDesc
    -- 活动时间
    self.activityTime = self.___ex.activityTime
    -- 购买次数提示
    self.buyTimesTips = self.___ex.buyTimesTips
    -- 前往联赛按钮
    self.goToBtn = self.___ex.goToBtn
    -- 数据模型
    self.careerDoubleModel = nil
end

function CareerDoubleView:InitView(careerDoubleModel)
    self.careerDoubleModel = careerDoubleModel
    self:BuildView()
end

function CareerDoubleView:start()
    self:BindAll()
end

function CareerDoubleView:BindAll()
    self.goToBtn:regOnButtonClick(function ()
        if self.careerDoubleModel:IsLeagueUnlock() then
            require("ui.controllers.league.LeagueCtrl").new()
        else
            local unlockLevel = self.careerDoubleModel:GetLeagueUnlockLevel()
            DialogManager.ShowToast(lang.trans("careerDouble_leagueLockTips", unlockLevel))
        end
    end)
end

function CareerDoubleView:BuildView()
    self.activityDesc.text = self.careerDoubleModel:GetDesc()

    local startTime = self.careerDoubleModel:GetStartTime()
    local endTime = self.careerDoubleModel:GetEndTime()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.formatTimestampNoYear(startTime), string.formatTimestampNoYear(endTime))

    local lastBuyTimes = self.careerDoubleModel:GetLastBuyTimes()
    local totalBuyTimes = self.careerDoubleModel:GetTotalBuyTimes()
    self.buyTimesTips.text = lang.transstr("canBuyTimesToday") .. "<color=#FFE958>" .. lastBuyTimes .. "/</color>" .. totalBuyTimes 
end

return CareerDoubleView