local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local LeagueScheduleScrollerView = class(LuaScrollRectExSameSize)

function LeagueScheduleScrollerView:ctor()
    self.leagueInfoModel = nil
    self.super.ctor(self)
end

function LeagueScheduleScrollerView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.itemDatas = self.leagueInfoModel:GetScheduleList()
    
    self:BuildPage()
end

function LeagueScheduleScrollerView:start()
end

function LeagueScheduleScrollerView:BuildPage()
    self:refresh()
    self:scrollToCellImmediate(self.leagueInfoModel:GetScheduleRound())
end

function LeagueScheduleScrollerView:createItem(index)
    local node = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueScheduleRound.prefab", GameObject))
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    nodeScript:InitView(self.leagueInfoModel, index, self.itemDatas[index])
    return node
end

function LeagueScheduleScrollerView:resetItem(spt, index)
    spt:InitView(self.leagueInfoModel, index, self.itemDatas[index])
    spt:BuildPage()
end

return LeagueScheduleScrollerView
