local FancyGroupView = class(unity.base)

function FancyGroupView:ctor()
    self.backBtn = self.___ex.backBtn
    self.watchBtn = self.___ex.watchBtn
    self.title = self.___ex.title
    self.content = self.___ex.content
    self.scrollContent = self.___ex.scrollContent
end

function FancyGroupView:start()
    self.backBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.watchBtn:regOnButtonClick(function ()
        self:WatchCard()
    end)
end

function FancyGroupView:InitView(fancyGroupModel)
    self.fancyGroupModel = fancyGroupModel
    self.title.text = fancyGroupModel:GetTitle()
    self:SetCourt(self.content)
    self:ShowScrollList()
end

function FancyGroupView:ShowGroupAttrItem(data)
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyHome/CardGroupAttrItem.prefab")
    obj.transform:SetParent(self.scrollContent, false)
    spt:InitView(data)
end

function FancyGroupView:ShowScrollList()
    res.ClearChildrenImmediate(self.scrollContent)
    local perAttr = self.fancyGroupModel:GetAllPerAttr()
    self:ShowGroupAttrItem(self.fancyGroupModel:GetLightAttrText(perAttr))
    self:ShowGroupAttrItem(self.fancyGroupModel:GetStarAttrText(perAttr))
    self:ShowGroupAttrItem(self.fancyGroupModel:GetAllStarAttrText())
end
local param = {showStar = true, shadow = true}
function FancyGroupView:SetCourt(content)
    local courtSize = content.sizeDelta
    local count = content.childCount
    local formtionID = self.fancyGroupModel:GetFormationID()
    self.sptList = {}
    if count == 0 then
        for i = 1, 11 do
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardSmall.prefab")
            obj.transform:SetParent(content, false)
            spt:InitView(self.fancyGroupModel:GetCard(i), param)
            spt:SetPos(self.fancyGroupModel:GetCardPos(i), formtionID, courtSize)
            spt.OnBtnClick = function() self:OnCardClick(i) end
            table.insert(self.sptList, spt)
        end
    else
        local getChild = content.GetChild
        for i = 0, count - 1 do
            local spt = res.GetLuaScript(getChild(i).gameObject)
            spt:InitView(self.fancyGroupModel:GetCard(i + 1), param)
            spt:SetPos(self.fancyGroupModel:GetCardPos(i + 1), formtionID, courtSize)
            table.insert(self.sptList, spt)
        end
    end
end

function FancyGroupView:OnCardClick(i)
    if self.onCardClick then
        self.onCardClick(i)
    end
end

function FancyGroupView:FancyUpStar()
    self:RefreshCourt()
    self:ShowScrollList()
end

function FancyGroupView:RefreshCourt()
    if not self.sptList then
        return
    end
    for k, v in pairs(self.sptList) do
        v:RefreshStar()
    end
end

function FancyGroupView:WatchCard()
    res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyWatchCtrl", self.fancyGroupModel)
end

function FancyGroupView:Close()
    res.PopScene()
end

function FancyGroupView:EnterScene()
    EventSystem.AddEvent("FancyUpStar", self, self.FancyUpStar)
end

function FancyGroupView:ExitScene()
    EventSystem.RemoveEvent("FancyUpStar", self, self.FancyUpStar)
end

return FancyGroupView