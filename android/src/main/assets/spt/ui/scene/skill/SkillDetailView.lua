local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local CardDialogType = require("ui.controllers.cardDetail.CardDialogType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardConfig = require("ui.common.card.CardConfig")
local LevelLimit = require("data.LevelLimit")
local VIP = require("data.VIP")
local SkillStateType = require("ui.scene.skill.SkillStateType")
local SkillShowType = require("ui.scene.skill.SkillShowType")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local SkillCostType = require("ui.scene.skill.SkillCostType")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local SkillType = require("ui.common.enum.SkillType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local SkillDetailView = class(unity.base)

function SkillDetailView:ctor()
    self.quality = self.___ex.quality
    self.skillIcon = self.___ex.skillIcon
    self.normalObj = self.___ex.normalObj
    self.normalName = self.___ex.normalName
    self.normalSkillLevel = self.___ex.normalSkillLevel
    self.normalSkillInfo = self.___ex.normalSkillInfo
    self.lockText = self.___ex.lockText
    self.skillLock = self.___ex.skillLock
    self.levelSlider = self.___ex.levelSlider

    self.skillDesc = self.___ex.skillDesc
    self.currentSkillInfo = self.___ex.currentSkillInfo
    self.nextSkillInfo = self.___ex.nextSkillInfo

    self.btnLevelUp = self.___ex.btnLevelUp
    self.btnJump = self.___ex.btnJump
    self.close = self.___ex.close

    self.animator = self.___ex.animator
    self.effect = self.___ex.effect
    self.position = self.___ex.position -- table
    self.formation = self.___ex.formation
    self.match = self.___ex.match
    self.matchtext = self.___ex.matchtext

    self.chemicalContent = self.___ex.chemicalContent -- 最佳拍档技能描述
    self.chemicalArea = self.___ex.chemicalArea
    self.chemicalCard = self.___ex.chemicalCard
    self.stateArea = self.___ex.stateArea
    self.stateText = self.___ex.stateText
    self.notActive = self.___ex.notActive
    self.active = self.___ex.active
    self.diamondArea = self.___ex.diamondArea
    self.skillItemArea = self.___ex.skillItemArea
    self.skillItemText = self.___ex.skillItemText
    self.skillSign = self.___ex.skillSign
    self.skillExLvl = self.___ex.skillExLvl

    -- 一键升级
    self.btnOnClickLvlUp = self.___ex.btnOnClickLvlUp
    self.txtCurrency_oneClick = self.___ex.txtCurrency_oneClick
    self.iconCurrency_oneClick = self.___ex.iconCurrency_oneClick

    self.costType = SkillCostType.Defalut
    self.oneClickCostType = SkillCostType.Defalut
end

function SkillDetailView:start()
    self.close:regOnButtonClick(function()
        self:Close(true)
    end)
    self.btnLevelUp:regOnButtonClick(function()
        if self.levelUpClick and type(self.levelUpClick) == "function" then
            self.levelUpClick(self.skillState, self.costType)
        end
    end)
    self.btnOnClickLvlUp:regOnButtonClick(function()
        if self.onOneClickLvlUp and type(self.onOneClickLvlUp) == "function" then
            self.onOneClickLvlUp(self.skillState, self.oneClickCostType)
        end
    end)
    self.btnJump:regOnButtonClick(function()
        if self.jumpClick and type(self.jumpClick) == "function" then
            self.jumpClick()
        end
    end)
    -- 越南版技能额外加成说明文字与等级进度条重叠
    if luaevt.trig("__VN__VERSION__") then
        self.skillExLvl.transform.anchoredPosition = Vector2(255, -65)
    else
        self.skillExLvl.transform.anchoredPosition = Vector2(228.7, -65)
    end
end

-- isCloseButton 新手引导的时候屏蔽两侧点击关闭界面防止引导错误
function SkillDetailView:Close(isCloseButton)
    if GuideManager.GuideIsOnGoing("main") then
        if not isCloseButton then 
            return 
        end
    end
    if self.skillShowType == SkillShowType.IsPaster then 
        self:CloseDialog()
    else
        self.animator:Play("CardDialogRotateBackCN")
    end
end

function SkillDetailView:ShowDialog(cardDialogType)
    if cardDialogType == CardDialogType.SKILL then -- 在回到技能界面时还原位置
        self.transform.anchoredPosition = Vector2(0, 0)
        self.animator:Play("CardDialogRotateCN")
    end
end

function SkillDetailView:CloseDialog()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function SkillDetailView:OnShowDetail()
    if self.showDetail then 
        self.showDetail()
    end
end

function SkillDetailView:OnAnimationEnd()
    self:CloseDialog()
end

function SkillDetailView:SetEffect()
    GameObjectHelper.FastSetActive(self.effect, false)
    GameObjectHelper.FastSetActive(self.effect, true)
end

function SkillDetailView:AdjustInitPos(skillShowType)
    if skillShowType == SkillShowType.IsPaster then 
        self.transform.anchoredPosition = Vector2.zero
    else
        self.transform.anchoredPosition = Vector2(10000, 10000) -- 在点击动画的时候先移走，让动画更流畅
    end
end

local UnlockSkillLevel = 12
function SkillDetailView:InitView(skillItemModel, cardModel, playerInfoModel, skillShowType)
    self.skillItemModel = skillItemModel
    self.skillShowType = skillShowType
    self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(skillItemModel:GetIconIndex())
    self.cardModel = cardModel
    self.skillDesc.text = skillItemModel:GetDesc()
    local position = skillItemModel:GetPosition()
    local match = skillItemModel:GetMatchName() 
    local restrain = skillItemModel:GetRestrainedName()
    if position then
        GameObjectHelper.FastSetActive(self.formation, true)
        self:SetPosition(position)
    end
    if match or restrain then
        GameObjectHelper.FastSetActive(self.match.gameObject, true)
        self.match.text = match and lang.transstr("skillDetail_match") or lang.transstr("skillDetail_restrain")
        local list = match or restrain
        local text = ""
        for i, v in ipairs(list) do
            if i == 1 then
                text = text .. v
            else
                text = text .. "\n" .. v
            end
        end
        self.matchtext.text = text
    end
    local isOperable = cardModel:IsOperable()
    local name = skillItemModel:GetName()
    local isOpen = skillItemModel:IsOpen()
    self.currentSkillInfo:InitView(skillItemModel)
    self.nextSkillInfo:InitView(skillItemModel)
    local unlockSkillLevel = LevelLimit["skillLvlUp"].playerLevel or UnlockSkillLevel
    local isLock = playerInfoModel:GetLevel() < unlockSkillLevel
    self.skillState = SkillStateType.None
    local skillLevel = skillItemModel:GetLevel()
    local isChemicalSkill = false
    local currentSkillIsMax = false
    local cardId1, cardId2
    if skillItemModel:IsChemicalSkill() then
        isChemicalSkill = true
        cardId1, cardId2 = skillItemModel:GetChemicalSkillCoupleID()
    elseif skillItemModel:IsTrainingSkill() and skillItemModel:GetSkillType() == SkillType.CHEMICAL then
        isChemicalSkill = true
        cardId1, cardId2 = skillItemModel:GetTrainingChemicalSkillCoupleID()
    end
    if isChemicalSkill then
        local chemicalCardModel = StaticCardModel.new(cardId2)
        local chemical_skillDesc1 = lang.transstr("chemical_skillDesc1")
        local chemical_skillDesc2 = lang.transstr("chemical_skillDesc2")
        self.chemicalContent.text = chemical_skillDesc1 .. "<color=#FFD700FF> " .. chemicalCardModel:GetName() .. " </color>" .. chemical_skillDesc2
        self.chemicalCard:InitView(chemicalCardModel)
        local isPlayerInTeam = cardModel:IsPlayerInTeam()
        local isChemicalPlayerInTeam = cardModel:IsChemicalPlayerInTeam(cardId2)
        if not isPlayerInTeam and not isChemicalPlayerInTeam then
            self.stateText.text = lang.trans("chemical_skillState3")
        elseif not isPlayerInTeam then
            self.stateText.text = lang.trans("chemical_skillState2")
        elseif not isChemicalPlayerInTeam then
            self.stateText.text = lang.trans("chemical_skillState1")
        else
            self.stateText.text = lang.trans("chemical_skillState4")
        end
        local isActive = tobool(isPlayerInTeam and isChemicalPlayerInTeam)
        GameObjectHelper.FastSetActive(self.active.gameObject, isActive)
        GameObjectHelper.FastSetActive(self.notActive.gameObject, not isActive)
    end

    if isOpen and not isLock then
        local attributePlusTable = skillItemModel:GetEffectPlus(skillLevel)
        if not attributePlusTable then
            self.currentSkillInfo:NoSkillEffect()
        else
            self.currentSkillInfo:SetSkillAttribute(skillLevel)
        end

        if skillItemModel:IsUpToMaxLevel30(cardModel) then
            self.nextSkillInfo:ToMax()
            currentSkillIsMax = true
            self.skillState = SkillStateType.Max
        elseif skillItemModel:IsUpToMaxUpgradeMaxLevel(cardModel) then
            self.nextSkillInfo:UpToMaxAscend()
            self.skillState = SkillStateType.NeedAscend
        elseif skillItemModel:IsUpToCurrentUpgradeMaxLevel() then
            self.nextSkillInfo:UpToMaxUpgrade()
            self.skillState = SkillStateType.NeedUpgrade
        else
            self.nextSkillInfo:SetSkillAttribute(tonumber(skillLevel) + 1)
        end

        GameObjectHelper.FastSetActive(self.skillLock, false)
        local maxLevel = skillItemModel:GetSkillMaxLevel()
        local maxLevelStr = "/" .. maxLevel
        self.normalSkillLevel.text = "Lv " .. tostring(skillLevel) .. maxLevelStr
        self.levelSlider.value = tonumber(skillLevel / maxLevel)
        GameObjectHelper.FastSetActive(self.normalSkillInfo, not currentSkillIsMax)
    else
        if isOpen and isLock then 
            self.lockText.text = lang.trans("skill_open", unlockSkillLevel)
            self.skillState = SkillStateType.Lock
        elseif not isOpen then 
            self.lockText.text = lang.trans("not_open")
            self.skillState = SkillStateType.NotOpen
        end
        GameObjectHelper.FastSetActive(self.normalSkillInfo, false)
        GameObjectHelper.FastSetActive(self.skillLock, isOperable)
        self.currentSkillInfo:NotOpen(skillItemModel, skillShowType)
        self.nextSkillInfo:SetSkillAttribute(tonumber(skillLevel) + 1)
    end
    GameObjectHelper.FastSetActive(self.skillDesc.gameObject, not isChemicalSkill)
    GameObjectHelper.FastSetActive(self.chemicalArea.gameObject, isChemicalSkill)
    GameObjectHelper.FastSetActive(self.stateArea.gameObject, isOpen and isChemicalSkill)
    self.normalName.text = name

    if isOperable and isOpen then
        -- 升级按钮状态设置
        self:SetButtonState(not currentSkillIsMax, playerInfoModel)
    else
        self:SetButtonState(false, playerInfoModel)
    end
    
    if self.skillShowType == SkillShowType.IsPaster then 
        local pasterSkillType = skillItemModel:GetPasterSkillType()
        self.skillSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Identity" .. pasterSkillType .. ".png")
        self.skillSign:SetNativeSize()
    end
    local exNum = 0
    local exLvl = ""
    if isOpen and not isLock then
        local skillExLvl = skillItemModel:GetPasterSkillExLvl()
        if skillExLvl > 0 then
            exNum = exNum + 1
            exLvl = exLvl .. lang.transstr("paster_skill_add", skillExLvl) .. "\n"
        end
        local medalExLvl = skillItemModel:GetMedalSkillExLvl()
        if medalExLvl > 0 then
            exNum = exNum + 1
            exLvl = exLvl .. lang.transstr("medal_skill_add", medalExLvl) .. "\n"
        end
        local trainingExlvl = skillItemModel:GetTrainingSkillExLvl()
        if trainingExlvl > 0 then
            exNum = exNum + 1
            exLvl = exLvl .. lang.transstr("training_skill_add", trainingExlvl) .. "\n"
        end
        local herohallExlvl = skillItemModel:GetHerohallSkillExLvl()
        if herohallExlvl > 0 then
            exNum = exNum + 1
            exLvl = exLvl .. lang.transstr("herohall_skill_add", herohallExlvl) .. "\n"
        end
        local coachExLvl = skillItemModel:GetCoachSkillExLvl()
        if coachExLvl > 0 then
            exNum = exNum + 1
            exLvl = exLvl .. lang.transstr("coach_skill_add", coachExLvl) .. "\n"
        end
        local legendRoadExLvl = skillItemModel:GetLegendRoadSkilllvl()
        if legendRoadExLvl > 0 then
            exNum = exNum + 1
            exLvl = exLvl .. lang.transstr("legendRoad_skill_add", legendRoadExLvl) .. "\n"
        end
        local homeCourtExLvl = skillItemModel:GetHomeCourtLvl()
        if homeCourtExLvl > 0 then
            exNum = exNum + 1
            exLvl = exLvl .. lang.transstr("homeCourt_skill_add", homeCourtExLvl) .. "\n"
        end
        local fancyLvl = skillItemModel:GetFancyLvl()
        if fancyLvl > 0 then
            exLvl = exLvl .. lang.transstr("fancy_skill_add", fancyLvl) .. "\n"
        end
        local supportLvl = skillItemModel:GetSupportLvl()
        if supportLvl > 0 then
            exLvl = exLvl .. lang.transstr("support_skill_add", supportLvl) .. "\n"
        end
        exLvl = string.sub(exLvl, 1, string.len(exLvl) - 1)
    end
    self.skillExLvl.text = exLvl
    GameObjectHelper.FastSetActive(self.skillSign.gameObject, self.skillShowType == SkillShowType.IsPaster)
    -- 越南版技能太多会显示不全
    if luaevt.trig("__VN__VERSION__") and exNum >= 5 then
        self.skillExLvl.transform.anchoredPosition = Vector2(255, -80)
    end
end

function SkillDetailView:SetButtonState(isShow, playerInfoModel)
    self.costType = SkillCostType.Defalut
    self.oneClickCostType = SkillCostType.Defalut
    if isShow then
        local vipLvl = playerInfoModel:GetVipLevel()
        local openDiamond = VIP[vipLvl + 1] and (tonumber(VIP[vipLvl + 1].skillUp) == 1)
        local itemsMapModel = ItemsMapModel.new()
        local skillCouponNum = itemsMapModel:GetItemNum(SkillCostType.SkillCouponId)
        local skillCouponIcon = res.LoadRes(SkillCostType.SkillCouponPath)
        local diamondIcon = res.LoadRes(CurrencyImagePath.d)
        -- 单次升级按钮状态判断
        if skillCouponNum > 0 then
            self.skillItemText.text = "x" .. skillCouponNum
            self.skillItemArea.overrideSprite = skillCouponIcon
            self.costType = SkillCostType.SkillItem
        else
            if openDiamond then
                self.skillItemText.text = "x" .. SkillCostType.DiamondCost
                self.skillItemArea.overrideSprite = diamondIcon
                self.costType = SkillCostType.Diamond
            end
        end
        -- 一键升级按钮状态判断
        local maxLvl = self.skillItemModel:GetSkillMaxLevel()
        local currLvl = self.skillItemModel:GetLevel()
        if skillCouponNum > 0 then
            self.txtCurrency_oneClick.text = "x" .. skillCouponNum
            self.iconCurrency_oneClick.overrideSprite = skillCouponIcon
            self.oneClickCostType = SkillCostType.SkillItem
        else
            if openDiamond then
                local currDiamond = playerInfoModel:GetDiamond()
                local needDiamond = (maxLvl - currLvl) * SkillCostType.DiamondCost
                if needDiamond > currDiamond then
                    needDiamond = math.floor(currDiamond / SkillCostType.DiamondCost) * SkillCostType.DiamondCost
                end
                if needDiamond <= 0 then needDiamond = SkillCostType.DiamondCost end
                self.txtCurrency_oneClick.text = "x" .. needDiamond
                self.iconCurrency_oneClick.overrideSprite = diamondIcon
                self.oneClickCostType = SkillCostType.Diamond
            end
        end
    end
    GameObjectHelper.FastSetActive(self.btnJump.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.btnLevelUp.gameObject, tobool(self.costType ~= SkillCostType.Defalut))
    GameObjectHelper.FastSetActive(self.btnOnClickLvlUp.gameObject, tobool(self.oneClickCostType ~= SkillCostType.Defalut))
end

function SkillDetailView:EnterScene()
    EventSystem.AddEvent("PlayerCardModel_UpdateSkillLevelUp", self, self.EventUpdateSkillLevelUp)
    EventSystem.AddEvent("CardDetail_ShowDialog", self, self.ShowDialog)
end

function SkillDetailView:ExitScene()
    EventSystem.RemoveEvent("PlayerCardModel_UpdateSkillLevelUp", self, self.EventUpdateSkillLevelUp)
    EventSystem.RemoveEvent("CardDetail_ShowDialog", self, self.ShowDialog)
end

function SkillDetailView:EventUpdateSkillLevelUp(pcid)
    if self.updateSkillLevelUpCallBack then
        self.updateSkillLevelUpCallBack(pcid)
    end
end

function SkillDetailView:SetPosition(position)
    assert(type(position) == "table")
    for k, v in pairs(self.position) do
        GameObjectHelper.FastSetActive(v, false)
    end
    for i, v in ipairs(position) do
        local pos = self.position[tostring(CardConfig.POSITION_LETTER_MAP[v])]
        GameObjectHelper.FastSetActive(pos, true)
    end    
end

return SkillDetailView
