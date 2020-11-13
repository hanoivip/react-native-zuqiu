local OldPlayerItemBaseView = require("ui.scene.oldPlayer.OldPlayerItemBaseView")
local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local OldPlayerVipActivityItemView = class(OldPlayerItemBaseView)

function OldPlayerVipActivityItemView:ctor()
    self.title = self.___ex.title
    self.vipAreaRect = self.___ex.vipAreaRect
    OldPlayerVipActivityItemView.super.ctor(self)
    self:RegBtn()
end

function OldPlayerVipActivityItemView:RegBtn()
    self.recvBtn:regOnButtonClick(function()
        self:OnRecv()
    end)
end

function OldPlayerVipActivityItemView:OnRecv()
    if self.onRecv then
        self.onRecv(function(args)
            if args then
                self:InitRewardButtonState(args.status)
            end
        end)
    end
end

function OldPlayerVipActivityItemView:InitView(itemData)
    OldPlayerVipActivityItemView.super.InitView(self, itemData)
    local vipLevel = itemData.condition
    local vipRectX = -13
    if tonumber(vipLevel) > 9 then
        vipRectX = -18
    end
    self.vipAreaRect.anchoredPosition = Vector2(vipRectX, 0)
    self.title.text = tostring(vipLevel)
    self.recvText.text = lang.trans("receive")
end

return OldPlayerVipActivityItemView
