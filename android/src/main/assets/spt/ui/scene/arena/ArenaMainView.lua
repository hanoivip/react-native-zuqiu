local ArenaType = require("ui.scene.arena.ArenaType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ArenaMainView = class(unity.base)

local showPage = 1

local ViewKey = { ArenaType.SilverStage, ArenaType.GoldStage, ArenaType.BlackGoldStage, ArenaType.PlatinumStage, ArenaType.RedGoldStage, ArenaType.YellowGoldStage, ArenaType.BlueGoldStage}
function ArenaMainView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent

    self.btnRule = self.___ex.btnRule
    self.btnRank = self.___ex.btnRank
    self.btnStories = self.___ex.btnStories
    self.btnStore = self.___ex.btnStore
    self.btnHonor = self.___ex.btnHonor
    self.honorRedPoint = self.___ex.honorRedPoint
    self.btnLeft = self.___ex.btnLeft
    self.btnRight = self.___ex.btnRight
    self.arenaViewMap = self.___ex.arenaViewMap

    for key, view in pairs(self.arenaViewMap) do
        view.clickState = function(arenaType, state) self:OnClickState(arenaType, state) end
        view.refresh = function(arenaType) self:OnRefresh(arenaType) end
        view.clickStage = function(arenaType) self:OnClickStage(arenaType) end
        view.clickFormation = function(arenaType) self:OnClickFormation(arenaType) end
    end
end

function ArenaMainView:start()
    self.btnRank:regOnButtonClick(function()
        self:OnBtnRank()
    end)
    self.btnStories:regOnButtonClick(function()
        self:OnBtnStories()
    end)
    self.btnStore:regOnButtonClick(function()
        self:OnBtnStore()
    end)
    self.btnHonor:regOnButtonClick(function()
        self:OnBtnHonor()
    end)
    self.btnRule:regOnButtonClick(function()
        self:OnBtnRule()
    end)
    self.btnLeft:regOnButtonClick(function()
        self:OnBtnLeft()
    end)
    self.btnRight:regOnButtonClick(function()
        self:OnBtnRight()
    end)

    self:UpdateArenaHonor()
end

function ArenaMainView:OnBtnRule()
    if self.clickRule then 
        self.clickRule()
    end
end

function ArenaMainView:OnBtnRank()
    if self.clickRank then
        self.clickRank()
    end
end

function ArenaMainView:OnBtnStories()
    if self.clickStories then
        self.clickStories()
    end
end

function ArenaMainView:OnBtnStore()
    if self.clickStore then
        self.clickStore()
    end
end

function ArenaMainView:OnBtnHonor()
    if self.clickHonor then
        self.clickHonor()
    end
end

function ArenaMainView:OnClickFormation(arenaType)
    if self.clickFormation then
        self.clickFormation(arenaType)
    end
end

function ArenaMainView:OnClickState(arenaType, state)
    if self.clickState then
        self.clickState(arenaType, state)
    end
end

function ArenaMainView:OnClickStage(arenaType)
    if self.clickStage then
        self.clickStage(arenaType)
    end
end

function ArenaMainView:OnRefresh(arenaType)
    if self.refresh then
        self.refresh(arenaType)
    end
end

function ArenaMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function ArenaMainView:OnEnterScene()
    for key, view in pairs(self.arenaViewMap) do
        view:OnEnterScene()
    end
    EventSystem.AddEvent("ReqEventModel_arenaHonor", self, self.UpdateArenaHonor)
end

function ArenaMainView:OnExitScene()
    for key, view in pairs(self.arenaViewMap) do
        view:OnExitScene()
    end
    EventSystem.RemoveEvent("ReqEventModel_arenaHonor", self, self.UpdateArenaHonor)
end

function ArenaMainView:UpdateArenaHonor()
    local arenaHonor = ReqEventModel.GetInfo("arenaHonor")
    local hasArenaHonor = tonumber(arenaHonor) > 0
    GameObjectHelper.FastSetActive(self.honorRedPoint, hasArenaHonor)
end

function ArenaMainView:OnBtnLeft()
    showPage = 1
    self:ShowCutPageInfo()
end

function ArenaMainView:OnBtnRight()
    showPage = 2
    self:ShowCutPageInfo()
end

function ArenaMainView:ShowCutPageInfo()
    local showLeft = showPage == 2
    self:CutPage()
    GameObjectHelper.FastSetActive(self.btnLeft.gameObject, showLeft)
    GameObjectHelper.FastSetActive(self.btnRight.gameObject, not showLeft)
    if luaevt.trig("__SGP__VERSION__") or luaevt.trig("__KR__VERSION__") or luaevt.trig("__VN__VERSION__")then
        GameObjectHelper.FastSetActive(self.btnLeft.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnRight.gameObject, false)
    end
end

function ArenaMainView:InitView(arenaModel)
    self.arenaModel = arenaModel
    for key, view in pairs(self.arenaViewMap) do
        local index = tonumber(string.sub(key, 2))
        view:InitView(arenaModel, ViewKey[index])
    end
    self:ShowCutPageInfo()
end

function ArenaMainView:CutPage()
    for key, view in pairs(self.arenaViewMap) do
        local index = tonumber(string.sub(key, 2))
        view:CutPage(self.arenaModel, (showPage == 1 and index < 5) or (showPage == 2 and index > 4))
    end
end

return ArenaMainView