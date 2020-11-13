local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems
local NationalWelfareRewardType = require("ui.models.activity.NationalWelfareRewardType")

local NationalWelfareView = class(unity.base)

function NationalWelfareView:ctor()
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.txtTime = self.___ex.txtTime
    self.txtPayNumber = self.___ex.txtPayNumber
    self.btnVip = self.___ex.btnVip
    self.selectBtnGroup = self.___ex.selectBtnGroup
    self.residualTimer = nil
    self.curRewardType = NationalWelfareRewardType.NORMAL
end

function NationalWelfareView:start()
    self.btnVip:regOnButtonClick(function ()
        if self.onVip then
            self.onVip()
        end
    end)
    -- 全民福利
    self.selectBtnGroup:BindMenuItem("category1", function ()
        self.curRewardType = NationalWelfareRewardType.NORMAL
        self:BuildScroller()
    end)

    -- VIP3专属
    self.selectBtnGroup:BindMenuItem("category2", function ()
        self.curRewardType = NationalWelfareRewardType.VIP
        self:BuildScroller()
    end)
end

function NationalWelfareView:InitView(nationalWelfareModel)
    self.nationalWelfareModel = nationalWelfareModel
    self.activityDes.text = nationalWelfareModel:GetActivityDesc()
    self.txtPayNumber.text = tostring(nationalWelfareModel:GetPayNumber())
    self:BuildSelectBtnGroup("category" .. self.curRewardType)
    self:BuildScroller()
end

function NationalWelfareView:BuildSelectBtnGroup(tag)
    self.selectBtnGroup:selectMenuItem(tag)
end

function NationalWelfareView:BuildScroller()
    self.scrollView:InitView(self.nationalWelfareModel, self.curRewardType)
end

function NationalWelfareView:OnEnterScene()
    EventSystem.AddEvent("NationalWelfareView.UpdateRemainTime", self, self.UpdateRemainTime)
end

function NationalWelfareView:OnExitScene()
    EventSystem.RemoveEvent("NationalWelfareView.UpdateRemainTime", self, self.UpdateRemainTime)
end

function NationalWelfareView:UpdateRemainTime(remainTime)
    local timeTable = string.convertSecondToTimeTable(remainTime)
    self.txtTime.text = lang.trans("activity_nationalWelfare_remainTime", timeTable.day, timeTable.hour, timeTable.minute)
end

function NationalWelfareView:OnRefresh()
end

function NationalWelfareView:onDestroy()
end

return NationalWelfareView