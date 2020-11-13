local CardBuilder = require("ui.common.card.CardBuilder")
local CardDetailModel = require("ui.models.cardDetail.CardDetailModel")
local PlayerLetterModel = require("ui.models.playerLetter.PlayerLetterModel")
local DiscussHotTopicModel = require("ui.models.discuss.DiscussHotTopicModel")
local ShareHelper = require("ui.common.ShareHelper")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local CardMoreInfoCtrl = class(BaseCtrl)

CardMoreInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardMoreInfo/CardMoreInfo.prefab"

CardMoreInfoCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false
}

function CardMoreInfoCtrl:Init()
    -- bind buttons
    self.view.checkGroup:BindMenuItem(
        "moreInfo",
        function()
            self:SwitchToMoreInfo()
        end
    )
    self.view.checkGroup:BindMenuItem(
        "source",
        function()
            self:SwitchToSource()
        end
    )
    self.view.checkGroup:BindMenuItem(
        "brief",
        function()
            self:SwitchToBrief()
        end
    )
    self.view.checkGroup:BindMenuItem(
        "correlation",
        function()
            self:SwitchToCorrelation()
        end
    )

    self.view.checkGroup:BindMenuItem(
        "discuss",
        function()
            self:SwitchToDiscuss()
        end
    )
    self.view.shareClick = function() self:OnShareClick() end
    self.view.checkGroup:selectMenuItem("moreInfo")
    self:SwitchToMoreInfo()
end

function CardMoreInfoCtrl:Refresh(cid, currentModel, cardDetailModel)
    self.cid = cid
    self.currentModel = currentModel
    self.cardDetailModel = cardDetailModel
    -- refresh view by model
    self.view:InitView(self.currentModel, self.cardDetailModel, self.playerData, self.playerLetterData)
end

function CardMoreInfoCtrl:AheadRequest(cid)
    -- server request
    local response = req.cardAccess(cid)
    if api.success(response) then
        self.playerData = response.val
    end

    local response = req.playerLetterInfo()
    if api.success(response) then
        self.playerLetterData = response.val.list
    end

end

function CardMoreInfoCtrl:SwitchToMoreInfo()
    self.view.briefPanel:SetActive(false)
    self.view.cardRoot:SetActive(false)
    self.view.sourcePanel:SetActive(false)
    self.view.listPanel:SetActive(true)
    self.view.correlationListPanel:SetActive(false)
    self.view.discussPanel:SetActive(false)
    self.view.isOwned:SetActive(true)
end

function CardMoreInfoCtrl:SwitchToSource()
    self.view.briefPanel:SetActive(false)
    self.view.cardRoot:SetActive(true)
    self.view.sourcePanel:SetActive(true)
    self.view.listPanel:SetActive(false)
    self.view.correlationListPanel:SetActive(false)
    self.view.discussPanel:SetActive(false)
    self.view.isOwned:SetActive(true)
end

function CardMoreInfoCtrl:SwitchToBrief()
    self.view.briefPanel:SetActive(true)
    self.view.cardRoot:SetActive(true)
    self.view.sourcePanel:SetActive(false)
    self.view.listPanel:SetActive(false)
    self.view.correlationListPanel:SetActive(false)
    self.view.discussPanel:SetActive(false)
    self.view.isOwned:SetActive(true)
end

function CardMoreInfoCtrl:SwitchToCorrelation()
    self.view.briefPanel:SetActive(false)
    self.view.cardRoot:SetActive(false)
    self.view.sourcePanel:SetActive(false)
    self.view.listPanel:SetActive(false)
    self.view.correlationListPanel:SetActive(true)
    self.view.discussPanel:SetActive(false)
    self.view.isOwned:SetActive(true)
end


function CardMoreInfoCtrl:SwitchToDiscuss()
    self.view.briefPanel:SetActive(false)
    self.view.cardRoot:SetActive(true)
    self.view.sourcePanel:SetActive(false)
    self.view.listPanel:SetActive(false)
    self.view.correlationListPanel:SetActive(false)
    self.view.discussPanel:SetActive(true)
    self:InitDiscuss()
    self.view.isOwned:SetActive(false)
end

function CardMoreInfoCtrl:InitDiscuss()
    clr.coroutine(function()
        local response = req.queryNormalHotComment(self.cid, 0, 10)
        if api.success(response) then
            discussHotTopicModel = DiscussHotTopicModel.new()
            self.discussHotTopicModel = discussHotTopicModel
            discussHotTopicModel:SetHotTopicContent(self.cid, response.val.commentList)
            self.view.discussContentView:SetDiscussViewPara(false)
            self.view.discussContentView:Init(self.cid, 1, discussHotTopicModel)
        end
    end)
end

function CardMoreInfoCtrl:OnShareClick()
    local reply = self.discussHotTopicModel:GetShareContent()
    ShareHelper.DiscussCaptrueCamera(reply, self.cid)
end

return CardMoreInfoCtrl
