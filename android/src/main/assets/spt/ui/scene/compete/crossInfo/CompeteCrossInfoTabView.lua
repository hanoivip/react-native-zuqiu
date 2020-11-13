local GameObjectHelper = require("ui.common.GameObjectHelper")
local ButtonGroup = require("ui.control.button.ButtonGroup")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteCrossInfoTabView = class(ButtonGroup, "CompeteCrossInfoTabView")

function CompeteCrossInfoTabView:ctor()
    CompeteCrossInfoTabView.super.ctor(self)
    self.scrollView = self.___ex.scrollView
    self.menu = {}
end

function CompeteCrossInfoTabView:start()
end

function CompeteCrossInfoTabView:InitView(rankTab, tabClickCallBack)
    if type(rankTab) == "table" then
        self.scrollView:regOnCreateItem(function(scrollSelf, index)
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/CrossInfo/RankTabItem.prefab"
            local obj, spt = res.Instantiate(prefab)
            scrollSelf:resetItem(spt, index)
            return obj
        end)

        self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
            local tabData = scrollSelf.itemDatas[index]
            local tag = tabData.tag
            spt:InitView(tabData, index)
            self.menu[tag] = spt
            self:BindMenuItem(tag, function()
                tabClickCallBack(tag, spt)
            end)
            scrollSelf:updateItemIndex(spt, index)
          
            if cache.getSelectedCrossInfoTabID() and tostring(cache.getSelectedCrossInfoTabID()) == tostring(tag) then
                spt:SetSelect(true)
            else
                spt:SetSelect(false)
            end 
        end)
        self.scrollView:refresh(rankTab)
    end
end

function CompeteCrossInfoTabView:ClearTabs()
    self.scrollView:clearData()

    self:UnbindAll()
    self.menu = {}
    self.currentMenuTag = nil
end

function CompeteCrossInfoTabView:ChangeSelectTag(tag)
    for tag, spt in pairs(self.menu) do
        spt:SetSelect(false)
    end
    self.menu[tag]:SetSelect(true)
end

function CompeteCrossInfoTabView:GetSelectedTag()
    for tag, spt in pairs(self.menu) do
        if spt.isSelect then return tag end
    end
end

return CompeteCrossInfoTabView