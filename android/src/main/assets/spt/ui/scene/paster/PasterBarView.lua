local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local Skills = require("data.Skills")
local PasterBarView = class(unity.base)

function PasterBarView:ctor()
    self.pasterArea = self.___ex.pasterArea
    self.appendArea = self.___ex.appendArea
    self.pasterView = self.___ex.pasterView
    self.skillIcon = self.___ex.skillIcon
    self.skillName = self.___ex.skillName
    self.skillLvl  = self.___ex.skillLvl
    self.skillLvlObj = self.___ex.skillLvlObj
    self.btnUse = self.___ex.btnUse
    self.btnAppend = self.___ex.btnAppend
    self.btnSkill = self.___ex.btnSkill
    self.useButton = self.___ex.useButton
    self.useText = self.___ex.useText
    self.isHave = self.___ex.isHave
    self.useState = self.___ex.useState
    self.isInvalid = self.___ex.isInvalid
    self.pasterView.clickCardPaster = function(index, cardPasterModel) self:OnPasterClick(index, cardPasterModel) end
    --助阵贴纸显示
    self.bSupporter = false
end

function PasterBarView:start()
    self.btnAppend:regOnButtonClick(function()
        self:OnAppendClick()
    end)
    self.btnUse:regOnButtonClick(function()
        self:OnUseClick()
    end)
    self.btnSkill:regOnButtonClick(function()
        self:OnSkillClick()
    end)
end



function PasterBarView:OnAppendClick()
    if self.clickAppend then 
        self.clickAppend()
    end
end

function PasterBarView:OnPasterClick(index, cardPasterModel)
    if self.clickCardPaster then 
        self.clickCardPaster(cardPasterModel)
    end
end

function PasterBarView:OnUseClick()
    if self.clickUse then 
        self.clickUse(self.cardAppendPasterModel)
    end
end

function PasterBarView:OnSkillClick()
    if self.clickSkill then 
        self.clickSkill(self.index, self.cardAppendPasterModel)
    end
end

function PasterBarView:InitView(cardAppendPasterModel, pasterRes)
    self.cardAppendPasterModel = cardAppendPasterModel
    local isAppend = cardAppendPasterModel.isAppend
    if not isAppend then 
        self.pasterView:InitView(cardAppendPasterModel, nil, pasterRes)
        local pasterType = cardAppendPasterModel:GetPasterType()
        local isShowButton = false
        local descText = ""
        local isShowSkill = false
        local isShowSkillLvl = false
        local sid = nil

        if cardAppendPasterModel:IsWeekPaster() then
            isShowButton = false
            descText = lang.trans("paster_apply_content2")
            isShowSkill = true
            isShowSkillLvl = true
            sid = cardAppendPasterModel:GetPasterSkill()
        elseif cardAppendPasterModel:IsMonthPaster() then
            local skillValid = cardAppendPasterModel:GetSkillValid()
            local isSkillConflict = cardAppendPasterModel:IsSkillConflict()
            if skillValid == 1 then
                if not isSkillConflict then
                    descText = lang.trans("paster_apply_content1")
                else
                    descText = lang.trans("paster_apply_content5")
                end
            else
                isShowButton = true
            end
            isShowSkill = true
            isShowSkillLvl = true
            sid = cardAppendPasterModel:GetPasterSkill()
        elseif cardAppendPasterModel:IsHonorPaster() then
            descText = lang.trans("paster_apply_content3")
        elseif cardAppendPasterModel:IsAnnualPaster() then
            descText = lang.trans("paster_apply_content3")
        elseif cardAppendPasterModel:IsCompetePaster() then
            descText = lang.trans("paster_apply_content4")
            isShowSkill = true
            isShowSkillLvl = false
            sid = cardAppendPasterModel:GetCompetePasterSkill()
        end

        self:UpdateSkillInfo(sid, isShowSkill, isShowSkillLvl)

        GameObjectHelper.FastSetActive(self.useButton.gameObject, isShowButton and not self.bSupporter and not cardAppendPasterModel:GetIsPasterPokedex())
        self.useText.text = cardAppendPasterModel:GetIsPasterPokedex() and "" or descText
    end
    GameObjectHelper.FastSetActive(self.pasterArea.gameObject, not isAppend)
    GameObjectHelper.FastSetActive(self.appendArea.gameObject, isAppend)
    local isHave = not cardAppendPasterModel.isAppend and cardAppendPasterModel:GetIsHave()
    GameObjectHelper.FastSetActive(self.isHave, isHave)
    self.useState.text = isHave and lang.trans("have_own_player1") or ""
end

function PasterBarView:UpdateSkillInfo(sid, isShowSkill, isShowSkillLvl)
    GameObjectHelper.FastSetActive(self.btnSkill.gameObject, isShowSkill)
    GameObjectHelper.FastSetActive(self.skillLvlObj, isShowSkillLvl)
    if isShowSkill then
        GameObjectHelper.FastSetActive(self.isInvalid.gameObject, self.cardAppendPasterModel:IsSkillConflict())
        local skillTable = Skills[tostring(sid)]
        if skillTable then
            self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(skillTable.picIndex)
            self.skillName.text = tostring(skillTable.skillName)
            self:UpdateSkillLevelUp()
        end
    end
end

function PasterBarView:UpdateSkillLevelUp(cardAppendPasterModel)
    if cardAppendPasterModel then
        self.cardAppendPasterModel = cardAppendPasterModel
    end
    local lvl = self.cardAppendPasterModel:GetPasterSkillLvl()
    if not self.bSupporter then
        lvl = lvl + self.cardAppendPasterModel:GetLevelEx()
    end
    self.skillLvl.text = "Lv." .. lvl
end

function PasterBarView:UpdateItemIndex(index)
    self.index = index
end

return PasterBarView
