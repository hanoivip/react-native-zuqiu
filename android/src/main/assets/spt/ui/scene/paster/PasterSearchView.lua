local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterSearchView = class(unity.base)

function PasterSearchView:ctor()
--------Start_Auto_Generate--------
    self.mainSelectPageGo = self.___ex.mainSelectPageGo
    self.closeBtn = self.___ex.closeBtn
    self.levelGroupSpt = self.___ex.levelGroupSpt
    self.typeGroupSpt = self.___ex.typeGroupSpt
    self.skillSelectBtn = self.___ex.skillSelectBtn
    self.skillEmptyGo = self.___ex.skillEmptyGo
    self.skillIconImg = self.___ex.skillIconImg
    self.resetBtn = self.___ex.resetBtn
    self.confirmBtn = self.___ex.confirmBtn
    self.skillSelectPageGo = self.___ex.skillSelectPageGo
    self.skillCloseBtn = self.___ex.skillCloseBtn
    self.skillGroupSpt = self.___ex.skillGroupSpt
    self.skillIconImg = self.___ex.skillIconImg
    self.nameTxt = self.___ex.nameTxt
    self.skillResetBtn = self.___ex.skillResetBtn
    self.skillConfirmBtn = self.___ex.skillConfirmBtn
--------End_Auto_Generate----------
end

function PasterSearchView:start()
    self.resetBtn:regOnButtonClick(function()
        self:OnResetClick()
    end)

    self.confirmBtn:regOnButtonClick(function()
        self:OnConfirmClick()
    end)

    self.skillSelectBtn:regOnButtonClick(function()
        self:OnSkillSelectClick()
    end)

    self.skillResetBtn:regOnButtonClick(function()
        self:OnSkillResetClick()
    end)

    self.skillConfirmBtn:regOnButtonClick(function()
        self:OnSkillConfirmClick()
    end)

    self.closeBtn:regOnButtonClick(function()
        self:RevertTags()
        self:Close()
    end)

    self.skillCloseBtn:regOnButtonClick(function()
        self:ShowSkillPage(false)
    end)

    -- 是否满级选择
    self.typeGroupSpt:CanMultipleSelect(false)
    for tag, v in pairs(self.levelGroupSpt.menu) do
        self.levelGroupSpt:BindMenuItem(tag, function()
        end)
    end

    -- 贴纸类型选择
    self.typeGroupSpt:CanMultipleSelect(true)
    for tag, v in pairs(self.typeGroupSpt.menu) do
        self.typeGroupSpt:BindMenuItem(tag, function()
        end)
    end
end

function PasterSearchView:InitView(pasterQueueModel)
    self.pasterQueueModel = pasterQueueModel
    self:InitSkillPage()
    self:ShowSkillPage(false)

    local pasterTypeTags, levelTag, skillTag = self.pasterQueueModel:GetPasterSearchList()
    self:CacheTags(pasterTypeTags, levelTag, skillTag)
    self:RefreshSelectSkill(skillTag)

    if pasterTypeTags then
        self.typeGroupSpt:SetMultipleDefaultSelectTags(pasterTypeTags)
    end

    if levelTag then
        self.levelGroupSpt:SetSingleDefaultSelectTag(levelTag)
    end
end

-- 重置所有
function PasterSearchView:OnResetClick()
    self.typeGroupSpt:ClearSelectTags()
    self.levelGroupSpt:ClearSelectTags()
    self.skillTag = nil
    self.pasterQueueModel:SetPasterSearchList(nil, nil, nil)
    EventSystem.SendEvent("PasterSearch_OnSearch")
    self:Close()
end

-- 确认
function PasterSearchView:OnConfirmClick()
    local levelTag = self.levelGroupSpt:GetSingleSelectTag()
    local pasterTypeTags = self.typeGroupSpt:GetMultipleSelectTags()
    local skillTag = self:GetSkillTag()
    self.pasterQueueModel:SetPasterSearchList(pasterTypeTags, levelTag, skillTag)
    EventSystem.SendEvent("PasterSearch_OnSearch")
    self:Close()
end

-- 右边技能选择按钮
function PasterSearchView:OnSkillSelectClick()
    self:ShowSkillPage(true)
end

-- 技能重置
function PasterSearchView:OnSkillResetClick()
    self.skillGroupSpt:ClearSelectTags()
    self:RefreshSelectSkill()
    self:ShowSkillPage(false)
end

-- 技能确认
function PasterSearchView:OnSkillConfirmClick()
    local skillTag = self:GetSkillTag()
    self:RefreshSelectSkill(skillTag)
    self:ShowSkillPage(false)
end

function PasterSearchView:RefreshSelectSkill(skillTag)
    if skillTag then
        local picIndex = self.pasterQueueModel:GetSkillPicIndex(skillTag)
        local skillIndex = self.pasterQueueModel:GetSkillIndexBySkillTag(skillTag)
        self.skillIconImg.overrideSprite = AssetFinder.GetSkillIcon(picIndex)
        self.skillGroupSpt:SetSingleDefaultSelectTag(skillIndex)
    end
    GameObjectHelper.FastSetActive(self.skillEmptyGo, not tobool(skillTag))
    GameObjectHelper.FastSetActive(self.skillIconImg.gameObject, tobool(skillTag))
end

function PasterSearchView:Close()
    self.closeDialog()
end

function PasterSearchView:InitSkillPage()
    local skillList = self.pasterQueueModel:GetSkillList()
    self.skillGroupSpt:CreateMenuItems(skillList,
            function(spt, value, index) spt:InitView(value) end,
            function(value, index) end)
    self.skillGroupSpt:CanMultipleSelect(false)
end

function PasterSearchView:ShowSkillPage(isShow)
    GameObjectHelper.FastSetActive(self.mainSelectPageGo, not isShow)
    GameObjectHelper.FastSetActive(self.skillSelectPageGo, isShow)
    GameObjectHelper.FastSetActive(self.closeBtn.gameObject, not isShow)
end

function PasterSearchView:GetSkillTag()
    local skillIndex = self.skillGroupSpt:GetSingleSelectTag()
    if skillIndex then
        local skillList = self.pasterQueueModel:GetSkillList()
        local skillData = skillList[skillIndex]
        return skillData.skillID
    end
end

function PasterSearchView:CacheTags(pasterTypeTags, levelTag, skillTag)
    self.cachePasterTypeTags = clone(pasterTypeTags)
    self.cacheLevelTag = levelTag
    self.cacheSkillTag = skillTag
end

function PasterSearchView:RevertTags()
    self.pasterQueueModel:SetPasterSearchList(self.cachePasterTypeTags, self.cacheLevelTag, self.cacheSkillTag)
end

function PasterSearchView:EnterScene()
end

function PasterSearchView:ExitScene()
end

return PasterSearchView
