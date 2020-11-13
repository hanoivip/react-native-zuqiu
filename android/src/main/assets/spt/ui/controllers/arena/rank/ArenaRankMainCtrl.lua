local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaRankBoardCtrl = require("ui.controllers.arena.rank.ArenaRankBoardCtrl")
local ArenaRankConstants = require("ui.scene.arena.rank.ArenaRankConstants")
local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local ArenaRankMainCtrl = class(BaseCtrl,"ArenaRankMainCtrl")

ArenaRankMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/ArenaRankBoard.prefab"

function ArenaRankMainCtrl:GetStatusData()
    return self.arenaRankModel, self.arenaMainModel
end

function ArenaRankMainCtrl:Init(arenaRankModel, arenaMainModel)
    self.arenaRankModel = arenaRankModel
    self.arenaMainModel = arenaMainModel
    self.zone = self.arenaRankModel.zone
    self.type = self.arenaRankModel.type
    self.curSelectIndex = self.arenaRankModel.selectIndex
    self.arenaRankBoardCtrl = ArenaRankBoardCtrl.new(self.view.rankBoard)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:OnClickBackAnimation()
        end)
    end)
    self.view.onServer = function() self:OnServer(ArenaRankConstants.Type.Server) end
    self.view.onWorld = function() self:OnServer(ArenaRankConstants.Type.World) end
    self.view.clickBack = function() self:OnClickBack() end
end

function ArenaRankMainCtrl:OnClickBack()
    res.PopScene()
end

function ArenaRankMainCtrl:Refresh(arenaRankModel, arenaMainModel)
    ArenaRankMainCtrl.super.Refresh(self)
    self:InitView(arenaRankModel, arenaMainModel)
end

function ArenaRankMainCtrl:InitView(arenaRankModel, arenaMainModel)
    self:RefreshZoneGroup()
    -- 暂时隐藏规则按钮，后期可能再加
    -- self.view.onRule = function() self:OnRule() end
    self.view:InitView(arenaRankModel)
    self.arenaRankBoardCtrl:InitView(arenaRankModel, arenaMainModel)
end

function ArenaRankMainCtrl:RefreshView()
    self.view:InitView(self.arenaRankModel)
    self.arenaRankBoardCtrl:InitView(self.arenaRankModel, self.arenaMainModel)
end

function ArenaRankMainCtrl:RefreshZoneGroup()
    local zoneList = self.arenaRankModel:GetZoneList()
    for k, v in pairs(self.view.zoneGroup) do
        local zoneData = zoneList[v.zoneIndex]
        v.btnRankTab.clickRankTab = function() self:ClickRankTab(v.zoneIndex) end
        v:InitView(zoneData.name)
        v:ChangeButtonState(zoneData.isSelect)
        if luaevt.trig("__SGP__VERSION__") or luaevt.trig("__VN__VERSION__") or luaevt.trig("__KR__VERSION__") or luaevt.trig("__VN__VERSION__")then
            if v.zoneIndex > 4 then
                GameObjectHelper.FastSetActive(v.gameObject, false)
            end
        end
    end
end

function ArenaRankMainCtrl:ClickRankTab(index)
    self.curSelectIndex = index
    self.arenaRankModel:SetSelectIndex(index)
    local zoneList = self.arenaRankModel:GetZoneList()
    for i, zoneData in ipairs(zoneList) do
        if i == index then
            zoneData.isSelect = true
            self:RequestCurRankDataList(zoneData.zone, self.type)
        else
            zoneData.isSelect = false
        end
        for k, v in pairs(self.view.zoneGroup) do
            if v.zoneIndex == i then
                v:ChangeButtonState(zoneData.isSelect)
            end
        end
    end
    self:RefreshView()
end

function ArenaRankMainCtrl:RequestCurRankDataList(zone, type)
    clr.coroutine(function()
        local respone = req.arenaRankInfo(zone, type)
        if api.success(respone) then
            local data = respone.val
            if data then
                self.arenaRankModel:InitWithProtocol(data)
            end
            self:RefreshView()
        end
    end)
end

-- 暂时隐藏规则按钮，后期可能再加
-- function ArenaRankMainCtrl:OnRule()
--     -- 规则弹板
--     res.PushScene("ui.controllers.arena.ArenaRuleCtrl")
-- end

function ArenaRankMainCtrl:OnServer(targetType)
    if self.type ~= targetType then
        self.type = targetType
        self.arenaRankModel:SetSelectType(targetType)
        self:ClickRankTab(self.curSelectIndex)
    end
end

return ArenaRankMainCtrl