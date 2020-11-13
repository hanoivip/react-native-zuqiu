local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local ItemsMapModel = require("ui.models.ItemsMapModel")

local OptionRewardView = class(unity.base)

function OptionRewardView:ctor()
    self.scroll = self.___ex.scroll
    self.leftArrow = self.___ex.leftArrow
    self.rightArrow = self.___ex.rightArrow

    DialogAnimation.Appear(self.transform)
end

function OptionRewardView:InitView(itemModel, num)
    self.itemModel = itemModel
    self.num = num or 1
    self:InitScrollView()
end

function OptionRewardView:InitScrollView()
    self.scroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/ItemList/OptionRewardItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scroll:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:InitView(data)

        spt.onClickSelectBtn = function()
            local parentItemNum = self.num
            local parentItemName = self.itemModel:GetName()
            local itemName = RewardNameHelper.GetSingleContentName(data.contents)
            local itemNum = self:GetItemNum(data.contents, parentItemNum)
            local title = lang.trans("tips")
            local content = lang.transstr("option_reward_tips", parentItemNum, parentItemName, itemName, itemNum)
            DialogManager.ShowConfirmPop(title, content,function()
                clr.coroutine(function ()
                    local response = req.useItem(self.itemModel:GetId(), self.num, data.contentId)
                    if api.success(response) then
                        local data = response.val
                        self:Close()
                        CongratulationsPageCtrl.new(data.contents)
                        if data.item ~= nil then
                            ItemsMapModel.new():ResetItemNum(data.item.id, data.item.num)
                        end
                    end
                end)
            end)
        end

        scrollSelf:updateItemIndex(spt, index)
    end)

    local data = self.itemModel:GetItemContent()
    self.scroll:refresh(data)
    local arrowState = #data > 3
    GameObjectHelper.FastSetActive(self.leftArrow, arrowState)
    GameObjectHelper.FastSetActive(self.rightArrow, arrowState)
end

function OptionRewardView:GetItemNum(contents, parentNum)
    parentNum = parentNum or 1
    if type(contents) == "table" then
        local index, value = next(contents)
        if type(value) == "number" then
            return " x" .. value * parentNum
        elseif type(value) == "table" then
            local i, item = next(value)
            return " x" .. item.num * parentNum
        end
        return ""
    end
    return ""
end

function OptionRewardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return OptionRewardView