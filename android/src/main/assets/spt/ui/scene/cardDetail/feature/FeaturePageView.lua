local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FeatureSkillItemModel = require("ui.models.cardDetail.feature.FeatureSkillItemModel")
local FeatureSkillItemLockModel = require("ui.models.cardDetail.feature.FeatureSkillItemLockModel")
local FeatureSkillItemAppointModel = require("ui.models.cardDetail.feature.FeatureSkillItemAppointModel")
local AssetFinder = require("ui.common.AssetFinder")
local FeaturePageView = class(unity.base)

function FeaturePageView:ctor()
    self.itemAddSign = self.___ex.itemAddSign
    self.btnItem = self.___ex.btnItem
    self.itemName = self.___ex.itemName
    self.tipsObject = self.___ex.tipsObject
    self.tipsText = self.___ex.tipsText
    self.featureAddSign = self.___ex.featureAddSign
    self.item = self.___ex.item
    self.feature = self.___ex.feature
    self.itemQuality = self.___ex.itemQuality
    self.itemIcon = self.___ex.itemIcon
    self.featureQuality = self.___ex.featureQuality
    self.featureDecorate = self.___ex.featureDecorate
    self.featureIcon = self.___ex.featureIcon
    self.btnFeature = self.___ex.btnFeature
    self.btnQuestion = self.___ex.btnQuestion
    self.featureName = self.___ex.featureName
    self.btnUse = self.___ex.btnUse
    self.notAvailable = self.___ex.notAvailable
    self.available = self.___ex.available
    self.border = self.___ex.border
    self.bottom = self.___ex.bottom
    self.bottomTitleBar1 = self.___ex.bottomTitleBar1
    self.bottomTitleBar2 = self.___ex.bottomTitleBar2
    self.bottomTitle = self.___ex.bottomTitle
    self.featureSkillArea = self.___ex.featureSkillArea
    self.targetItem = self.___ex.targetItem
    self.targetFeature = self.___ex.targetFeature
    self.useLabel = self.___ex.useLabel
    self.itemModel = nil -- 道具model
    self.itemFuncModel = nil -- 道具放入后重新生成的model
    self.skillModel = nil -- 特性书
    self.skillFeatureMap = {}
end

function FeaturePageView:start()
    self.btnItem:regOnButtonClick(function()
        self:OnBtnItem()
    end)
    self.btnFeature:regOnButtonClick(function ()
        self:OnBtnFeature()
    end)
    self.btnUse:regOnButtonClick(function ()
        self:OnBtnUse()
    end)
    self.btnQuestion:regOnButtonClick(function ()
        self:OnBtnQuestion()
    end)
end

function FeaturePageView:OnBtnQuestion()
    if self.clickQuestion then 
        self.clickQuestion()
    end
end

function FeaturePageView:OnBtnUse()
    if self.clickUse then 
        self.clickUse(self.skillModel, self.itemFuncModel)
    end
end

function FeaturePageView:OnBtnItem()
    if self.clickItem then 
        self.clickItem(self.itemModel)
    end
end

function FeaturePageView:OnBtnFeature()
    if self.clickFeature then
        self.clickFeature(self.skillModel)
    end
end

function FeaturePageView:EnterScene()
    EventSystem.AddEvent("CardFeatureUnloadHandle", self, self.EventFeatureUnloadHandle)
    EventSystem.AddEvent("CardFeatureReplaceHandle", self, self.EventFeatureReplaceHandle)
    EventSystem.AddEvent("CardFeatureEquipHandle", self, self.EventFeatureEquipHandle)
    EventSystem.AddEvent("CardFeature_ChooseCancel", self, self.EventFeatureChooseCancel)
    EventSystem.AddEvent("CardFeature_ChooseConfirm", self, self.EventFeatureChooseConfirm)
    for i, v in ipairs(self.skillFeatureMap) do
        v:EnterScene()
    end
end

function FeaturePageView:ExitScene()
    EventSystem.RemoveEvent("CardFeatureUnloadHandle", self, self.EventFeatureUnloadHandle)
    EventSystem.RemoveEvent("CardFeatureReplaceHandle", self, self.EventFeatureReplaceHandle)
    EventSystem.RemoveEvent("CardFeatureEquipHandle", self, self.EventFeatureEquipHandle)
    EventSystem.RemoveEvent("CardFeature_ChooseCancel", self, self.EventFeatureChooseCancel)
    EventSystem.RemoveEvent("CardFeature_ChooseConfirm", self, self.EventFeatureChooseConfirm)
    for i, v in ipairs(self.skillFeatureMap) do
        v:ExitScene()
    end
