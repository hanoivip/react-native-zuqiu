local OldPlayerItemBaseView = require("ui.scene.oldPlayer.OldPlayerItemBaseView")
local OldPlayerLevelActivityItemView = class(OldPlayerItemBaseView)

function OldPlayerLevelActivityItemView:ctor()
    self.mName = self.___ex.mName
    self.mValue = self.___ex.mValue
    self.iconImg = self.___ex.iconImg
    OldPlayerLevelActivityItemView.super.ctor(self)
    self:RegBtn()
end

function OldPlayerLevelActivityItemView:RegBtn()
    self.recvBtn:regOnButtonClick(function()
        self:OnRecv()
    end)
end

function OldPlayerLevelActivityItemView:OnRecv()
    if self.onRecv then
        self.onRecv(function(args)
            if args then
                self:InitRewardButtonState(args.status)
            end
        end)
    end
end

function OldPlayerLevelActivityItemView:InitView(itemData)
    OldPlayerLevelActivityItemView.super.InitView(self, itemData)
    self.mName.text = lang.trans("oldPlayer_spConsume_item")
    self.mValue.text = itemData.value .. "/" .. itemData.condition
    self.recvText.text = lang.trans("receive")
    -- 写死
    self.iconImg.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Common/Icon_Strength.png")
    self.iconImg.preserveAspect = true
end

return OldPlayerLevelActivityItemView
