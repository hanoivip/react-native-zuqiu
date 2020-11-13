local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PersonScheduleListScrollView = class(LuaScrollRectExSameSize)

function PersonScheduleListScrollView:ctor()
    PersonScheduleListScrollView.super.ctor(self)
end

function PersonScheduleListScrollView:GetScheduleBarRes()
    if not self.scheduleBar then 
        self.scheduleBar = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/PersonScheduleBar.prefab")
    end
    return self.scheduleBar
end

function PersonScheduleListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetScheduleBarRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function PersonScheduleListScrollView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

function PersonScheduleListScrollView:resetItem(spt, index)
    spt:InitView(self.data[index], self.arenaScheduleTeamModel, self.playerId)
    spt.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
    self:updateItemIndex(spt, index)
end

function PersonScheduleListScrollView:InitView(arenaPersonScheduleModel, arenaScheduleTeamModel)
    local playerInfoModel = PlayerInfoModel.new()
    self.playerId = playerInfoModel:GetID()
    self.arenaScheduleTeamModel = arenaScheduleTeamModel
    local data = arenaPersonScheduleModel:GetListData()
    self.data = data
    self:refresh(self.data, 0)
end

function PersonScheduleListScrollView:onDestroy()
    self.scheduleBar = nil
end

return PersonScheduleListScrollView
