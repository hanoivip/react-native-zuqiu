local OldPlayerItemBaseView = require("ui.scene.oldPlayer.OldPlayerItemBaseView")
local OldPlayerLoginRewardItemView = class(OldPlayerItemBaseView)

function OldPlayerLoginRewardItemView:ctor()
    self.title = self.___ex.title
    OldPlayerLoginRewardItemView.super.ctor(self)
    self:RegBtn()
end

function OldPlayerLoginRewardItemView:RegBtn()
    self.recvBtn:regOnButtonClick(function()
        self:OnRecv()
    end)
end

function OldPlayerLoginRewardItemView:OnRecv()
    if self.onRecv then
        self.onRecv(function(args)
            if args then
                self:InitRewardButtonState(args.status)
            end
        end)
    end
end

function OldPlayerLoginRewardItemView:InitView(itemData)
    OldPlayerLoginRewardItemView.super.InitView(self, itemData)
    self.title.text = lang.trans("oldPlayer_item_day", itemData.condition)
    self.recvText.text = lang.trans("receive")
end

return OldPlayerLoginRewardItemView
