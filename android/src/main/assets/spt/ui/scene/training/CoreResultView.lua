local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local UISoundManager = require("ui.control.manager.UISoundManager")
local Skills = require("data.Skills")
local AssetFinder = require("ui.common.AssetFinder")

local CoreResultView = class(unity.base)

function CoreResultView:ctor()
    self.fail = self.___ex.fail
    self.complete = self.___ex.complete
    self.perfect = self.___ex.perfect
    self.cardParent = self.___ex.cardParent
    self.clickArea = self.___ex.clickArea
    self.nameTxt = self.___ex.nameTxt
    self.effectComplete = self.___ex.effectComplete
    self.effectFail = self.___ex.effectFail
    self.skill1 = self.___ex.skill1
    self.skill2 = self.___ex.skill2
    self.skillIcon1 = self.___ex.skillIcon1
    self.skillName1 = self.___ex.skillName1
    self.skillBeforeLevel1 = self.___ex.skillBeforeLevel1
    self.skillAfterLevel1 = self.___ex.skillAfterLevel1
    self.skillIcon2 = self.___ex.skillIcon2
    self.skillName2 = self.___ex.skillName2
    self.skillBeforeLevel2 = self.___ex.skillBeforeLevel2
    self.skillAfterLevel2 = self.___ex.skillAfterLevel2
    self.skillArea = self.___ex.skillArea
    self.skill2Area = self.___ex.skill2Area
    self.boardAreaRect = self.___ex.boardAreaRect
end

function CoreResultView:start()
    self.clickArea:regOnButtonClick(function()
        if self.clickPanel then
            self.clickPanel()
        end
    end)
end

function CoreResultView:SetCard(cardTrans)
    cardTrans:SetParent(self.cardParent.transform, false)
end

function CoreResultView:InitView(skillReward, score, cardModel)
    UISoundManager.play('Training/trainingEnd', 1)
    self.fail:SetActive(false)
    self.complete:SetActive(false)
    self.perfect:SetActive(false)

    if self.nameTxt then
        self.nameTxt.text = tostring(cardModel:GetName())
    end

    if score == "fail" then
        self.fail:SetActive(true)
        self.skillArea:SetActive(false)
        if self.effectFail then
            self.effectFail:SetActive(true)
        end
    else
        if score == "success" then
            self.complete:SetActive(true)
        elseif score == "bigSuccess" then
            self.perfect:SetActive(true)
        end
        self.skillArea:SetActive(true)
        local skillRewardCount = #skillReward
        if skillRewardCount >= 1 then
            self.skill1.name.text = Skills[skillReward[1].sid].skillName
            self.skill1.icon.overrideSprite = AssetFinder.GetSkillIcon(Skills[skillReward[1].sid].picIndex)
            self.skill1.beforeLevel.text = "Lv" .. tostring(skillReward[1].before)
            self.skill1.afterLevel.text = "Lv" .. tostring(skillReward[1].after)
            if skillRewardCount == 2 then
                self.skill2Area:SetActive(true)
                self.skillArea.transform.sizeDelta = Vector2(self.skillArea.transform.sizeDelta.x, 320)
                self.boardAreaRect.localPosition = Vector3(self.boardAreaRect.x, 40, self.boardAreaRect.z)
                self.skill2.name.text = Skills[skillReward[2].sid].skillName
                self.skill2.icon.overrideSprite = AssetFinder.GetSkillIcon(Skills[skillReward[2].sid].picIndex)
                self.skill2.beforeLevel.text = "Lv" .. tostring(skillReward[2].before)
                self.skill2.afterLevel.text = "Lv" .. tostring(skillReward[2].after)
            else
                self.skill2Area:SetActive(false)
                self.skillArea.transform.sizeDelta = Vector2(self.skillArea.transform.sizeDelta.x, 220)
                self.boardAreaRect.localPosition = Vector3(self.boardAreaRect.x, 0, self.boardAreaRect.z)
            end
        end
        if self.effectComplete then
            self.effectComplete:SetActive(true)
        end
    end
end

return CoreResultView
