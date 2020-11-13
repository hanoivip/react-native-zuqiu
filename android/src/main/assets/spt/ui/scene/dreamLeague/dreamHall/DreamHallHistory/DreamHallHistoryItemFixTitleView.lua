local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local DreamHallHistoryItemFixTitleView = class(unity.base, "DreamHallHistoryItemFixTitleView")

function DreamHallHistoryItemFixTitleView:ctor()
    self.parentTrans = self.___ex.parentTrans
    self.otherObj = self.___ex.otherObj
end

function DreamHallHistoryItemFixTitleView:InitView(data)
end

function DreamHallHistoryItemFixTitleView:AddTitle(text, isShowBackImage, width)
    self:InstantiateObj(text, isShowBackImage, width)
end

function DreamHallHistoryItemFixTitleView:InstantiateObj(text, isShowBackImage, width)
    local obj = Object.Instantiate(self.otherObj)
    obj.transform:SetParent(self.parentTrans, false)
    local spt = obj:GetComponent(clr.CapsUnityLuaBehav)
    spt:InitView(text, isShowBackImage, width)
end

return DreamHallHistoryItemFixTitleView