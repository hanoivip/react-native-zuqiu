local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachGuideModel = require("ui.models.coach.coachGuide.CoachGuideModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local CardDetailModel = require("ui.models.cardDetail.CardDetailModel")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local CardDetailPageType = require("ui.scene.cardDetail.CardDetailPageType")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local MenuType = require("ui.controllers.itemList.MenuType")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CoachGuideCtrl = class(BaseCtrl)

CoachGuideCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachGuide/CoachGuideBoard.prefab"

function CoachGuideCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        local infoBarCtrl = InfoBarCtrl.new(child, self)
        infoBarCtrl:RegOnBtnBack(function ()
            self.view:coroutine(function()
                unity.waitForEndOfFrame()
                res.PopSceneImmediate()
            end)
        end)
    end)
    self.view.onBagClick = function() self:OnClickBag() end
    self.view.onSwitchClick = function(guideSlotData) self:OnClickSwitch(guideSlotData) end
    self.view.onAddClick = function(guideSlotData) self:OnClickAdd(guideSlotData) end
    self.view.onBuyClick = function(guideSlotData) self:OnClickBuy(guideSlotData) end
    self.view.onNotOpenClick = function(guideSlotData) self:OnClickNotOpen(guideSlotData) end
    self.view.onCardDetailClick = function(guideSlotData) self:OnClickCardDetail(guideSlotData) end
end

function CoachGuideCtrl:Refresh()
    CoachGuideCtrl.super.Refresh(self)
    self.coachGuideModel = CoachGuideModel.new()
    self.view:InitView(self.coachGuideModel)
    GuideManager.Show(self)
end

function CoachGuideCtrl:OnClickBag()
    res.PushSceneImmediate("ui.controllers.itemList.ItemListMainCtrl", MenuType.TACTIC, nil, CoachItemType.PlayerTalentSkillBook)
end

function CoachGuideCtrl:OnClickSwitch(guideSlotData)
    local pcids = self.coachGuideModel:GetSlotPcids()
    guideSlotData.pcids = pcids
    res.PushDialog("ui.controllers.coach.coachGuide.CoachPlayerListMainCtrl", guideSlotData)
end

function CoachGuideCtrl:OnClickAdd(guideSlotData)
    local pcids = self.coachGuideModel:GetSlotPcids()
    guideSlotData.pcids = pcids
    res.PushDialog("ui.controllers.coach.coachGuide.CoachPlayerListMainCtrl", guideSlotData)
end

function CoachGuideCtrl:OnClickBuy(guideSlotData)
    res.PushDialog("ui.controllers.coach.coachGuide.CoachGuideBuyCtrl", guideSlotData)
end

function CoachGuideCtrl:OnClickNotOpen(guideSlotData)

end

function CoachGuideCtrl:OnClickCardDetail(guideSlotData)
    local pcid = guideSlotData.slotStateData.pcid
    local currentModel = CardBuilder.GetStarterModel(pcid)
    local cardDetailModel = CardDetailModel.new(currentModel)
    cardDetailModel:SetCurrentPage(CardDetailPageType.FeaturePage)
    local cardList = {pcid}
    local cardCtrl = res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, 1, currentModel, cardDetailModel)
	GuideManager.Show(cardCtrl)
end

function CoachGuideCtrl:SlotPlayerChange(data)
    self.coachGuideModel:InitWithProtocol(data)
    self.view:InitView(self.coachGuideModel)
end

--再次触发引导 到添加指导球员
function CoachGuideCtrl:GuideToPlayerChoice(slotId)
    self.view.guideListScroll:scrollToPosImmediate(1)
    GuideManager.InitCurModule("coachguide2")
    GuideManager.Show(self)
end

--再次触发引导 到指导球员特性
function CoachGuideCtrl:EnterPlayerGuide()
    self.view.guideListScroll:scrollToPosImmediate(1)
    GuideManager.InitCurModule("coachguide3")
    GuideManager.Show(self)
end

--- 注册事件
function CoachGuideCtrl:RegisterEvent()
    EventSystem.AddEvent("CoachGuideCtrl_SlotPlayerChange", self, self.SlotPlayerChange)
    EventSystem.AddEvent("CoachGuideCtrl_GuideToPlayerChoice", self, self.GuideToPlayerChoice)
    EventSystem.AddEvent("CoachGuideCtrl_EnterPlayerGuide", self, self.EnterPlayerGuide)
end

--- 移除事件
function CoachGuideCtrl:RemoveEvent()
    EventSystem.RemoveEvent("CoachGuideCtrl_SlotPlayerChange", self, self.SlotPlayerChange)
    EventSystem.RemoveEvent("CoachGuideCtrl_GuideToPlayerChoice", self, self.GuideToPlayerChoice)
    EventSystem.RemoveEvent("CoachGuideCtrl_EnterPlayerGuide", self, self.EnterPlayerGuide)
end

function CoachGuideCtrl:OnEnterScene()
    self:RegisterEvent()
end

function CoachGuideCtrl:OnExitScene()
    self:RemoveEvent()
end

return CoachGuideCtrl