end

function FeaturePageView:EventFeatureChooseCancel()
    self:InitialFeature()
end

function FeaturePageView:EventFeatureChooseConfirm(skillModel, oldSkill, pcid, skillBookId, itemId)
    if self.featureChoose then
        self.featureChoose(skillModel, oldSkill, pcid, skillBookId, itemId)
    end
end

function FeaturePageView:EventFeatureUnloadHandle(coachItemType)
    if coachItemType == CoachItemType.PlayerTalentSkillBook then 
        GameObjectHelper.FastSetActive(self.feature, false)
        self.skillModel = nil
        self.featureName.text = lang.trans("put_on_feature")
        GameObjectHelper.FastSetActive(self.notAvailable, true)
        GameObjectHelper.FastSetActive(self.available, false)
        self.useLabel.color = ColorConversionHelper.ConversionColor(147, 147, 147)
    elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then 
        GameObjectHelper.FastSetActive(self.item, false)
        GameObjectHelper.FastSetActive(self.tipsObject, false)
        self.itemFuncModel = nil
        self.itemModel = nil
        self.itemName.text = lang.trans("put_on_item")
        self:RefreshFeatureSkill()
    end
end

function FeaturePageView:EventFeatureReplaceHandle(coachItemType, equipFeatureModel)
    self:EventFeatureHandle(coachItemType, equipFeatureModel)
end

function FeaturePageView:EventFeatureEquipHandle(coachItemType, equipFeatureModel)
    self:EventFeatureHandle(coachItemType, equipFeatureModel)
end

function FeaturePageView:EventFeatureHandle(coachItemType, equipFeatureModel)
    if coachItemType == CoachItemType.PlayerTalentSkillBook then 
        self.featureDecorate.overrideSprite = AssetFinder.GetCoachFeatureDecorateIcon(equipFeatureModel:GetDecoratePicIcon())
        self.featureIcon.overrideSprite = AssetFinder.GetCoachItemIcon(equipFeatureModel:GetIconIndex(), equipFeatureModel:GetCoachItemType())
        self.featureQuality.overrideSprite = AssetFinder.GetItemQualityBoard(equipFeatureModel:GetQuality())
        self.featureName.text = equipFeatureModel:GetName()
        self.skillModel = equipFeatureModel
        self.useLabel.color = ColorConversionHelper.ConversionColor(101, 85, 60)
        GameObjectHelper.FastSetActive(self.feature, true)
        GameObjectHelper.FastSetActive(self.notAvailable, false)
        GameObjectHelper.FastSetActive(self.available, true)
    elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then 
        self.itemIcon.overrideSprite = AssetFinder.GetCoachItemIcon(equipFeatureModel:GetIconIndex(), equipFeatureModel:GetCoachItemType())
        self.itemQuality.overrideSprite = AssetFinder.GetItemQualityBoard(equipFeatureModel:GetQuality())
        local desc = equipFeatureModel:GetPageDesc()
        self.tipsText.text = string.gsub(desc, "{1}", 0)
        self.itemName.text = equipFeatureModel:GetName()
        GameObjectHelper.FastSetActive(self.item, true)
        GameObjectHelper.FastSetActive(self.tipsObject, true)
        self.itemModel = equipFeatureModel
        local itemId = equipFeatureModel:GetId()
        local itemFunctionType = equipFeatureModel:GetItemFunction()
        if itemFunctionType == CoachItemType.ItemFuncType.Lock then
            -- 锁定道具
            self.itemFuncModel = FeatureSkillItemLockModel.new(itemId)
        elseif itemFunctionType == CoachItemType.ItemFuncType.Replace then
            -- 替换指定道具
            self.itemFuncModel = FeatureSkillItemAppointModel.new(itemId)
        else
            self.itemFuncModel = FeatureSkillItemModel.new(itemId)
        end
        self:RefreshFeatureSkill(self.itemFuncModel)
    end
end

