local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SkillSelectItemView = class(unity.base)
local ShowMode = {
    SelectBox = 1, -- 选择框
    Skill = 2, -- 技能列表
    SelectSkill = 3, -- 已选择
}
function SkillSelectItemView:ctor()
    self.selectImg = self.___ex.selectImg
    self.skillObj = self.___ex.skillObj
    self.skillIcon = self.___ex.skillIcon
    self.skillName = self.___ex.skillName
    self.selectBtn = self.___ex.selectBtn
    self.skillBtn = self.___ex.skillBtn
    self.selectSign = self.___ex.selectSign
    self.selectBoxObj = self.___ex.selectBoxObj
end

function SkillSelectItemView:start()
    EventSystem.AddEvent("SkillItemList.UpdateState", self, self.UpdateState)
    EventSystem.AddEvent("SkillItemList.CancelSelectSkill", self, self.CancelSelectSkill)
    if self.showMode then
        self:UpdateState(true)
    end
end

function SkillSelectItemView:InitView(mainView, showMode, skillData)
    self.mainView = mainView
    self.showMode = showMode
    self.skillData = skillData
    self:UpdateState()
end

function SkillSelectItemView:UpdateState(isInit)
    if self.showMode == ShowMode.Skill then
        if isInit then
            self.skillData.isSelect = false
        end
        for k, v in pairs(self.mainView.selectSkill) do
            if v == self.skillData.skillID then
                self.skillData.isSelect = true
            end
        end
    end
    -- 选择框Btn
    GameObjectHelper.FastSetActive(self.selectBtn.gameObject, self.showMode ~= ShowMode.Skill)
    -- 选择框    
    GameObjectHelper.FastSetActive(self.selectBoxObj, self.showMode == ShowMode.Skill)
    GameObjectHelper.FastSetActive(self.selectImg, self.showMode == ShowMode.SelectBox)
    -- 技能选择
    GameObjectHelper.FastSetActive(self.skillObj, self.showMode == ShowMode.Skill)
    GameObjectHelper.FastSetActive(self.skillName.gameObject, self.showMode ~= ShowMode.SelectBox)
    GameObjectHelper.FastSetActive(self.skillIcon.gameObject, self.showMode ~= ShowMode.SelectBox)
    if self.showMode ~= ShowMode.SelectBox then
        self.skillName.text = self.skillData.name
        self.skillIcon.overrideSprite = AssetFinder.GetSkillIcon(self.skillData.picIndex)
        GameObjectHelper.FastSetActive(self.selectSign, self.skillData.isSelect)
        self.skillBtn:regOnButtonClick(function() self:OnSkillClick() end)
    end
end

function SkillSelectItemView:CancelSelectSkill()
    if self.showMode == ShowMode.Skill then
        self.skillData.isSelect = false
        GameObjectHelper.FastSetActive(self.selectSign, false)
    end
end

function SkillSelectItemView:OnSkillClick()
    if not self.skillData.isSelect and self.mainView.skillCounter >= self.mainView.SkillCount then
        return
    end
    if self.skillData.isSelect then
        self.mainView.skillCounter = self.mainView.skillCounter - 1
        for index, sid in ipairs(self.mainView.skillViewMap) do
            if self.skillData.skillID == sid then
                self.mainView.skillViewMap[index] = ""
            end
        end 
    else
        self.mainView.skillCounter = self.mainView.skillCounter + 1
        for i = 1, self.mainView.SkillCount do
            if self.mainView.skillViewMap[i] == "" then
                self.mainView.skillViewMap[i] = self.skillData.skillID
                break
            end
        end
    end
    self.skillData.isSelect = not self.skillData.isSelect
    GameObjectHelper.FastSetActive(self.selectSign, self.skillData.isSelect)
    EventSystem.SendEvent("PlayerSearchView.UpdateSkillSelectCount")
    EventSystem.SendEvent("MedalSearchView.UpdateSelectSkill", self.skillData)
end

function SkillSelectItemView:onDestroy()
    EventSystem.RemoveEvent("SkillItemList.UpdateState", self, self.UpdateState)
    EventSystem.RemoveEvent("SkillItemList.CancelSelectSkill", self, self.CancelSelectSkill)
end

return SkillSelectItemView