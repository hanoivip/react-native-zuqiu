local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CompeteCrossListScrollView = class(LuaScrollRectExSameSize)

function CompeteCrossListScrollView:ctor()
    CompeteCrossListScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.competeItemMap = {}
end

function CompeteCrossListScrollView:GetCompeteRes()
    if not self.itemRes then 
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CrossFrame.prefab")
    end
    return self.itemRes
end

function CompeteCrossListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetCompeteRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function CompeteCrossListScrollView:resetItem(spt, index)
    local matchModel = self.itemDatas[index]
    spt:InitView(matchModel, index)
    self:updateItemIndex(spt, index)
end

function CompeteCrossListScrollView:onItemIndexChanged(pageIndex)
	self.competeCrossMatchModel:SetPageIndex(pageIndex)
end

function CompeteCrossListScrollView:InitView(competeCrossMatchModel, pageIndex)
    self.competeCrossMatchModel = competeCrossMatchModel
    local matchModels = self.competeCrossMatchModel:GetMatchModel()
	self:refresh(matchModels)
	local pageNum = table.nums(matchModels)
	if pageIndex > pageNum then pageIndex = pageNum end
	self:scrollToCellImmediate(pageIndex)
end

function CompeteCrossListScrollView:OnDestroy()
    self.itemRes = nil
end

return CompeteCrossListScrollView
