local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local EventSystem = require("EventSystem")
local MarblesExchangeView = class(unity.base)

function MarblesExchangeView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.topGo = self.___ex.topGo
    self.own1Img = self.___ex.own1Img
    self.own1Txt = self.___ex.own1Txt
    self.own2Img = self.___ex.own2Img
    self.own2Txt = self.___ex.own2Txt
    self.own3Img = self.___ex.own3Img
    self.own3Txt = self.___ex.own3Txt
    self.own4Img = self.___ex.own4Img
    self.own4Txt = self.___ex.own4Txt
    self.scrollViewSpt = self.___ex.scrollViewSpt
    self.exchangeTrans = self.___ex.exchangeTrans
    self.rewardTrans = self.___ex.rewardTrans
    self.exchangeBtn = self.___ex.exchangeBtn
    self.buyLimitTxt = self.___ex.buyLimitTxt
    self.soldOutGo = self.___ex.soldOutGo
--------End_Auto_Generate----------
    self.ownImg = {self.own1Img, self.own2Img, self.own3Img, self.own4Img}
    self.ownTxt = {self.own1Txt, self.own2Txt, self.own3Txt, self.own4Txt}
    self.itemImgPath = "Assets/CapstonesRes/Game/UI/Common/Images/MarblesExchangeItem/M%d.png"
end

function MarblesExchangeView:start()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function MarblesExchangeView:InitView(marblesExchangeModel)
    self.model = marblesExchangeModel
    DialogAnimation.Appear(self.transform, nil)
    res.ClearChildren(self.contentTrans)
    local exchangeList = self.model:GetExchangeList()
    self.scrollViewSpt:InitView(exchangeList, self.getExchangeReward)
    self:RefreshContent()
end

function MarblesExchangeView:RefreshContent()
    local scrollPos = self.scrollViewSpt:getScrollNormalizedPos()
    local exchangeList = self.model:GetExchangeList()
    self.scrollViewSpt:refresh(exchangeList, scrollPos)
    self:InitOwnItemCount()
end

-- 当前拥有的兑换物品
function MarblesExchangeView:InitOwnItemCount()
    local ownItem = self.model:GetOwnItem()
    for i, v in ipairs(self.ownImg) do
        local itemData = ownItem[i]
        local picPath = string.format(self.itemImgPath, itemData.picIndex)
        local imgRes = res.LoadRes(picPath)
        v.sprite = imgRes
        self.ownTxt[i].text = "X" .. itemData.ownCount
    end
    GameObjectHelper.FastSetActive(self.topGo, true)
end

function MarblesExchangeView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return MarblesExchangeView
