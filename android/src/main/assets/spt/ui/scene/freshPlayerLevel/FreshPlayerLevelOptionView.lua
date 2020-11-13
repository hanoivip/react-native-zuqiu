local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FreshPlayerLevelOptionView = class(unity.base)

-- 可选列表显示出来的物品个数
local MinItemCount = 4

function FreshPlayerLevelOptionView:ctor()
    self.scroll = self.___ex.scroll
    self.leftArrow = self.___ex.leftArrow
    self.rightArrow = self.___ex.rightArrow
    self.minContentTrans = self.___ex.minContentTrans

    DialogAnimation.Appear(self.transform)
end

function FreshPlayerLevelOptionView:InitView(id, contents, buyCallBack)
    self.contents = contents
    self.id = id
    self.buyCallBack = buyCallBack
    if #self.contents > MinItemCount then
        self:InitScrollView()
    else
        self:InitMinContentlView()
    end
    self:InitArrowState()
end

function FreshPlayerLevelOptionView:InitScrollView()
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
            if self.buyCallBack then
                self.buyCallBack(self.id, data)
                self:Close()
            end
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    local data = self.contents
    self.scroll:refresh(data)
end

function FreshPlayerLevelOptionView:InitMinContentlView()
    res.ClearChildren(self.minContentTrans)
    for i,v in ipairs(self.contents) do
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/ItemList/OptionRewardItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        obj.transform:SetParent(self.minContentTrans, false)
        spt:InitView(v)
        if self.buyCallBack then
            self.buyCallBack(self.id, v)
            self:Close()
        end
    end
end

function FreshPlayerLevelOptionView:InitArrowState()
    local arrowState = #self.contents > MinItemCount
    GameObjectHelper.FastSetActive(self.leftArrow, arrowState)
    GameObjectHelper.FastSetActive(self.rightArrow, arrowState)
    GameObjectHelper.FastSetActive(self.scroll.gameObject, arrowState)
end

function FreshPlayerLevelOptionView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return FreshPlayerLevelOptionView
