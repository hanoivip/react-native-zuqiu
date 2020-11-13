local Card = require("data.Card")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LevelLimit = require("data.LevelLimit")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtScoutPlayerInfoView = class(unity.base)

function CourtScoutPlayerInfoView:ctor()
    self.btnClose = self.___ex.btnClose
    self.btnExtra = self.___ex.btnExtra
    self.canvasGroup = self.___ex.canvasGroup
    self.playerListScroll = self.___ex.playerListScroll
    self.hintInfo = self.___ex.hintInfo
    self.beActivatedPlayers = {}
end

function CourtScoutPlayerInfoView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnExtra:regOnButtonClick(function()
        self:ClickExtra()
    end)

    EventSystem.AddEvent("ShowScoutPlayerInfo", self, self.ShowScoutPlayerInfo)
end

function CourtScoutPlayerInfoView:onDestroy()
    EventSystem.RemoveEvent("ShowScoutPlayerInfo", self, self.ShowScoutPlayerInfo)
end

function CourtScoutPlayerInfoView:InitView(courtBuildModel, cardResourceCache)
    self.beActivatedPlayers = {}
    local scoutLvl = courtBuildModel:GetBuildLevel(CourtBuildType.ScoutBuild)
    local playerStageMap = {}
    for k, v in pairs(Card) do
        local valid = tonumber(v.valid)
        local transferCondition = tonumber(v.transferCondition)
        if valid == 1 and transferCondition > 0 then 
            if not playerStageMap[transferCondition] then 
                playerStageMap[transferCondition] = {}
            end
            table.insert(playerStageMap[transferCondition], v.ID)

            if transferCondition <= scoutLvl then 
                self.beActivatedPlayers[v.ID] = true
            end
        end
    end
    self.playerListScroll:InitView(playerStageMap, cardResourceCache, scoutLvl, courtBuildModel)

    local playerInfoModel = PlayerInfoModel.new()
    local lvl = playerInfoModel:GetLevel()
    local needLvl = LevelLimit["building"].playerLevel
    GameObjectHelper.FastSetActive(self.hintInfo, tobool(tonumber(lvl) < tonumber(needLvl)))
end

function CourtScoutPlayerInfoView:ClickExtra()
    if self.clickExtra then 
        self.clickExtra(self.beActivatedPlayers)
    end 
end

function CourtScoutPlayerInfoView:DisableScoutPlayerInfo()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function CourtScoutPlayerInfoView:ShowScoutPlayerInfo()
    GameObjectHelper.FastSetActive(self.gameObject, true)
end

function CourtScoutPlayerInfoView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function CourtScoutPlayerInfoView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

return CourtScoutPlayerInfoView
