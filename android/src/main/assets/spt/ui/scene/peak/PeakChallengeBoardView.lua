local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PeakChallengeBoardView = class(unity.base)

function PeakChallengeBoardView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.itemView = self.___ex.itemView
    self.refreshBtn = self.___ex.refreshBtn
end

function PeakChallengeBoardView:start()
    self:RegBtn()
end

function PeakChallengeBoardView:InitView(data)
    self:InitItemView(data)
end

function PeakChallengeBoardView:InitItemView(data)
    -- 刷新动画
    for k, v in pairs(self.itemView) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    local opponents = data.opponents
    for k, v in pairs(opponents) do
        local subItemView = self.itemView[tostring(k)]
        subItemView.gameObject:SetActive(true)
        subItemView:InitView(v)
        subItemView.onViewDetail = function (resetPowerCallBack)
            self.onViewDetail(v.sid, v.pid, resetPowerCallBack)
        end
        subItemView.onChallengeOpponent = function (sweep)
            self.onChallengeOpponent(v.pid, sweep)
        end
    end
end

function PeakChallengeBoardView:RegBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.refreshBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("Refresh_Peak_Opponent")
    end)
end

function PeakChallengeBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function PeakChallengeBoardView:CloseImmediate()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function PeakChallengeBoardView:OnEnterScene()
end

function PeakChallengeBoardView:OnDestroy()
end

return PeakChallengeBoardView
