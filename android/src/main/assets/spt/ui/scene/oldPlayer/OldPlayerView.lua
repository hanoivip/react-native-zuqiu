local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local OldPlayerView = class(unity.base)

function OldPlayerView:ctor()
    self.btnClose = self.___ex.btnClose
    self.mTime = self.___ex.mTime
    self.content = self.___ex.content
    self.tabScrollView = self.___ex.tabScrollView
    self.tabItemMap = {}
    self:OnCreateTagList()
end

function OldPlayerView:start()
    DialogAnimation.Appear(self.transform, nil)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function OldPlayerView:InitView(oldPlayerModel)
    self:Reset()
    self.oldPlayerModel = oldPlayerModel
    local tabMap = self.oldPlayerModel:GetMenuTab()
    self.tabScrollView:refresh(tabMap)
    self:OnTabClick(oldPlayerModel:GetSelectMenu())
    self:InitContent(oldPlayerModel:GetPublicContentData())
end

function OldPlayerView:InitContent(contentData)
    self.mTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(contentData.beginTime), 
                                    string.convertSecondToMonth(contentData.endTime))
end

function OldPlayerView:OnCreateTagList()
    self.tabScrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerTabBar.prefab")
        scrollSelf:resetItem(spt, index)
        return obj, spt
    end)
    self.tabScrollView:regOnResetItem(function(scrollSelf, spt, index)
        local tagData = self.tabScrollView.itemDatas[index]
        spt.clickTab = function() self:OnTabClick(tagData.tabNum) end
        local state = self.oldPlayerModel:GetSelectMenu() == tagData.tabNum
        spt:InitView(tagData, state)
        scrollSelf:updateItemIndex(spt, index)
        self.tabItemMap[tagData.tabNum] = spt
    end)
end

function OldPlayerView:Reset()
    self.selectTabPos = nil
end

function OldPlayerView:OnRecv(recvData)
    if self.onRecv then 
        self.onRecv(recvData)
    end
end

function OldPlayerView:OnBuy(buyData)
    if self.onBuy then 
        self.onBuy(recvData)
    end
end

function OldPlayerView:OnTabClick(pos)
    if self.selectTabPos == pos then 
        return 
    end
    local preTabItem = self.tabItemMap[self.selectTabPos]
    if preTabItem then 
        preTabItem:ChangeState(false)
    end
    local currentTabItem = self.tabItemMap[pos]
    if currentTabItem then 
        currentTabItem:ChangeState(true)
    end
    self.selectTabPos = pos
    if self.clickTab then 
        self.clickTab(pos)
    end
end

function OldPlayerView:Close()
    if self.onClose then
        self.onClose()
    end
    for k,v in pairs(self.tabItemMap) do
        v:OnExitScene()
    end
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return OldPlayerView
