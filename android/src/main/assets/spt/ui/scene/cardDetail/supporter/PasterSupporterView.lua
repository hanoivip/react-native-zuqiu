local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PasterQueueModel = require("ui.models.paster.PasterQueueModel")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local PasterSupporterView = class(unity.base, "PasterSupporterView")

function PasterSupporterView:ctor()
--------Start_Auto_Generate--------
    self.supportCardGo = self.___ex.supportCardGo
    self.tipBtn = self.___ex.tipBtn
    self.curAttrName1Txt = self.___ex.curAttrName1Txt
    self.curAttrTxt1Txt = self.___ex.curAttrTxt1Txt
    self.curAttrName2Txt = self.___ex.curAttrName2Txt
    self.curAttrTxt2Txt = self.___ex.curAttrTxt2Txt
    self.curAttrName3Txt = self.___ex.curAttrName3Txt
    self.curAttrTxt3Txt = self.___ex.curAttrTxt3Txt
    self.curAttrName4Txt = self.___ex.curAttrName4Txt
    self.curAttrTxt4Txt = self.___ex.curAttrTxt4Txt
    self.curAttrName5Txt = self.___ex.curAttrName5Txt
    self.curAttrTxt5Txt = self.___ex.curAttrTxt5Txt
    self.curSkillLevTxt = self.___ex.curSkillLevTxt
    self.detailBtn = self.___ex.detailBtn
    self.nextAttrName1Txt = self.___ex.nextAttrName1Txt
    self.nextAttrTxt1Txt = self.___ex.nextAttrTxt1Txt
    self.nextAttrName2Txt = self.___ex.nextAttrName2Txt
    self.nextAttrTxt2Txt = self.___ex.nextAttrTxt2Txt
    self.nextAttrName3Txt = self.___ex.nextAttrName3Txt
    self.nextAttrTxt3Txt = self.___ex.nextAttrTxt3Txt
    self.nextAttrName4Txt = self.___ex.nextAttrName4Txt
    self.nextAttrTxt4Txt = self.___ex.nextAttrTxt4Txt
    self.nextAttrName5Txt = self.___ex.nextAttrName5Txt
    self.nextAttrTxt5Txt = self.___ex.nextAttrTxt5Txt
    self.nextSkillLevTxt = self.___ex.nextSkillLevTxt
--------End_Auto_Generate----------
end

function PasterSupporterView:start()
    self.detailBtn:regOnButtonClick(function ()
        self:OnDetailClick()
    end)
    self.tipBtn:regOnButtonClick(function()
        self:OnTipBtnClick()
    end)
end

function PasterSupporterView:InitView(pasterSupporterModel)
    self.model = pasterSupporterModel
    self.supportCard = pasterSupporterModel:GetSupportCardModel()
    self.pasterQueueModel = PasterQueueModel.new(self.supportCard)
    local tag = {["1"] = true, ["2"] = true, ["3"] = true, ["5"] = true}
    self.pasterQueueModel:SetPasterSearchList(tag)
    self:ShowPasterSupport()
end

function PasterSupporterView:ShowPasterSupport()
    local supportCard = self.supportCard
    if supportCard == nil then
        GameObjectHelper.FastSetActive(self.supportCardGo, false)
        return
    end
    GameObjectHelper.FastSetActive(self.supportCardGo, true)

    local pentagonOrder
    if supportCard:IsGKPlayer() then
        pentagonOrder = CardHelper.GoalKeeperOrder
    else
        pentagonOrder = CardHelper.NormalPlayerOrder
    end

    local ability, nextAbility = self.supportCard:GetSupportPasterAbility()
    for i, abilityIndex in ipairs(pentagonOrder) do
        local str = lang.transstr(abilityIndex) .. ":"
        self["curAttrName" .. tostring(i) .. "Txt"].text = str
        self["curAttrTxt" .. tostring(i) .. "Txt"].text = tostring(ability[abilityIndex] or 0)
        self["nextAttrName" .. tostring(i) .. "Txt"].text = str
        self["nextAttrTxt" .. tostring(i) .. "Txt"].text = tostring(nextAbility[abilityIndex] or 0)
    end
    local skillLev2, skillLev3, skillLev5 = self.supportCard:GetSupportPasterSkillInitLev()
    local baseCardModel = self.model:GetCardModel()
    local str = lang.transstr("fancyAttrLevelContent") .. ": +"
    self.curSkillLevTxt.text = str .. (skillLev2 + skillLev3 + skillLev5)
    self.nextSkillLevTxt.text = str .. baseCardModel:GetSupportPasterSkillLev(self.supportCard)
end

function PasterSupporterView:OnDetailClick()
    res.PushDialog("ui.controllers.cardDetail.supporter.PasterQueueSupporterCtrl", self.pasterQueueModel)
end

function PasterSupporterView:OnTipBtnClick()
    local simpleIntroduceModel = SimpleIntroduceModel.new(24, "CardSupporterPaster")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function PasterSupporterView:EnterScene()

end

function PasterSupporterView:ExitScene()

end

return PasterSupporterView
