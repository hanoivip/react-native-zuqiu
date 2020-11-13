local AdvanceCtrl = require("ui.controllers.cardDetail.AdvanceCtrl")
local PlayerLevelUpCtrl = require("ui.controllers.cardDetail.PlayerLevelUpCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local BasePageCtrl = class(nil, "BasePageCtrl")

function BasePageCtrl:ctor(view, content)
    self:Init(content)
end

function BasePageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/BasePage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.pageView.clickLevelUp = function() self:OnBtnLevelUp() end
    self.pageView.clickTraining = function () self:OnBtnTraining() end
    self.advanceCtrl = AdvanceCtrl.new(self.pageView.advanceView)
end

function BasePageCtrl:OnBtnLevelUp()
    local isOperable = self.cardDetailModel:GetCardModel():IsOperable()
    if isOperable then 
        local playerLevelUpCtrl = PlayerLevelUpCtrl.new(self.cardDetailModel)
        -- 点击升级按钮
        GuideManager.Show(playerLevelUpCtrl)
    end
end

function BasePageCtrl:OnBtnTraining()
    res.ChangeScene("ui.controllers.cardTraining.CardTrainingMainCtrl", self.cardDetailModel)
end

function BasePageCtrl:EnterScene()
    self.advanceCtrl:EnterScene()
end

function BasePageCtrl:ExitScene()
    self.advanceCtrl:ExitScene()
end

function BasePageCtrl:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.pageView:InitView(cardDetailModel)
    self.advanceCtrl:InitControl(cardDetailModel)
end

function BasePageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return BasePageCtrl
