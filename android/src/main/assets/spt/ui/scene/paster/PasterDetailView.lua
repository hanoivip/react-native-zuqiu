local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local Skills = require("data.Skills")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local PasterDetailView = class(unity.base)

function PasterDetailView:ctor()
    self.pasterCardView = self.___ex.pasterCardView
    self.pasterText = self.___ex.pasterText
    self.pasterDesc = self.___ex.pasterDesc
    self.pasterApply = self.___ex.pasterApply
    self.skillIcon = self.___ex.skillIcon
    self.skillName = self.___ex.skillName
    self.buttonText = self.___ex.buttonText
    self.btnUse = self.___ex.btnUse
    self.btnClose = self.___ex.btnClose
    self.btnSkill = self.___ex.btnSkill
    self.btnSplit = self.___ex.btnSplit
    self.split = self.___ex.split
    self.splitDesc = self.___ex.splitDesc
    self.upgradeGo = self.___ex.upgradeGo
    self.upgradeBtn = self.___ex.upgradeBtn
end

function PasterDetailView:start()
    self.btnUse:regOnButtonClick(function()
        self:OnUseClick()
    end)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnSkill:regOnButtonClick(function()
        self:OnSkillClick()
    end)
    self.btnSplit:regOnButtonClick(function()
        self:OnSplitClick()
    end)
    self.upgradeBtn:regOnButtonClick(function()
        self:OnUpgradeClick()
    end)
    DialogAnimation.Appear(self.transform)
end

function PasterDetailView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

local DefaultHeight = 560
local ExpendHeight = 640
function PasterDetailView:InitView(cardPasterModel, cardPastersMapModel, bSupporter)
    local pasterRes = self:GetPasterRes()
    bSupporter = bSupporter or false
    self.pasterCardView:InitView(cardPasterModel, nil, pasterRes)
    self.pasterText.text = cardPasterModel:GetProfile()
    local pasterType = cardPasterModel:GetPasterType()
    local descText, pieceTypeDesc = "", ""
    local isShowSkill = false
    local sid = nil
    if cardPasterModel:IsWeekPaster() then
        isShowSkill = true
        sid = cardPasterModel:GetPasterSkill()
        descText = lang.trans("paster_week_instruction")
        pieceTypeDesc = lang.transstr("paster_piece_week")
    elseif cardPasterModel:IsMonthPaster() then
        isShowSkill = true
        sid = cardPasterModel:GetPasterSkill()
        descText = lang.trans("paster_month_instruction")
        pieceTypeDesc = lang.transstr("paster_piece_month")
    elseif cardPasterModel:IsHonorPaster() then
        local lvlEx = cardPasterModel:GetHonorSkillLevelEx()
        descText = lang.trans("paster_honor_instruction", lvlEx)
        pieceTypeDesc = lang.transstr("paster_piece_honor")
    elseif cardPasterModel:IsAnnualPaster() then
        local lvlEx = cardPasterModel:GetAnnualSkillLevelEx()
        descText = lang.trans("paster_annual_instruction", lvlEx)
        pieceTypeDesc = lang.transstr("paster_piece_annual")
    elseif cardPasterModel:IsCompetePaster() then
        isShowSkill = true
        sid = cardPasterModel:GetCompetePasterSkill()
        local lvlEx = cardPasterModel:GetCompeteSkillLevelEx()
        local improveSkillName = cardPasterModel:GetCompeteSkillName()
        descText = lang.trans("paster_compete_instruction", improveSkillName, tostring(lvlEx))
        pieceTypeDesc = lang.transstr("paster_piece_compete")
    end
    self.pasterDesc.text = descText
    self.pasterApply.text = cardPasterModel:GetUseText()
    self:UpdateSkillInfo(sid, isShowSkill)

    local hasSplit = false
    local pasterState = cardPasterModel:GetPasterState()
    if pasterState == PasterStateType.CanUse then 
        self.buttonText.text = lang.trans("use")
        hasSplit = cardPastersMapModel:HasSamePaster(cardPasterModel)
    elseif pasterState == PasterStateType.Unload then 
        self.buttonText.text = lang.trans("unload")
    end
    GameObjectHelper.FastSetActive(self.btnUse.gameObject, not bSupporter and pasterState ~= PasterStateType.Default and not cardPasterModel:GetIsPasterPokedex())

    local canSplit = cardPasterModel:CanPasterSplit()
    local fixHeight = DefaultHeight
    if hasSplit and canSplit then
        local splitPieceNum = cardPasterModel:GetSplitPieceNeed()
        self.splitDesc.text = lang.trans("paster_piece_repeat", splitPieceNum, pieceTypeDesc)
        fixHeight = ExpendHeight
    end

    local canUpgrade = cardPasterModel:CanPasterUpgrade()
    if luaevt.trig("__SGP__VERSION__") or luaevt.trig("__UK__VERSION__") or luaevt.trig("__KR__VERSION__") then
		canUpgrade = false
	end
    if canUpgrade then
        fixHeight = ExpendHeight
    end
    GameObjectHelper.FastSetActive(self.split.gameObject, not bSupporter and hasSplit and canSplit)
    GameObjectHelper.FastSetActive(self.upgradeGo, not bSupporter and canUpgrade)

    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, fixHeight)
end

function PasterDetailView:UpdateSkillInfo(sid, isShowSkill)
    GameObjectHelper.FastSetActive(self.btnSkill.gameObject, isShowSkill)
    if isShowSkill then
        local skillTable = Skills[tostring(sid)]
        if skillTable then
            self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(skillTable.picIndex)
            self.skillName.text = tostring(skillTable.skillName)
        end
    end
end

function PasterDetailView:OnUseClick()
    if self.clickUse then 
        self.clickUse()
    end
end

function PasterDetailView:OnSkillClick()
    if self.clickSkill then 
        self.clickSkill()
    end
end

function PasterDetailView:OnSplitClick()
    if self.clickSplit then 
        self.clickSplit()
    end
end

function PasterDetailView:OnUpgradeClick()
    if self.clicUpgrade then 
        self.clicUpgrade()
    end
end

function PasterDetailView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function PasterDetailView:EnterScene()

end

function PasterDetailView:ExitScene()

end

return PasterDetailView
