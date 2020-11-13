local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local HonorListScrollView = class(LuaScrollRectExSameSize)

function HonorListScrollView:ctor()
    HonorListScrollView.super.ctor(self)
end

function HonorListScrollView:start()
end

function HonorListScrollView:GetHonorGroupRes()
    if not self.honorGroup then 
        self.honorGroup = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/HonorGroup.prefab")
    end
    return self.honorGroup
end

function HonorListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetHonorGroupRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function HonorListScrollView:OnClickReward(id)
    if self.clickReward then
        self.clickReward(id)
    end
end

function HonorListScrollView:resetItem(spt, index)
    spt:InitView(self.data[index], self.arenaModel, self.arenaHonorModel)
    spt.clickReward = function(id) self:OnClickReward(id) end
    self:updateItemIndex(spt, index)
end

function HonorListScrollView:InitView(arenaModel, arenaHonorModel)
    self.arenaModel = arenaModel
    self.arenaHonorModel = arenaHonorModel
    local allotData = arenaHonorModel:GetHonorData()
    self.data = allotData
    self:refresh(self.data)
end

return HonorListScrollView
