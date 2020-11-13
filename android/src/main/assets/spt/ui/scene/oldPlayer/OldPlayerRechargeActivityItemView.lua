local OldPlayerItemBaseView = require("ui.scene.oldPlayer.OldPlayerItemBaseView")
local OldPlayerRechargeActivityItemView = class(OldPlayerItemBaseView)

function OldPlayerRechargeActivityItemView:ctor()
    self.mName = self.___ex.mName
    self.mValue = self.___ex.mValue
    OldPlayerRechargeActivityItemView.super.ctor(self)
    self:RegBtn()
end

function OldPlayerRechargeActivityItemView:RegBtn()
    self.recvBtn:regOnButtonClick(function()
        self:OnRecv()
    end)
end

function OldPlayerRechargeActivityItemView:OnRecv()
    if self.onRecv then
        self.onRecv(function(args)
            if args then
                self:InitRewardButtonState(args.status)
            end
        end)
    end
end

function OldPlayerRechargeActivityItemView:InitView(itemData)
    OldPlayerRechargeActivityItemView.super.InitView(self, itemData)
    self.mName.text = lang.trans("cumulative_pay")
    self.mValue.text = itemData.value .. "/" .. itemData.condition
    self.recvText.text = lang.trans("receive")
end

return OldPlayerRechargeActivityItemView
