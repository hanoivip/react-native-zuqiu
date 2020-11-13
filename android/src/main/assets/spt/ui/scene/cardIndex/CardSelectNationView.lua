local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Nation = require("data.Nation")
local DefaultNation = ""
local NationBoxHeight = 40
local NationItemHeight = 60
local CardSelectNationView = class(unity.base)

function CardSelectNationView:ctor()
    self.btnNation = self.___ex.btnNation
    self.btnCloseList = self.___ex.btnCloseList
    self.arrowUp = self.___ex.arrowUp
    self.arrowDown =self.___ex.arrowDown
    self.nationListObj = self.___ex.nationListObj
    self.content = self.___ex.content
    self.scrollRect = self.___ex.scrollRect
    self.nationObj = self.___ex.nationObj
    self.selectIcon = self.___ex.selectIcon
    self.selectName = self.___ex.selectName
    self.selectNone = self.___ex.selectNone
    self.selectInfo = self.___ex.selectInfo
    self.listRectPosY = nil
end

function CardSelectNationView:start()
    self.btnNation:regOnButtonClick(function()
        self:OnNationClick(true)
    end)
    self.btnCloseList:regOnButtonClick(function()
        self:OnNationClick(false)
    end)
    EventSystem.AddEvent("CardSelectNation.OnCancelSelect", self, self.CardSelectNation)
end

function CardSelectNationView:InitView(cardIndexViewModel)
    self.cardIndexViewModel = cardIndexViewModel
    self.nationList = self.cardIndexViewModel:GetNationMap()
    self:InitDetailView()
    self:CreateNationList()
    GameObjectHelper.FastSetActive(self.nationListObj, false)
    if self.cardIndexViewModel:GetViewNationality() ~= "" then
        self:PlayerSearchOnNationSelect(self.cardIndexViewModel:GetViewNationality(), self.cardIndexViewModel:GetSeletNationData())
    end
end

function CardSelectNationView:InitDetailView()
    GameObjectHelper.FastSetActive(self.arrowUp, false)
    GameObjectHelper.FastSetActive(self.arrowDown, true)
    GameObjectHelper.FastSetActive(self.nationObj, false)
    GameObjectHelper.FastSetActive(self.selectInfo, true)
end

function CardSelectNationView:PlayerSearchOnNationSelect(selectNationName, selectNationData)
    GameObjectHelper.FastSetActive(self.nationObj, true)
    GameObjectHelper.FastSetActive(self.selectInfo, false)
    if selectNationName ~= DefaultNation and selectNationData then
        GameObjectHelper.FastSetActive(self.selectIcon.gameObject, true)
        GameObjectHelper.FastSetActive(self.selectNone, false)
        local nationRes = AssetFinder.GetNationIcon(selectNationName)
        self.selectIcon.overrideSprite = nationRes
        self.selectName.text = selectNationData.name
        EventSystem.SendEvent("PlayerSearch.OnNationClick", selectNationName, selectNationData)
    else
        GameObjectHelper.FastSetActive(self.selectIcon.gameObject, false)
        GameObjectHelper.FastSetActive(self.selectNone, true)
    end
end

function CardSelectNationView:CreateNationList()
    local nationBox = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardIndex/NationBox.prefab")
    local nationItem = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardIndex/NationItem.prefab")
    local nationKeys = table.keys(self.nationList)
    table.sort(nationKeys, function(a, b) return a < b end)
    for i, v in pairs(nationKeys) do
        local obj = Object.Instantiate(nationBox)
        local spt = res.GetLuaScript(obj)
        obj.transform:SetParent(self.content)
        obj.transform.localScale = Vector3.one
        spt.onNationSelect = function(selectNationName, selectNationData) self:OnNationClick(false, selectNationName, selectNationData) end
        spt:InitView(self.nationList[v], v, nationItem)
    end
end

function CardSelectNationView:OnNationClick(isOpen, selectNationName, selectNationData)
    GameObjectHelper.FastSetActive(self.nationListObj, isOpen)
    GameObjectHelper.FastSetActive(self.arrowUp, isOpen)
    GameObjectHelper.FastSetActive(self.arrowDown, not isOpen)
    if selectNationName then
        EventSystem.SendEvent("PlayerSearch.OnNationClick", selectNationName, selectNationData)
        self:PlayerSearchOnNationSelect(selectNationName, selectNationData)
    end
end
function CardSelectNationView:CardSelectNation()
    self:PlayerSearchOnNationSelect("", nil)
end

function CardSelectNationView:onDestroy()
    EventSystem.RemoveEvent("CardSelectNation.OnCancelSelect", self, self.CardSelectNation)
end

return CardSelectNationView
