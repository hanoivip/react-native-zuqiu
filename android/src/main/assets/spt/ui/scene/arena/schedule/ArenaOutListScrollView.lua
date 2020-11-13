local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaOutListScrollView = class(LuaScrollRectExSameSize)

function ArenaOutListScrollView:ctor()
    ArenaOutListScrollView.super.ctor(self)
    self.waitProcess = self.___ex.waitProcess
end

function ArenaOutListScrollView:start()
end

function ArenaOutListScrollView:GetArenaOutBarRes()
    if not self.arenaOutBar then 
        self.arenaOutBar = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaOutBar.prefab")
    end
    return self.arenaOutBar
end

function ArenaOutListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetArenaOutBarRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function ArenaOutListScrollView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

function ArenaOutListScrollView:resetItem(spt, index)
    spt:InitView(self.data[index], self.arenaScheduleTeamModel, self.playerId)
    spt.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
    self:updateItemIndex(spt, index)
end

-- 主客场分列左右两边（决赛只有一场） 构建数据
function ArenaOutListScrollView:BuildScheduleData(matchScheduleType, arenaKnockoutModel, newScheduleData)
    local scheduleData = arenaKnockoutModel:GetMatchScheduleData(matchScheduleType) or {}
    if scheduleData and next(scheduleData) then
        local totalMatchNum = #scheduleData[1] -- 只有一场比赛的场次只需要一个标题
        local titleData = {}
        titleData.isTitle = true
        titleData.index = 1
        titleData.totalMatchNum = totalMatchNum
        titleData.round = matchScheduleType
        table.insert(newScheduleData, titleData)
        titleData = {}
        titleData.isTitle = true
        titleData.index = 2
        titleData.totalMatchNum = totalMatchNum
        titleData.round = matchScheduleType
        table.insert(newScheduleData, titleData)

        for i, v in ipairs(scheduleData) do
            for index, data in ipairs(v) do
                local barData = {}
                barData.isTitle = false
                barData.index = index
                barData.data = data
                table.insert(newScheduleData, barData)
            end
        end
    end
end

function ArenaOutListScrollView:InitView(arenaKnockoutModel, arenaScheduleTeamModel)
    self.arenaScheduleTeamModel = arenaScheduleTeamModel
    local playerInfoModel = PlayerInfoModel.new()
    self.playerId = playerInfoModel:GetID()
    local newScheduleData = {}
    self:BuildScheduleData(MatchScheduleType.SixteenIntoEight, arenaKnockoutModel, newScheduleData)
    self:BuildScheduleData(MatchScheduleType.EightIntoFour, arenaKnockoutModel, newScheduleData)
    self:BuildScheduleData(MatchScheduleType.Semi, arenaKnockoutModel, newScheduleData)
    self:BuildScheduleData(MatchScheduleType.Final, arenaKnockoutModel, newScheduleData)
    self.data = newScheduleData
    self:refresh(self.data)
    GameObjectHelper.FastSetActive(self.waitProcess, not next(self.data))
end

return ArenaOutListScrollView
