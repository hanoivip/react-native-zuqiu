local TeamView = class(unity.base)

function TeamView:ctor()
	self.scollEx = self.___ex.scollEx
	self:RegScrollComp()
end

function TeamView:RegScrollComp()
    self.scollEx:regOnCreateItem(function (scrollSelf, index)
        local obj = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/TeamGroup.prefab")
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj, spt
    end)
    
    self.scollEx:regOnResetItem(function (scrollSelf, spt, index)
        spt:InitView(self.matchModel, index)
    end)
end

function TeamView:InitView(matchModel, index)
	self.matchModel = matchModel
	local teamData = matchModel:GetSortData() or {}
	self.scollEx:refresh(teamData)
	self.scollEx:scrollToPosImmediate(1)
end

return TeamView