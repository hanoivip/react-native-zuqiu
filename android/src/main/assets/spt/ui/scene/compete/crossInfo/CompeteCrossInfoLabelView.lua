local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteCrossInfoLabelView = class(unity.base, "CompeteCrossInfoLabelView")
local DefaultTag = "1"
function CompeteCrossInfoLabelView:ctor()
    self.limit4Go = self.___ex.limit4Go
    self.over4Go = self.___ex.over4Go
    self.btnGroup = self.___ex.btnGroup
    self.scrollView = self.___ex.scrollView
    self.leftArrowNormal = self.___ex.leftArrowNormal
    self.leftArrowHighlight = self.___ex.leftArrowHighlight
    self.rightArrowNormal = self.___ex.rightArrowNormal
    self.rightArrowHighlight = self.___ex.rightArrowHighlight
    self.btnArrowLeft = self.___ex.btnArrowLeft
    self.btnArrowRight = self.___ex.btnArrowRight

    self.btnGroup.menu = {}
end

function CompeteCrossInfoLabelView:start()
end

function CompeteCrossInfoLabelView:InitView(rankLabel, labelClickCallBack)
    if type(rankLabel) == "table" then
        self.scrollView:regOnCreateItem(function(scrollSelf, index)
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/CrossInfo/RankLabelItem.prefab"
            local obj, spt = res.Instantiate(prefab)
            scrollSelf:resetItem(spt, index)
            return obj
        end)
        self.scrollView:regOnItemIndexChanged(function(index)
            if index > 1 then
                GameObjectHelper.FastSetActive(self.leftArrowNormal, false)
                GameObjectHelper.FastSetActive(self.leftArrowHighlight, true)
            else
                GameObjectHelper.FastSetActive(self.leftArrowNormal, true)
                GameObjectHelper.FastSetActive(self.leftArrowHighlight, false)
            end
            if index <= #self.scrollView.itemDatas - 4 then
                GameObjectHelper.FastSetActive(self.rightArrowNormal, false)
                GameObjectHelper.FastSetActive(self.rightArrowHighlight, true)
            else
                GameObjectHelper.FastSetActive(self.rightArrowNormal, true)
                GameObjectHelper.FastSetActive(self.rightArrowHighlight, false)
            end
        end)

        if #rankLabel <= 4 then
            GameObjectHelper.FastSetActive(self.limit4Go, true)
            GameObjectHelper.FastSetActive(self.over4Go, false)
            GameObjectHelper.FastSetActive(self.btnArrowLeft.gameObject, false)
            GameObjectHelper.FastSetActive(self.btnArrowRight.gameObject, false)
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/CrossInfo/RankLabelItem.prefab"
            for i, v in ipairs(rankLabel) do
                local tag = v.tag
                v.index = i
                local obj, spt = res.Instantiate(prefab)
                obj.transform:SetParent(self.limit4Go.transform, false)
                spt:InitView(v)
                self.btnGroup.menu[tag] = spt
                self.btnGroup:BindMenuItem(tag, function()
                    labelClickCallBack(tag, spt)
                end)

                spt:SetSelect(i == 1)
            end
        else
            GameObjectHelper.FastSetActive(self.limit4Go, false)
            GameObjectHelper.FastSetActive(self.over4Go, true)
            GameObjectHelper.FastSetActive(self.btnArrowLeft.gameObject, true)
            GameObjectHelper.FastSetActive(self.btnArrowRight.gameObject, true)
            self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
                local itemData = scrollSelf.itemDatas[index]
                itemData.index = index
                local tag = itemData.tag
                spt:InitView(itemData)

                self.btnGroup.menu[tag] = spt
                self.btnGroup:BindMenuItem(tag, function()
                    labelClickCallBack(tag, spt)
                end)
                scrollSelf:updateItemIndex(spt, index)

                spt:SetSelect(index == 1)
            end)
            self.scrollView:refresh(rankLabel)
        end
    end
    self.btnGroup.currentMenuTag = DefaultTag
    self.btnArrowLeft:regOnButtonClick(function()
        self.scrollView:scrollToPreviousGroup();
    end)
    self.btnArrowRight:regOnButtonClick(function()
        self.scrollView:scrollToNextGroup();
    end)
end


function CompeteCrossInfoLabelView:ChangeSelectTag(tag)
    for tag, spt in pairs(self.btnGroup.menu) do
        spt:SetSelect(false)
    end
    self.btnGroup.menu[tag]:SetSelect(true)
end

function CompeteCrossInfoLabelView:GetSelectedTag()
    for tag, spt in pairs(self.btnGroup.menu) do
        if spt.isSelect then return tag end
    end
end

function CompeteCrossInfoLabelView:ClearTabs()
    self.scrollView:clearData()

    self.btnGroup:UnbindAll()
    self.btnGroup.menu = {}
end

return CompeteCrossInfoLabelView