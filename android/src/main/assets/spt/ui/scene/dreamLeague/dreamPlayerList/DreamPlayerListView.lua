local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamPlayerListView = class(unity.base)

function DreamPlayerListView:ctor()
    self.nationIcon = self.___ex.nationIcon
    self.playerName = self.___ex.playerName
    self.playerNums = self.___ex.playerNums
    self.selectFilterBtn = self.___ex.selectFilterBtn
    self.decomposeBtn = self.___ex.decomposeBtn
    self.cardScrollRect = self.___ex.cardScrollRect
    self.confirmBtn = self.___ex.confirmBtn
end

function DreamPlayerListView:InitView(dreamPlayerListModel)
    self.dreamLeagueListModel = dreamPlayerListModel:GetDreamLeagueListModel()
    local isFilter =  dreamPlayerListModel:GetFilterState()
    self.qualitys = {}
    if isFilter then
        self.qualitys = dreamPlayerListModel:GetScrollDataFilter()
        dreamPlayerListModel:SetFilterState(false)
    else
        self.qualitys = dreamPlayerListModel:GetScrollDataQuality()
    end
    local isSelectMode = dreamPlayerListModel:GetSelectModeState()
    if isSelectMode then
        GameObjectHelper.FastSetActive(self.decomposeBtn.gameObject, false)
    end
    local qualityNums = dreamPlayerListModel:GetPlayerNum()
    local qualityB, qualityA, qualityS = unpack(qualityNums)
    local playerNameText = dreamPlayerListModel:GetPlayerName()
    local teamCode = dreamPlayerListModel:GetTeamCode()
    local nationRes = AssetFinder.GetNationIcon(teamCode)
    self.playerNums.text = lang.transstr("quality_nums", qualityS, qualityA, qualityB)
    self.playerName.text = playerNameText
    self.nationIcon.overrideSprite = nationRes

    self.cardScrollRect:InitView(self.qualitys)
    self.selectFilterBtn:regOnButtonClick(function()
        if self.onSelectFilterBtn then
            self.onSelectFilterBtn()
        end
    end)
    self.decomposeBtn:regOnButtonClick(function ()
        if self.onDecomposeClick then
            self.onDecomposeClick()
        end
    end)
    self.confirmBtn:regOnButtonClick(function ()
        if self.onConfirmClick then
            self.onConfirmClick()
        end
    end)
end

function DreamPlayerListView:ShowPlayerInfo(playerName, playerNation, qualityNumT)
    self.nationIcon.Path = "Assets/CapstonesRes/Game/UI/Common/Images/Nationality/".. tostring(playerNation).. ".png"
    self.nationIcon:ApplySource()

    self.playerName.text = playerName
end

function DreamPlayerListView:OnExitScene()
    for k,v in ipairs(self.qualitys) do
        local dcid = v:GetDcid()
        self.dreamLeagueListModel:ClearNewPlayerTag(dcid)
    end
end

return DreamPlayerListView

