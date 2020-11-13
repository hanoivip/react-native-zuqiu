local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local ArenaType = require("ui.scene.arena.ArenaType")
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local HonorPageType = require("ui.scene.arena.honor.HonorPageType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SingleArenaRewardView = class(unity.base)

function SingleArenaRewardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.seasonPass = self.___ex.seasonPass
    self.maxStageIcon = self.___ex.maxStageIcon
    self.maxStarMap = self.___ex.maxStarMap
    self.maxgradeText = self.___ex.maxgradeText
    self.currentstageIcon = self.___ex.currentstageIcon
    self.currentStarMap = self.___ex.currentStarMap
    self.currentgradeText = self.___ex.currentgradeText
    self.arenaName = self.___ex.arenaName
    self.arenaCup = self.___ex.arenaCup
    self.champion = self.___ex.champion
    self:RegScrollViewHandle()
end

function SingleArenaRewardView:GetHonorBarRes()
    if not self.honorBarRes then 
        self.honorBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/HonorBar.prefab")
    end
    return self.honorBarRes
end

function SingleArenaRewardView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local honorBarRes = self:GetHonorBarRes()
        local obj = Object.Instantiate(honorBarRes)
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local barData = scrollSelf.itemDatas[index]
        spt:InitView(barData, self.arenaModel, self.arenaHonorModel)
        spt.clickReward = function(id)
            self:OnClickReward(id) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end)
end

local ArenaTypeEnum = 
{
    [HonorPageType.Silver] = ArenaType.SilverStage, 
    [HonorPageType.Gold] = ArenaType.GoldStage, 
    [HonorPageType.BlackGold] = ArenaType.BlackGoldStage, 
    [HonorPageType.Platina] = ArenaType.PlatinumStage,
    [HonorPageType.Red] = ArenaType.RedGoldStage,
    [HonorPageType.Yellow] = ArenaType.YellowGoldStage,
    [HonorPageType.Blue] = ArenaType.BlueGoldStage 
}
function SingleArenaRewardView:InitView(arenaModel, arenaHonorModel, pageType)
    self.arenaModel = arenaModel
    self.arenaHonorModel = arenaHonorModel
    local listData = arenaHonorModel:GetHonorData(pageType)
    self.scrollView:refresh(listData)

    local arenaType = ArenaTypeEnum[pageType]
    self.seasonPass.text = lang.trans("season_pass", arenaModel:GetAreaSeasons(arenaType))
    self.champion.text = lang.trans("arena_champion_num", arenaModel:GetAreaChampion(arenaType))
    local score = arenaModel:GetAreaScore(arenaType)
    self:BuildStage(arenaModel, score, self.currentStarMap, self.currentstageIcon, self.currentgradeText)
    local maxScore = arenaModel:GetAreaMaxScore(arenaType)
    self:BuildStage(arenaModel, maxScore, self.maxStarMap, self.maxStageIcon, self.maxgradeText)
    self.arenaName.text = "—" .. lang.transstr(arenaType .. "_arena") .. "—"
    local index = ArenaIndexType[arenaType]
    self.arenaCup.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Arena/HonorCup" .. index .. ".png")
    self.arenaCup.transform.anchoredPosition = index < 5 and Vector2(-40, 0) or Vector2(0, 0)
    self.arenaCup:SetNativeSize()
end

function SingleArenaRewardView:BuildStage(arenaModel, score, starMap, stageIcon, gradeText)
    local stage, star, openStar, minStage = arenaModel:GetAreaState(score)
    for k, v in pairs(starMap) do
        local index = tonumber(string.sub(k, 2))
        local starData = ArenaHelper.GetStarPos[tostring(openStar)]
        local isOpen = starData and tobool(index <= openStar)
        if isOpen then
            local pos = starData[index]
            v.gameObject.transform.anchoredPosition = Vector2(pos.x, pos.y)
            local isShow = tobool(index <= star)
            v.interactable = isShow
        end
        GameObjectHelper.FastSetActive(v.gameObject, isOpen)
    end
    local minStageNum, minStageDesc = "", ""
    if stage then
        stageIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Mid_Team" .. stage .. ".png")
        stageIcon:SetNativeSize()
        local minStagePos = ArenaHelper.GetMinStagePos[tostring(stage)]
        if minStagePos then
            if stage < ArenaHelper.StageType.StoryStage then 
                minStageDesc = lang.transstr("reduce_num", minStage) 
            else
                minStageDesc = lang.transstr("star_num", minStage) 
            end
        end
    end
    gradeText.text = "(" .. arenaModel:GetGradeName(stage) .. minStageDesc .. ")"
end


function SingleArenaRewardView:EnterScene()

end

function SingleArenaRewardView:onDestroy()
    self.honorBarRes = nil
end

function SingleArenaRewardView:OnClickReward(id)
    if self.clickReward then 
        self.clickReward(id)
    end
end

function SingleArenaRewardView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return SingleArenaRewardView
