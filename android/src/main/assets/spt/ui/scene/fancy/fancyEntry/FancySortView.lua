local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local FancySortView = class(unity.base)

function FancySortView:ctor()
--------Start_Auto_Generate--------
    self.recycleBtn = self.___ex.recycleBtn
    self.sortScrollSpt = self.___ex.sortScrollSpt
    self.sortTrans = self.___ex.sortTrans
    self.spaceGo = self.___ex.spaceGo
    self.groupBtn = self.___ex.groupBtn
    self.groupIconImg = self.___ex.groupIconImg
    self.groupNameTxt = self.___ex.groupNameTxt
    self.newTipGo = self.___ex.newTipGo
    self.backBtn = self.___ex.backBtn
--------End_Auto_Generate----------
end

function FancySortView:start()
    self:BindButtonHandler()
end

function FancySortView:BindButtonHandler()
    -- 分解入口
    self.recycleBtn:regOnButtonClick(function()
        res.PushScene("ui.controllers.fancy.fancyRecycle.FancyRecycleCtrl")
    end)
    -- 返回
    self.backBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function FancySortView:InitView(fancySortModel, scrollPos)
    self.model = fancySortModel
    self:InitSortList()
    self.sortScrollSpt:SetScrollNormalizedPosition(scrollPos or 1)
end

function FancySortView:InitSortList()
    local sortList = self.model:GetSortList()
    self.sortScrollSpt:InitView(sortList, function(order) self:OnGroupClick(order) end)
end

function FancySortView:OnGroupClick(sortId)
    sortId = tostring(sortId)
    res.PushScene("ui.controllers.fancy.fancyEntry.FancyTeamCtrl", sortId)
end

function FancySortView:GetScrollPos()
    local pos = self.sortScrollSpt:GetScrollNormalizedPosition()
    return pos
end

function FancySortView:Close()
    if self.onClose then
        self.onClose()
    end
end

return FancySortView
