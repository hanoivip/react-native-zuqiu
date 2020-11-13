local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local PlayerLetterScrollView = class(LuaScrollRectExSameSize)

function PlayerLetterScrollView:ctor()
    self.scrollRect = self.___ex.scrollRect
    -- 球员信函视图model
    self.playerLetterViewModel = nil
    -- 滚动归一化位置
    self.scrollNormalizedPosition = nil
    self.super.ctor(self)
end

function PlayerLetterScrollView:awake()
    self:RegisterEvent()
end

function PlayerLetterScrollView:InitView(playerLetterViewModel)
    self.playerLetterViewModel = playerLetterViewModel
    self.scrollNormalizedPosition = self.playerLetterViewModel:GetScrollNormalizedPosition()
    self.itemDatas = self.playerLetterViewModel:GetLetterList()
end

function PlayerLetterScrollView:OnEnterView()
    self:refresh()
    self.currCoroutine = clr.coroutine(function ()
        unity.waitForNextEndOfFrame()
        self:SetScrollNormalizedPosition()
    end)
end

function PlayerLetterScrollView:OnExitView()
    EventSystem.SendEvent("PlayerLetter.SetScrollNormalizedPosition", self:GetScrollNormalizedPosition())
end

function PlayerLetterScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerLetterScrollItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    spt:InitView(self.itemDatas[index])
    return obj
end

function PlayerLetterScrollView:resetItem(spt, index)
    spt:InitView(self.itemDatas[index])
    spt:BuildView()
end

function PlayerLetterScrollView:RegisterEvent()
    EventSystem.AddEvent("PlayerLetter.InitView", self, self.InitView)
    EventSystem.AddEvent("PlayerLetter.OnEnterView", self, self.OnEnterView)
    EventSystem.AddEvent("PlayerLetter.OnExitView", self, self.OnExitView)
end

function PlayerLetterScrollView:RemoveEvent()
    EventSystem.RemoveEvent("PlayerLetter.InitView", self, self.InitView)
    EventSystem.RemoveEvent("PlayerLetter.OnEnterView", self, self.OnEnterView)
    EventSystem.RemoveEvent("PlayerLetter.OnExitView", self, self.OnExitView)
end

function PlayerLetterScrollView:GetScrollNormalizedPosition()
    return self.scrollRect.verticalNormalizedPosition
end

function PlayerLetterScrollView:SetScrollNormalizedPosition()
    self.scrollRect.verticalNormalizedPosition = self.scrollNormalizedPosition
end

function PlayerLetterScrollView:onDestroy()
    if self.currCoroutine then
        self:StopCoroutine(self.currCoroutine)
        self.currCoroutine = nil
    end
    self:RemoveEvent()
end

return PlayerLetterScrollView