function FeaturePageView:OnClickFeatureSkill(slot)
    local featureModel = self.cardModel:GetFeatureModel(slot)
    if featureModel then
        if self.itemFuncModel and self.itemFuncModel:HasOperational() then 
            local sid = featureModel:GetId()
            self.itemFuncModel:ChangeFeatureStatu(slot, sid)
            self:RefreshFeatureSkill()
        else
            if self.clickFeatureInfo then 
                self.clickFeatureInfo(featureModel)
            end
        end
    end
end

function FeaturePageView:ChangeFuncState(featureModelsMap, itemFuncModel)
    local selectCount = 0 
    for slot, model in pairs(featureModelsMap) do
        if itemFuncModel then
            local updateStatu = itemFuncModel:GetItemFunctionStatu(slot)
            if updateStatu == CoachItemType.SkillFuncType.Lock or updateStatu == CoachItemType.SkillFuncType.Appoint then
                selectCount = selectCount + 1
            end
            model:ChangeFuncState(updateStatu)
        else
            model:ChangeFuncStateByNormal()
        end
    end
    local desc = self.itemModel and self.itemModel:GetPageDesc()
    if desc then 
        self.tipsText.text = string.gsub(desc, "{1}", selectCount)
    end
    EventSystem.SendEvent("CardFeatureSkillRefreshHandle")
end

-- ���ߴ�������״̬
function FeaturePageView:RefreshFeatureSkill()
    local featureModelsMap = self.cardModel:GetFeatureModelsMap()
    self:ChangeFuncState(featureModelsMap, self.itemFuncModel)
end

function FeaturePageView:InitView(cardDetailModel)
    self.cardModel = cardDetailModel:GetCardModel()
    self.border.overrideSprite = cardDetailModel:GetImageRes("bottomAscend1")
    self.bottom.overrideSprite = cardDetailModel:GetImageRes("bottom")
    self.bottomTitle.overrideSprite = cardDetailModel:GetImageRes("bottomTitle")
    self.bottomTitleBar1.overrideSprite = cardDetailModel:GetImageRes("bottomTitleBar1")
    self.bottomTitleBar2.overrideSprite = cardDetailModel:GetImageRes("bottomTitleBar2")

    self:InitialFeature()
    self:HandleFeatureSkill()
end

function FeaturePageView:GetFeatureSkillRes()
    if not self.featureSkillRes then
        self.featureSkillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureSkill.prefab")
    end
    return self.featureSkillRes
end

local function GetTextColor(isShow)
    local r, g, b 
    if isShow then 
        r, g, b = 101, 85, 60
    else
        r, g, b = 147, 147, 147
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    return color
end

-- ��ԭ����״̬
function FeaturePageView:InitialFeature()
    self.itemFuncModel = nil
    self.itemModel = nil
    self.skillModel = nil
    local isOperable = self.cardModel:IsOperable()
    self.useLabel.color = ColorConversionHelper.ConversionColor(147, 147, 147)
    self.itemName.text = isOperable and lang.trans("put_on_item") or ""
    self.featureName.text = isOperable and lang.trans("put_on_feature") or ""
    
    GameObjectHelper.FastSetActive(self.feature, false)
    GameObjectHelper.FastSetActive(self.item, false)
    GameObjectHelper.FastSetActive(self.tipsObject, false)
    GameObjectHelper.FastSetActive(self.notAvailable, true)
    GameObjectHelper.FastSetActive(self.available, false)
    GameObjectHelper.FastSetActive(self.itemAddSign, isOperable)
    GameObjectHelper.FastSetActive(self.featureAddSign, isOperable)
end

-- ��ʼ����������
function FeaturePageView:HandleFeatureSkill()
    for i = 1, CoachItemType.SkillFeaturesNum do
        if not self.skillFeatureMap[i] then 
            local obj = Object.Instantiate(self:GetFeatureSkillRes())
            local spt = res.GetLuaScript(obj)
            spt:EnterScene()
            spt.clickFeature = function(slot) self:OnClickFeatureSkill(slot) end
            self.skillFeatureMap[i] = spt
            obj.transform:SetParent(self.featureSkillArea, false)
        end
        local model = self.cardModel:GetFeatureModel(i)
        self.skillFeatureMap[i]:InitView(model, i)
    end
end

function FeaturePageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function FeaturePageView:onDestroy()
    self.featureSkillRes = nil
end

return FeaturePageView
