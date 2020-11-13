local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local ArenaHonorView = class(unity.base)

function ArenaHonorView:ctor()
    self.mainTxt = self.___ex.mainTxt
    self.stageIcon = self.___ex.stageIcon
    self.maxStarMap = self.___ex.maxStarMap
    self.maxgradeText = self.___ex.maxgradeText
    self.iconGo = self.___ex.iconGo
end

function ArenaHonorView:InitView(arenaModel, maxScore)
    if arenaModel then
        self:BuildStage(arenaModel, maxScore, self.maxStarMap, self.stageIcon, self.maxgradeText)
    else
        -- 表示没有开启天梯系统
        GameObjectHelper.FastSetActive(self.iconGo, false)
        self.maxgradeText.text = "--"
    end
end

-- 天梯 段位显示
function ArenaHonorView:BuildStage(arenaModel, score, starMap, stageIcon, gradeText)
    local stage, star, openStar, minStage = arenaModel:GetAreaState(score)
    for k, v in pairs(starMap) do
        local index = tonumber(string.sub(k, 2))
        local starData = ArenaHelper.GetStarPos4Friend[tostring(openStar)]
        local isOpen = starData and tobool(index <= openStar)
        if isOpen then
            local pos = starData[index]
            v.gameObject.transform.anchoredPosition = Vector2(pos.x, pos.y)
            
            -- 显示灰色星星
            local isShow = tobool(index <= star)
            if not isShow then
                v.interactable = isShow
            end
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

return ArenaHonorView
