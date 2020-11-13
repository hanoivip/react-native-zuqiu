local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CompeteListScrollView = class(LuaScrollRectExSameSize)

function CompeteListScrollView:ctor()
    CompeteListScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.competeItemMap = {}
end

function CompeteListScrollView:GetCompeteRes()
    if not self.itemRes then 
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/MatchFrame.prefab")
    end
    return self.itemRes
end

function CompeteListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetCompeteRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function CompeteListScrollView:resetItem(spt, index)
    local competeModel = self.itemDatas[index]
    spt:InitView(competeModel, index, self.competeMainModel)
	spt.btnStart:regOnButtonClick(function() self:OnBtnStart(competeModel) end)
	spt.btnCheck:regOnButtonClick(function() self:OnBtnCheck(competeModel) end)
    self:updateItemIndex(spt, index)
end

function CompeteListScrollView:InitView(competeMainModel)
    self.competeMainModel = competeMainModel
    local frameModels = self.competeMainModel:GetMatchFrameModel()
	self:refresh(frameModels)
	local nextIndex = self.competeMainModel:GetNextMatchIndex()
	self:scrollToCellImmediate(nextIndex)
end

function CompeteListScrollView:OnBtnStart(competeModel)
	EventSystem.SendEvent("CompeteStart_Match", competeModel)
end

function CompeteListScrollView:OnBtnCheck(competeModel)
	EventSystem.SendEvent("CompeteCheck_Formation", competeModel)
end

function CompeteListScrollView:OnDestroy()
    self.itemRes = nil
end

return CompeteListScrollView
