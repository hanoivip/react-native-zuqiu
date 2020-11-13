local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CourtScoutExtraPlayerInfoView = class(unity.base)

function CourtScoutExtraPlayerInfoView:ctor()
    self.btnClose = self.___ex.btnClose
    self.btnBack = self.___ex.btnBack
    self.canvasGroup = self.___ex.canvasGroup
    self.playerListScroll = self.___ex.playerListScroll
end

function CourtScoutExtraPlayerInfoView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnBack:regOnButtonClick(function()
        self:Close()
    end)
end

function CourtScoutExtraPlayerInfoView:InitView(cardResourceCache, beActivatedPlayers, courtBuildModel)
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local cardList = playerCardsMapModel:GetCardList()
    local extraPlayers = {}
    local extraPlayersMap = {}
    for i, pcid in ipairs(cardList) do
        local cardModel = CardBuilder.GetOwnCardModel(pcid)
        local transferCondition = cardModel:GetTransferCondition()
        local valid = cardModel:GetValid()
        if valid == 1 and transferCondition ~= 'none' then 
            local isRebornOpen = cardModel:IsRebornOpen()
            if isRebornOpen then 
                local cid = cardModel:GetCid()
                if not extraPlayersMap[cid] and not beActivatedPlayers[cid] then 
                    extraPlayersMap[cid] = true
                    table.insert(extraPlayers, cid)
                end
            end
        end
    end
    self.playerListScroll:InitView(extraPlayers, cardResourceCache, courtBuildModel)
end

function CourtScoutExtraPlayerInfoView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function CourtScoutExtraPlayerInfoView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

return CourtScoutExtraPlayerInfoView
