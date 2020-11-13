local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper =  require("ui.common.GameObjectHelper")

local TimeLimitGuildCarnivalLogView = class(unity.base, "TimeLimitGuildCarnivalLogView")

TimeLimitGuildCarnivalLogView.menuTags = {
    rank = "rank",
    myLog = "myLog"
}

function TimeLimitGuildCarnivalLogView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    -- 页签group
    self.tabGroup = self.___ex.tabGroup
    -- 我的排名GameObject
    self.myRankObj = self.___ex.myRankObj
    -- 我的积分GameObject
    self.myPointObj = self.___ex.myPointObj
    -- 我的排名文本
    self.txtMyRank = self.___ex.txtMyRank
    -- 我的积分文本
    self.txtMyPoint = self.___ex.txtMyPoint
    -- 排行榜scroll view
    self.rankScroll = self.___ex.rankScroll
    -- 日志scroll view
    self.logScroll = self.___ex.logScroll
end

function TimeLimitGuildCarnivalLogView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function TimeLimitGuildCarnivalLogView:InitView(timeLimitGuildCarnivalLogModel)
end

function TimeLimitGuildCarnivalLogView:InitRankView(timeLimitGuildCarnivalLogModel)
    self.model = timeLimitGuildCarnivalLogModel
    self.txtTitle.text = self.model:GetRankTitle()
    local myRank = self.model:GetMyRank()
    self.txtMyRank.text = myRank > 0 and tostring(myRank) or lang.trans("none")
    local myPoint = self.model:GetMyPoint()
    self.txtMyPoint.text = myPoint > 0 and tostring(myPoint) or lang.trans("none")
    self.rankScroll:RegOnItemButtonClick("btnDetail", function(data) self:OnRankItemClickViewPlayer(data.pid, data.sid) end)
    self.rankScroll:InitView(self.model:GetRankData())
    GameObjectHelper.FastSetActive(self.myRankObj.gameObject, true)
    GameObjectHelper.FastSetActive(self.rankScroll.gameObject, true)
    GameObjectHelper.FastSetActive(self.logScroll.gameObject, false)
end

function TimeLimitGuildCarnivalLogView:InitMyLogView(timeLimitGuildCarnivalLogModel)
    self.model = timeLimitGuildCarnivalLogModel
    self.txtTitle.text = self.model:GetLogTitle()
    self.logScroll:InitView(self.model:GetMyLogData())
    GameObjectHelper.FastSetActive(self.myRankObj.gameObject, false)
    GameObjectHelper.FastSetActive(self.rankScroll.gameObject, false)
    GameObjectHelper.FastSetActive(self.logScroll.gameObject, true)
end

function TimeLimitGuildCarnivalLogView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)

    self.tabGroup:BindMenuItem(self.menuTags.rank, function()
        if self.onClickTabRank then
            self.onClickTabRank()
        end
    end)
    self.tabGroup:BindMenuItem(self.menuTags.myLog, function()
        if self.onClickTabMyLog then
            self.onClickTabMyLog()
        end
    end)
end

function TimeLimitGuildCarnivalLogView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function TimeLimitGuildCarnivalLogView:OnRankItemClickViewPlayer(pid, sid)
    if self.onRankItemClickViewPlayer then
        self.onRankItemClickViewPlayer(pid, sid)
    end
end

return TimeLimitGuildCarnivalLogView