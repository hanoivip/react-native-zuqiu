local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local WorldBossMatchDetailView = class(unity.base)

function WorldBossMatchDetailView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.comfirmBtn = self.___ex.comfirmBtn
    self.downItemSpt = self.___ex.downItemSpt
    self.rewardArea = self.___ex.rewardArea
end

function WorldBossMatchDetailView:start()
    self:BindButtonHandler()
    DialogAnimation.Appear(self.transform, nil)
end

function WorldBossMatchDetailView:InitView(matchData)
    self.downItemSpt.onInitTeamLogo = self.onInitTeamLogo
    self.downItemSpt:InitView(matchData.match)
    res.ClearChildren(self.rewardArea.transform)
    local rewardParams = {
        parentObj = self.rewardArea,
        rewardData = matchData.contents,
        isShowName = false,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
end

function WorldBossMatchDetailView:BindButtonHandler()
    self.comfirmBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function WorldBossMatchDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return WorldBossMatchDetailView