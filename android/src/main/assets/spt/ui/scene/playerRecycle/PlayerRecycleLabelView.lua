local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local PlayerRecycleLabelView = class(unity.base, "PlayerRecycleLabelView")
function PlayerRecycleLabelView:ctor()
    self.limit = self.___ex.limit
    self.over = self.___ex.over
    self.btnGroup = self.___ex.btnGroup
    self.scrollView = self.___ex.scrollView
    self.leftArrow = self.___ex.leftArrow
    self.rightArrow = self.___ex.rightArrow
    self.btnArrowLeft = self.___ex.btnArrowLeft
    self.btnArrowRight = self.___ex.btnArrowRight

    self.btnGroup.menu = {}
end

function PlayerRecycleLabelView:InitView(rankLabel, labelClickCallBack, defaultTag)
    if type(rankLabel) == "table" then
        self.scrollView:regOnCreateItem(function(scrollSelf, index)
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/PlayerRecycle/RankLabelItem.prefab"
            local obj, spt = res.Instantiate(prefab)
            scrollSelf:resetItem(spt, index)
            return obj
        end)
        self.scrollView:regOnItemIndexChanged(function(index)
            if index > 1 then
                GameObjectHelper.FastSetActive(self.leftArrow, false)
            else
                GameObjectHelper.FastSetActive(self.leftArrow, true)
            end
            if index <= #self.scrollView.itemDatas - 4 then
                GameObjectHelper.FastSetActive(self.rightArrow, true)
            else
                GameObjectHelper.FastSetActive(self.rightArrow, true)
            end
        end)

        if #rankLabel <= 3 then
            GameObjectHelper.FastSetActive(self.over, false)
            GameObjectHelper.FastSetActive(self.limit.gameObject, true)
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/PlayerRecycle/RankLabelItem.prefab"
            for i, v in ipairs(rankLabel) do
                local tag = v.tag
                v.index = i
                local obj, spt = res.Instantiate(prefab)
                obj.transform:SetParent(self.limit, false)
                spt:InitView(v)
                self.btnGroup.menu[tag] = spt
                self.btnGroup:BindMenuItem(tag, function()
                    labelClickCallBack(tag, spt, v)
                end)
                spt:SetSelect(i == 1)
            end
        else
            GameObjectHelper.FastSetActive(self.over, true)
            GameObjectHelper.FastSetActive(self.limit.gameObject, false)
            self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
                local itemData = scrollSelf.itemDatas[index]
                itemData.index = index
                local tag = itemData.tag
                spt:InitView(itemData)

                self.btnGroup.menu[tag] = spt
                self.btnGroup:BindMenuItem(tag, function()
                    labelClickCallBack(tag, spt, itemData)
                end)
                scrollSelf:updateItemIndex(spt, index)

                spt:SetSelect(index == 1)
                if itemData.tag == defaultTag then
                    labelClickCallBack(tag, spt, itemData)
                end
            end)
            self.scrollView:refresh(rankLabel)
        end
    end
    self.btnGroup.currentMenuTag = defaultTag

    self.btnArrowLeft:regOnButtonClick(function()
        self.scrollView:scrollToPreviousGroup();
    end)
    self.btnArrowRight:regOnButtonClick(function()
        self.scrollView:scrollToNextGroup();
    end)
end


function PlayerRecycleLabelView:ChangeSelectTag(tag)
    for tag, spt in pairs(self.btnGroup.menu) do
        spt:SetSelect(false)
    end
    self.btnGroup.menu[tag]:SetSelect(true)
end

function PlayerRecycleLabelView:GetSelectedTag()
    for tag, spt in pairs(self.btnGroup.menu) do
        if spt.isSelect then return tag end
    end
end

function PlayerRecycleLabelView:ClearTabs()
    self.scrollView:clearData()
    self.btnGroup:UnbindAll()
    self.btnGroup.menu = {}
end

return PlayerRecycleLabelView