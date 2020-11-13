local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CoachGachaOptionRewardView = class(unity.base)

-- 可选列表显示出来的物品个数
local MinItemCount = 4 

function CoachGachaOptionRewardView:ctor()
    self.scroll = self.___ex.scroll
    self.leftArrow = self.___ex.leftArrow
    self.rightArrow = self.___ex.rightArrow
    self.minContentTrans = self.___ex.minContentTrans

    DialogAnimation.Appear(self.transform)
end

function CoachGachaOptionRewardView:InitView(contents, gachaId)
    self.contents = contents
    self.gachaId = gachaId
    if #self.contents > MinItemCount then
        self:InitScrollView()
    else
        self:InitMinContentlView()
    end
    self:InitArrowState()
end

function CoachGachaOptionRewardView:InitScrollView()
    self.scroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/ItemList/OptionRewardItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scroll:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:InitView(data)

        spt.onClickSelectBtn = function ()
            if self.onExchangeGift and type(self.onExchangeGift) == "function" then
                self.onExchangeGift(self.gachaId, data)
            end
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    local data = self.contents
    self.scroll:refresh(data)
end

function CoachGachaOptionRewardView:InitMinContentlView()
    res.ClearChildren(self.minContentTrans)
    for i,v in ipairs(self.contents) do
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/ItemList/OptionRewardItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        obj.transform:SetParent(self.minContentTrans, false)
        spt:InitView(v)
        spt.onClickSelectBtn = function ()
            if self.onExchangeGift and type(self.onExchangeGift) == "function" then
                self.onExchangeGift(self.gachaId, v)
            end
        end
    end
end

function CoachGachaOptionRewardView:InitArrowState()
    local arrowState = #self.contents > MinItemCount
    GameObjectHelper.FastSetActive(self.leftArrow, arrowState)
    GameObjectHelper.FastSetActive(self.rightArrow, arrowState)
    GameObjectHelper.FastSetActive(self.scroll.gameObject, arrowState)
end

function CoachGachaOptionRewardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return CoachGachaOptionRewardView
