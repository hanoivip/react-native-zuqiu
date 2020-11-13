local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CarnivalPopBoardView = class(unity.base)

function CarnivalPopBoardView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.content = self.___ex.content
    self.title = self.___ex.title
    self.rewardTitle = self.___ex.rewardTitle
    self.rewardText = self.___ex.rewardText
    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function CarnivalPopBoardView:InitView(model)
    self.title.text = lang.trans("carnival_rewardTitle", model.index)
    self.rewardTitle.text = lang.trans("carnival_rewardSubtitle")
    self.rewardText.text = lang.trans("carnival_rewardDescription", model.condition)
    local rewardParams = {
        parentObj = self.content,
        rewardData = model.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function CarnivalPopBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return CarnivalPopBoardView