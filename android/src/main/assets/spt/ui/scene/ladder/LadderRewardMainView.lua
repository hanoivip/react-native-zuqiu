local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MailRewardType = require("ui.scene.mail.MailRewardType")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")

local LadderRewardMainView = class(unity.base)

function LadderRewardMainView:ctor()
    self.btnBack = self.___ex.btnBack
    self.btnViewCardDetail = self.___ex.btnViewCardDetail
    self.btnRewardDetail = self.___ex.btnRewardDetail
    self.currentSeasonRankBoard = self.___ex.currentSeasonRankBoard
    self.txtSeasonName = self.___ex.txtSeasonName
    self.rewardCardParent = self.___ex.rewardCardParent
    self.seasonTimeArea = self.___ex.seasonTimeArea
    self.seasonEndArea = self.___ex.seasonEndArea
    self.txtSeasonRemainTime = self.___ex.txtSeasonRemainTime
    self.txtSeasonRemainDay = self.___ex.txtSeasonRemainDay
    self.btnArrow = self.___ex.btnArrow
    self.rewardTitle = self.___ex.rewardTitle
end

function LadderRewardMainView:start()
    self:BindButtonHandler()
end

function LadderRewardMainView:InitView(ladderModel)
    self.ladderModel = ladderModel
    self.txtSeasonName.text = ladderModel:GetCurSeasonName()
    self:InitSeasonCd()
end

function LadderRewardMainView:BindButtonHandler()
    self.btnBack:regOnButtonClick(function()
        if self.onBack then
            self.onBack()
        end
    end)
    self.btnViewCardDetail:regOnButtonClick(function()
        if self.onViewCardDetail then
            self.onViewCardDetail()
        end
    end)
    self.btnRewardDetail:regOnButtonClick(function()
        if self.onRewardDetail then
            self.onRewardDetail()
        end
    end)
    self.btnArrow:regOnButtonClick(function()
        if self.onArrowClick then
            self.onArrowClick()
        end
    end)
end

function LadderRewardMainView:InitSeasonCd()
    local seasonCd = self.ladderModel:GetCurSeasonCd()
    if seasonCd <= 0 then
        GameObjectHelper.FastSetActive(self.seasonTimeArea, false)
        GameObjectHelper.FastSetActive(self.seasonEndArea, true)
    else
        GameObjectHelper.FastSetActive(self.seasonTimeArea, true)
        GameObjectHelper.FastSetActive(self.seasonEndArea, false)
        self:coroutine(function()
            self.txtSeasonRemainDay.text, self.txtSeasonRemainTime.text = self:SplitTime(seasonCd)
            while true do
                coroutine.yield(WaitForSeconds(1))
                seasonCd = math.max(seasonCd - 1, 0)
                if seasonCd <= 0 then
                    GameObjectHelper.FastSetActive(self.seasonTimeArea, false)
                    GameObjectHelper.FastSetActive(self.seasonEndArea, true)
                    break
                end
                self.txtSeasonRemainDay.text, self.txtSeasonRemainTime.text = self:SplitTime(seasonCd)
            end
        end)
    end
end

function LadderRewardMainView:SplitTime(seconds)
    local timeStr = string.convertSecondToTime(seconds)
    local startIndex, endIndex = string.find(timeStr, clr.unwrap(lang.trans("day")))
    if startIndex and endIndex then
        local dayStr = string.sub(timeStr, 1, startIndex-1)
        local hourMinuteSecondStr = string.sub(timeStr, endIndex+1, -1)
        if tonumber(dayStr) < 10 then
            dayStr = "0" .. dayStr
        end
        return dayStr, hourMinuteSecondStr
    else
        return "00", timeStr
    end
end

function LadderRewardMainView:GetCurrentSeasonRankBoard()
    return self.currentSeasonRankBoard
end

function LadderRewardMainView:InitPlayerCard(playerCardModel, index)
    self:HideRewardChild()
    if not self.playerCardView then
        local playerCardObject, playerCardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        playerCardObject.transform:SetParent(self.rewardCardParent, false)
        self.playerCardView = playerCardView
    end
    self.playerCardView:InitView(playerCardModel)
    GameObjectHelper.FastSetActive(self.playerCardView.gameObject, true)
    local indexStr = lang.transstr("number_" .. index)
    self.rewardTitle.text = lang.transstr("ladder_reward_infoTitle", indexStr)
end

function LadderRewardMainView:InitCardPiece(cardPieceModel, index)
    self:HideRewardChild()
    if not self.cardPieceView then
        local avatarBoxObj, cardPieceView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/CardPiece.prefab")
        avatarBoxObj.transform:SetParent(self.rewardCardParent, false)
        self.cardPieceView = cardPieceView
    end
    self.cardPieceView:InitView(cardPieceModel, true, false, true)
    self.cardPieceView:SetNumFont(24)
    GameObjectHelper.FastSetActive(self.cardPieceView.gameObject, true)
    local indexStr = lang.transstr("number_" .. index)
    self.rewardTitle.text = lang.transstr("ladder_reward_infoTitle", indexStr)
end

function LadderRewardMainView:InitItem(itemModel, index)
    self:HideRewardChild()
    if not self.itemView then
        local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
        self.itemView = itemBoxView
        itemBoxObj.transform:SetParent(self.rewardCardParent, false)
    end
    self.itemView:InitView(itemModel, itemModel:GetID(), true, false, true, ItemOriginType.OTHER)
    self.itemView:SetNumFont(24)
    GameObjectHelper.FastSetActive(self.itemView.gameObject, true)
    local indexStr = lang.transstr("number_" .. index)
    self.rewardTitle.text = lang.transstr("ladder_reward_infoTitle", indexStr)
end

function LadderRewardMainView:HideRewardChild()
    local childCount = self.rewardCardParent.childCount
    for i = 1, childCount do
        local cTrans = self.rewardCardParent:GetChild(i-1)
        GameObjectHelper.FastSetActive(cTrans.gameObject, false)
    end
end

function LadderRewardMainView:OnEnterScene()
    --GameObjectHelper.FastSetActive(self.seasonTimeArea, false)
end

return LadderRewardMainView
