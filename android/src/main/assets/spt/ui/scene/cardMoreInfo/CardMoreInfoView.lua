local ChemicalBarView = require("ui.scene.cardDetail.ChemicalBarView")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardMoreInfoView = class(unity.base)

local UnityEngine = clr.UnityEngine

function CardMoreInfoView:ctor()
    self.checkGroup = self.___ex.checkGroup
    self.briefPanel = self.___ex.briefPanel
    self.sourcePanel = self.___ex.sourcePanel
    self.listPanel = self.___ex.listPanel
    self.briefView = self.___ex.briefView
    self.sourceView = self.___ex.sourceView
    self.multiView = self.___ex.multiView
    self.cardRoot = self.___ex.cardRoot
    self.cardParent = self.___ex.cardParent
    self.cardName = self.___ex.cardName
    self.isOwnedTxt = self.___ex.isOwnedTxt
    self.isActive = self.___ex.isActive
    self.closeBtn = self.___ex.closeBtn
    self.playerNameTxt = self.___ex.playerNameTxt
    self.correlationView = self.___ex.correlationView
    self.correlationListPanel = self.___ex.correlationListPanel
    self.discussContentView = self.___ex.discussContentView
    self.discussPanel = self.___ex.discussPanel
    self.isOwned = self.___ex.isOwned
    self.shareBtn = self.___ex.shareBtn

    self.closeBtn:regOnButtonClick(
        function()
            self:Close()
        end
    )

    self.shareBtn:regOnButtonClick(
        function()
            if self.shareClick then
                self.shareClick()
            end
        end
    )
    if clr.plat == "Android" then
        GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
    end
    DialogAnimation.Appear(self.transform, nil)
end

function CardMoreInfoView:InitView(currentModel, cardDetailModel, playerData, playerLetterData)
    self.currentModel = currentModel
    self.cardDetailModel = cardDetailModel
    self.playerData = playerData

    self.briefView:InitView(self.currentModel)
    self.sourceView:InitView(self.currentModel, playerData)
    self.multiView:InitView(self.currentModel, playerLetterData)
    self.correlationView:InitView(self.currentModel)

    if not self.cardView then
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        cardObject.transform:SetParent(self.cardParent, false)
        self.cardView = cardSpt
        self.cardView:IsShowName(false)
    end

    self.cardName.text = tostring(self.currentModel:GetName())
    self.cardView:InitView(self.currentModel)
    if self.playerData.own then
        self.isOwnedTxt.text = lang.trans("have_own_player")
    else
        self.isOwnedTxt.text = lang.trans("do_not_have_player")
    end
    self.isActive:SetActive(self.playerData.collected)
end

function CardMoreInfoView:contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function CardMoreInfoView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(
            self.transform,
            nil,
            function()
                if type(self.closeCallback) == "function" then
                    self.closeCallback()
                end
                self.closeDialog()
            end
        )
    end
end

return CardMoreInfoView
