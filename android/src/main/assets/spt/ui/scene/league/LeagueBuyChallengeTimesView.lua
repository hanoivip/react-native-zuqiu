local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local LeagueBuyChallengeTimesView = class(unity.base)

function LeagueBuyChallengeTimesView:ctor()
    -- 钻石花费数量1
    self.costNum1 = self.___ex.costNum1
    -- 钻石花费数量2
    self.costNum2 = self.___ex.costNum2
    -- 购买次数提示
    self.buyTimesTips = self.___ex.buyTimesTips
    -- 关闭按钮
    self.closeBtn = self.___ex.closeBtn
    -- 确定按钮
    self.confirmBtn = self.___ex.confirmBtn
    self.canvasGroup = self.___ex.canvasGroup
    -- 数据模型
    self.leagueInfoModel = nil
end

function LeagueBuyChallengeTimesView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self:BuildView()
end

function LeagueBuyChallengeTimesView:start()
    self:BindAll()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function LeagueBuyChallengeTimesView:BindAll()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self.confirmBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("League_BuyChallengeTimes")
    end)
end

function LeagueBuyChallengeTimesView:BuildView()
    local costNum = self.leagueInfoModel:GetCostNum()
    self.costNum1.text = "x" .. costNum
    self.costNum2.text = "x" .. costNum
    local lastBuyTimes = self.leagueInfoModel:GetLastBuyTimes()
    local totalBuyTimes = self.leagueInfoModel:GetTotalBuyTimes()
    self.buyTimesTips.text = lang.transstr("canBuyTimesToday") .. "<color=#A2FF11>" .. lastBuyTimes .. "/</color>" .. totalBuyTimes 
end

function LeagueBuyChallengeTimesView:FormatTimestamp(timestamp)
    local month = os.date("%m", timestamp)
    local day = os.date("%d", timestamp)
    return month .. lang.transstr("month") .. day .. lang.transstr("day_1")
end

function LeagueBuyChallengeTimesView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        self:Destroy()
    end)
end

function LeagueBuyChallengeTimesView:Destroy()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

return LeagueBuyChallengeTimesView