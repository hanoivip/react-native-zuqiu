local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local LoopType = Tweening.LoopType
local TweenExtensions = Tweening.TweenExtensions
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")

local TimeLimitGuildCarnivalView = class(ActivityParentView)

function TimeLimitGuildCarnivalView:ctor()
    -- 活动时间
    self.activityTime = self.___ex.activityTime
    -- 所属公会
    self.txtGuildName = self.___ex.txtGuildName
    -- 公会积分
    self.txtGuildPoint = self.___ex.txtGuildPoint
    -- 日志
    self.btnLog = self.___ex.btnLog
    -- 奖励列表
    self.scrollReward = self.___ex.scrollReward
    -- 商品列表
    self.scrollCommodity = self.___ex.scrollCommodity
    -- 无公会面板
    self.notHasGuild = self.___ex.notHasGuild
    -- 加入公会按钮
    self.btnAddGuild = self.___ex.btnAddGuild
    -- 公会解散面板
    self.guildDismissed = self.___ex.guildDismissed
    -- 玩法说明
    self.btnIntro = self.___ex.btnIntro
end

function TimeLimitGuildCarnivalView:InitView(timeLimitGuildCarnivalModel)
    self.model = timeLimitGuildCarnivalModel
    self:BuildView()
end

function TimeLimitGuildCarnivalView:start()
    self:BindAll()
end

function TimeLimitGuildCarnivalView:BindAll()
    self.btnLog:regOnButtonClick(function()
        if self.onClickBtnLog then
            self.onClickBtnLog()
        end
    end)

    self.btnAddGuild:regOnButtonClick(function()
        if self.onClickBtnAddGuild then
            self.onClickBtnAddGuild()
        end
    end)

    self.btnIntro:regOnButtonClick(function()
        if self.onClickBtnIntro then
            self.onClickBtnIntro()
        end
    end)
end

function TimeLimitGuildCarnivalView:BuildView()
    -- 活动时间
    local startTime = self.model:GetBeginTime()
    local endTime = self.model:GetEndTime()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.formatTimestampNoYear(startTime), string.formatTimestampNoYear(endTime))
    -- 所属公会
    local guildName = self.model:GetGuildName()
    local guildID = self.model:GetGuildID()
    local hasGuildID = string.len(guildID) > 0
    local hasGuildName = string.len(guildName) > 0
    if hasGuildID and hasGuildName then
        -- 加入公会，公会正常运转，活动开放给玩家
        self.txtGuildName.text = lang.trans("time_limit_guild_carnival_guild", guildName)
        -- 公会积分
        self.txtGuildPoint.text = tostring(self.model:GetGuildPoint())
        self:BoardSetActive(true, false, false)
    elseif not hasGuildID and hasGuildName then
        -- 不可能情况
        self:BoardSetActive(false, false, false)
    elseif hasGuildID and not hasGuildName then
        -- 公会在活动过程中解散
        self.txtGuildName.text = lang.trans("time_limit_guild_carnival_guild", lang.transstr("dismissed"))
        -- 公会积分
        self.txtGuildPoint.text = lang.trans("dismissed")
        self:BoardSetActive(false, false, true)
    else
        -- 未加入过公会
        self.txtGuildName.text = lang.trans("time_limit_guild_carnival_guild", lang.transstr("none"))
        self.txtGuildPoint.text = lang.trans("none")
        self:BoardSetActive(false, true, false)
    end
    -- 奖励列表
    self.scrollReward:InitView(self.model:GetRewardList())
    -- 商品列表
    self.scrollCommodity:InitView(self.model:GetCommodityList())
end

function TimeLimitGuildCarnivalView:BoardSetActive(isShowCommodity, isShowNotHasGuild, isShowGuildDismissed)
    GameObjectHelper.FastSetActive(self.scrollCommodity.gameObject, isShowCommodity)
    GameObjectHelper.FastSetActive(self.notHasGuild.gameObject, isShowNotHasGuild)
    GameObjectHelper.FastSetActive(self.guildDismissed.gameObject, isShowGuildDismissed)
    GameObjectHelper.FastSetActive(self.btnLog.gameObject, isShowCommodity)
end

function TimeLimitGuildCarnivalView:OnEnterScene()
    TimeLimitGuildCarnivalView.super.OnEnterScene(self)
    EventSystem.AddEvent("GuildCarnival_PurchaseItem", self, self.OnClickPurchase)
    EventSystem.AddEvent("CongratulationsPageClosed", self, self.CongratulationsPageClosed)
end

function TimeLimitGuildCarnivalView:OnExitScene()
    TimeLimitGuildCarnivalView.super.OnExitScene(self)
    EventSystem.RemoveEvent("GuildCarnival_PurchaseItem", self, self.OnClickPurchase)
    EventSystem.RemoveEvent("CongratulationsPageClosed", self, self.CongratulationsPageClosed)
end

function TimeLimitGuildCarnivalView:OnClickPurchase(subID, num)
    if self.onClickPurchase then
        self.onClickPurchase(subID, num)
    end
end

function TimeLimitGuildCarnivalView:UpdateAfterPurchased()
    -- 公会积分
    self.txtGuildPoint.text = tostring(self.model:GetGuildPoint())
    -- 奖励列表
    local normalizedPos = self.scrollReward:getScrollNormalizedPos()
    self.scrollReward:InitView(self.model:GetRewardList())
    self.scrollReward:scrollToPosImmediate(normalizedPos)
    -- 商品列表
    normalizedPos = self.scrollCommodity:getScrollNormalizedPos()
    self.scrollCommodity:InitView(self.model:GetCommodityList())
    self.scrollCommodity:scrollToPosImmediate(normalizedPos)
end

function TimeLimitGuildCarnivalView:CongratulationsPageClosed()
    local duration = 0.1
    local changeGreen = ShortcutExtensions.DOColor(self.txtGuildPoint, Color(138 / 255, 227 / 255, 90 / 255), duration)
    TweenSettingsExtensions.SetLoops(changeGreen, 6, LoopType.Yoyo)
    TweenSettingsExtensions.OnComplete(changeGreen, function()
        self.txtGuildPoint.color = Color(1, 1, 149 / 255) -- yellow
    end)
end

return TimeLimitGuildCarnivalView
