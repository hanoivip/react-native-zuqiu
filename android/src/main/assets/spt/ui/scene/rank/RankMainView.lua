local GameObjectHelper = require("ui.common.GameObjectHelper")
local Vector2 = clr.UnityEngine.Vector2
local RankMainView = class(unity.base)

function RankMainView:ctor()
    self.scrollView = self.___ex.scrollView
    self.tabScrollView = self.___ex.tabScrollView
    self.btnBack = self.___ex.btnBack
    self.myInfoView = self.___ex.myInfoView
    self.myDesc = self.___ex.myDesc
    self.serverMenu = self.___ex.serverMenu
    self.tabItemMap = {}
    self.selectTabIndex = nil
    self.selectServerKey = nil
    self:CreateItemList()
    self:CreateTagList()
end

function RankMainView:start()
    self.btnBack:regOnButtonClick(function()
        if self.onBack then
            self.onBack()
        end
    end)
    local menu = self.serverMenu.menu
    for key, server in pairs(menu) do
        server:regOnButtonClick(function()
            self:OnBtnMenu(key)
        end)
    end
    -- 越南版排行榜界面排名文字和排名数字重叠
    if luaevt.trig("__VN__VERSION__")then
        self.myDesc.transform.anchoredPosition = Vector2(-55, 10)
    else
        self.myDesc.transform.anchoredPosition = Vector2(-14.4, 10)
    end
end

function RankMainView:InitView(rankModel, playerInfoModel, guildData)
    self.rankModel = rankModel
    self.playerInfoModel = playerInfoModel
    self.guildData = guildData
    local tabMap = self.rankModel:GetMenuTab()
    self.tabScrollView:refresh(tabMap)
    self.serverMenu:selectMenuItem(self.rankModel:GetServerState())
end

function RankMainView:RefreshScrollView(normalizedPos)
    local list = self.rankModel:GetCurrentMenuData()
    self.scrollView:refresh(list, normalizedPos)
    self:InitSelfInfo(list)
end

function RankMainView:InitSelfInfo(list)
    local hasRank = false
    local id = self.playerInfoModel:GetID()
    local gid = self.guildData.base.isExsit and self.guildData.base.gid or "nil"
    for k, v in ipairs(list) do
        if v.pid == id or v.gid == gid then 
            hasRank = true
            self.myInfoView:InitView(v, self.rankModel)
            break
        end
    end
    GameObjectHelper.FastSetActive(self.myInfoView.gameObject, hasRank)
    self.myDesc.text = hasRank and lang.trans("mine_desc") or lang.trans("mine_not_rank_desc")
end

function RankMainView:CreateItemList()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Rank/Prefab/RankBar.prefab")
        scrollSelf:resetItem(spt, index)
        return obj, spt
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local itemData = self.scrollView.itemDatas[index]
        spt.onView = function(pid, sid, pcid, gid, cid) self:ClickView(pid, sid, pcid, gid, cid) end
        spt:InitView(itemData, self.rankModel)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function RankMainView:CreateTagList()
    self.tabScrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Rank/Prefab/RankTabBar.prefab")
        scrollSelf:resetItem(spt, index)
        return obj, spt
    end)
    self.tabScrollView:regOnResetItem(function(scrollSelf, spt, index)
        local tagData = self.tabScrollView.itemDatas[index]
        spt.clickRankTab = function() self:ClickRankTab(index) end
        spt:InitView(tagData, index, self.selectTabIndex)
        scrollSelf:updateItemIndex(spt, index)
        self.tabItemMap[tostring(index)] = spt
    end)
end

function RankMainView:Reset()
    self.selectTabIndex = nil
    self.selectServerKey = nil
end

function RankMainView:ClickRankTab(index)
    if self.selectTabIndex == index then 
        return 
    end
    local preTabItem = self.tabItemMap[tostring(self.selectTabIndex)]
    if preTabItem then 
        preTabItem:ChangeState(false)
    end
    local currentTabItem = self.tabItemMap[tostring(index)]
    if currentTabItem then 
        currentTabItem:ChangeState(true)
    end
    self.selectTabIndex = index
    if self.clickTab then 
        self.clickTab(index)
    end
end

function RankMainView:ClickView(pid, sid, pcid, gid, cid)
    if self.clickView then 
        self.clickView(pid, sid, pcid, gid, cid, self.scrollView:getScrollNormalizedPos())
    end
end

function RankMainView:OnBtnMenu(key)
    if key == self.selectServerKey then return end
    self.selectServerKey = key
    self:OnBtnServer(key)
    self.serverMenu:selectMenuItem(key)
end

function RankMainView:OnBtnServer(key)
    if self.clickServer then 
        self.clickServer(key)
    end
end

return RankMainView