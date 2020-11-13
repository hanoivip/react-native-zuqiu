local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardTrainingMedalBoxView = class(unity.base)

function CardTrainingMedalBoxView:ctor()
    self.boxQuality = self.___ex.boxQuality
    self.medalQuality = self.___ex.medalQuality
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
    self.defaultImg = self.___ex.defaultImg
    self.btnMedalItem = self.___ex.btnMedalItem
    self.countTxt = self.___ex.countTxt
    self.numObj = self.___ex.numObj
    self.plus = self.___ex.plus
    self.btnMedalItem:regOnButtonClick(function() self:OnClickMedal() end) 
end

local function EqsCallBack()
    self:coroutine(function ()
        local pcid = self.cardTrainingMainModel:GetPcid()
        local trainId = self.cardTrainingMainModel:GetCurrLevelSelected()
        local subId = self.cardTrainingMainModel:GetSubIdByLevel(trainId)
        local contents = {}
        contents.eqs = {}
        contents.eqs[self.id] = self.needCount
        local response = req.cardTrainingDemand(pcid, trainId, subId, contents)
        if api.success(response) then
            EventSystem.SendEvent("CardTraining_RefreshMainView")
        end
    end)
end 

function CardTrainingMedalBoxView:OnClickMedal()
    if not self.medalModel then
        if not self.cardTrainingMedalModel:IsCanUse() then
            res.PushDialog("ui.controllers.cardTraining.CardTrainingMedalRuleCtrl", self.cardTrainingMedalModel:GetInfoData())
            return
        end
        res.PushDialog("ui.controllers.cardTraining.CardTrainingMedalSelectPageCtrl", self.cardTrainingMainModel)
    end
end

function CardTrainingMedalBoxView:InitView(medalModel, isShowName, isShowAddNum, isShowDetail, cardTrainingMainModel)
    self.medalModel = medalModel
    self.cardTrainingMainModel = cardTrainingMainModel
    self.cardTrainingMedalModel = cardTrainingMainModel:GetCardTrainingMedalMode()
    self:InitMultView(medalModel, cardTrainingMainModel)
    if not medalModel then
        local isHaveUse = self.cardTrainingMedalModel:IsCanUse()
        self:InitSprites(self.cardTrainingMedalModel:GetNeedQuality(), self.cardTrainingMedalModel:GetNeedQuality(), nil, not isHaveUse)
        return
    end
    self:InitSprites(medalModel:GetQuality(), medalModel:GetBoxQuality(), medalModel:GetPic(), medalModel:HasBroken())
    self.nameTxt.text = medalModel:GetName()
end

function CardTrainingMedalBoxView:InitSprites(quality, boxQuality, picIndex, hasBroken)
    self.medalQuality.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/Medal_Quality" .. (quality or 1) .. ".png")
    self.boxQuality.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemQualityBoard/quality_board" .. (boxQuality or 1) .. ".png")
    if picIndex then
        self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex .. ".png")
    end
    local brokenColor = hasBroken and 0 or 1
    self.boxQuality.color = Color(brokenColor, 1, 1, 1)
    self.medalQuality.color = Color(brokenColor, 1, 1, 1)
end

function CardTrainingMedalBoxView:InitMultView(medalModel, cardTrainingMainModel)
    GameObjectHelper.FastSetActive(self.defaultImg, not medalModel)
    GameObjectHelper.FastSetActive(self.icon.gameObject, medalModel)
    GameObjectHelper.FastSetActive(self.plus, not medalModel and self.cardTrainingMedalModel:IsCanUse())
    local needCount = self.cardTrainingMainModel:GetNeedItemMaxCountByTypeAndId("medal")
    local hadCount = self.medalModel and self.medalModel:GetAddNum() or (self.cardTrainingMedalModel:IsCanUse() or 0)
    self.countTxt.text = hadCount .. "-" .. needCount
    if self.medalModel then
        self.countTxt.text = "<color=#d7ff01>" .. hadCount .. "-" .. needCount .. "</color>"
    end
end

return CardTrainingMedalBoxView
