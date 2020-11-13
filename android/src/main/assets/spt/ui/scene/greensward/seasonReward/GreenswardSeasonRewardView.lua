local ReqEventModel = require("ui.models.event.ReqEventModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GreenswardSeasonRewardView = class(unity.base, "GreenswardSeasonRewardView")

function GreenswardSeasonRewardView:ctor()
--------Start_Auto_Generate--------
    self.buttonGroupSpt = self.___ex.buttonGroupSpt
    self.allRewardRedPointGo = self.___ex.allRewardRedPointGo
    self.contentTrans = self.___ex.contentTrans
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.introSptMap = {}
end

function GreenswardSeasonRewardView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function GreenswardSeasonRewardView:InitView(greenswardSeasonRewardModel)
    self.model = greenswardSeasonRewardModel
    for introduceType, v in pairs(self.buttonGroupSpt.menu) do
        self.buttonGroupSpt:BindMenuItem(introduceType, function()
            self:OnTabClick(introduceType)
        end)
    end
end

function GreenswardSeasonRewardView:RefreshView()
    if not self.model then
        return
    end

    local currTag = self.model:GetTab()
    self.buttonGroupSpt:selectMenuItem(currTag)
    self:OnTabClick(currTag)
    self:IsShowGreenswardPoint()
end

function GreenswardSeasonRewardView:OnEnterScene()
    EventSystem.AddEvent("ReqEventModel_advReward", self, self.IsShowGreenswardPoint)
end

function GreenswardSeasonRewardView:OnExitScene()
    EventSystem.RemoveEvent("ReqEventModel_advReward", self, self.IsShowGreenswardPoint)
end

function GreenswardSeasonRewardView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

local DefaultRegion = "1"
function GreenswardSeasonRewardView:OnTabClick(tag)
    local introSpt = self.introSptMap[tag]
    if not introSpt then
        local path = self.model:GetPrefabPathByTag(tag)
        local obj, spt = res.Instantiate(path)
        obj.transform:SetParent(self.contentTrans, false)
        self.introSptMap[tag] = spt
        introSpt = spt
    end
    self.model:SetTab(tag)
    introSpt:InitView(self.model, self.model:GetRegion(), self.receiveReward)

    for i, spt in pairs(self.introSptMap) do
        GameObjectHelper.FastSetActive(spt.gameObject, false)
    end
    GameObjectHelper.FastSetActive(introSpt.gameObject, true)
end

function GreenswardSeasonRewardView:IsShowGreenswardPoint()
    local advReward = ReqEventModel.GetInfo("advReward") or 0 -- 有可领取的奖励
    local isShow = tonumber(advReward) > 0
    GameObjectHelper.FastSetActive(self.allRewardRedPointGo, isShow)
end

return GreenswardSeasonRewardView
