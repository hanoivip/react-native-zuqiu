local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

local Num2LetterPos = require("data.Num2LetterPos")
local Letter2NumPos = require("data.Letter2NumPos")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local BlockDebuffSkills = require("ui.scene.match.overlay.BlockDebuffSkills")
local PlayerTalentSkill = require("data.PlayerTalentSkill")

local Green = Color(144.0 / 255, 243.0 / 255, 38.0 / 255)
local Red = Color(1, 42.0 / 255, 78.0 / 255)

local TalentItem = class(unity.base)

function TalentItem:ctor()
    self.positionImage = self.___ex.positionImage
    self.playerName = self.___ex.playerName
    self.positionText = self.___ex.positionText
    self.buffListPanel = self.___ex.buffListPanel
    self.buffListPanelTransform = self.buffListPanel.transform
    self.buffListPanelGetChild = self.buffListPanel.transform.GetChild
    self.buffList = nil
    self.value = 0
end

function TalentItem:init(athleteData)
    self.athleteId = athleteData.id
    self.onfieldId = athleteData.onfieldId

    local athlete = ___matchUI:getAthlete(athleteData.id)
    self.playerName.text = athlete.name
    local favPos = Num2LetterPos[tostring(athlete.role)]
    self.positionText.text = Letter2NumPos[favPos].displayPos

    self.buffList = {}
    self.value = 0

    -- local count = self.buffListPanelTransform.childCount
    -- for i = 0, count - 1 do
    --     GameObjectHelper.FastSetActive(self.buffListPanelGetChild(i).gameObject, false)
    -- end

    local posNum = tonumber(athlete.role)
    local posColorFlagIndex = 1
    if posNum >= 1 and posNum <= 5 then
        posColorFlagIndex = 1
    elseif posNum >= 6 and posNum <= 20 then
        posColorFlagIndex = 2
    elseif posNum >= 21 and posNum <= 25 then
        posColorFlagIndex = 3
    elseif posNum == 26 then
        posColorFlagIndex = 4
    end
    self.positionImage.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/Images/Common/PosColorFlag" .. posColorFlagIndex .. ".png")
    self:buildTalentSkillList(athleteData.guide)
end

function TalentItem:buildTalentSkillList(talentSkills)
    if not talentSkills then
        return
    end

    for i, talentSkill in ipairs(talentSkills) do
        local talentSkillData = PlayerTalentSkill[talentSkill]
        local talentSkillItem = res.Instantiate("Assets/CapstonesRes/Game/UI/Match/Overlay/TalentSkillItem.prefab")
        local talentSkillItemTransform = talentSkillItem.transform
        talentSkillItemTransform:SetParent(self.buffListPanelTransform)
        talentSkillItemTransform.localScale = Vector3(1, 1, 1)
        talentSkillItemTransform.localPosition = Vector3(0, 0, 0)
        res.GetLuaScript(talentSkillItem):init(talentSkillData)
    end
end

return TalentItem
