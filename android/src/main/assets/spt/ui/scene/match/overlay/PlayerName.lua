local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Sprite = UnityEngine.Sprite
local Canvas = UnityEngine.Canvas
local Object = UnityEngine.Object

local AssetFinder = require("ui.common.AssetFinder")
local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchInfoModel = require("ui.models.MatchInfoModel")

local PlayerName = class(unity.base)

function PlayerName:ctor()
    self.nameTxt = self.___ex.name
    self.number = self.___ex.number
    self.skillGroup = self.___ex.skillGroup
    self.skillBox = self.___ex.skillBox
    self.homeTeamLogoBox = self.___ex.homeTeamLogoBox
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamLogoBox = self.___ex.awayTeamLogoBox
    self.awayTeamLogo = self.___ex.awayTeamLogo
end

function PlayerName:start()
    local matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamLogo, playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.awayTeamLogo, opponentTeamData.logo)
end

function PlayerName:Init(athleteData, isPlayer, needShowSkills)
    self.gameObject:SetActive(true)
    self.nameTxt.text = athleteData.name
    self.number.text = tostring(athleteData.number)

    if isPlayer then
        self.homeTeamLogoBox:SetActive(true)
        self.awayTeamLogoBox:SetActive(false)
    else
        self.homeTeamLogoBox:SetActive(false)
        self.awayTeamLogoBox:SetActive(true)
    end

    if not needShowSkills then
        self.skillBox:SetActive(false)
    elseif athleteData.skills then
        local hasSkillShow = false
        local i = 1
        for skillId, v in pairs(athleteData.skills) do
            if not string.find(skillId, "M") then
                local skillItemView = self.skillGroup["view" .. i]
                local skillIcon = AssetFinder.GetMatchSkillIcon(skillId)
                if skillIcon == nil or skillIcon == clr.null then
                    skillItemView:SetActive(false)
                else
                    skillItemView:InitView(skillId, skillIcon, athleteData.markedSkillSet[skillId])
                    hasSkillShow = true
                end
                i = i + 1
                if i > 4 then
                    break
                end
            end
        end
        if hasSkillShow == false then
            self.skillBox:SetActive(false)
        else
            self.skillBox:SetActive(true)
            while i <= 4 do
                local skillItemView = self.skillGroup["view" .. i]
                skillItemView:SetActive(false)
                i = i + 1
            end
        end
    end
end

return PlayerName
