local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local HonorBarView = class(unity.base)

function HonorBarView:ctor()
    self.seasonPass = self.___ex.seasonPass
    self.currentgradeText = self.___ex.currentgradeText
end

function HonorBarView:InitView(arenaModel, arenaHonorModel, arenaType)
    local score = arenaModel:GetAreaScore(arenaType)

    self.seasonPass.text = lang.trans("season_pass", arenaModel:GetAreaSeasons(arenaType))
    local stage, star, openStar, minStage = arenaModel:GetAreaState(score)
    local minStageNum, minStageDesc = "", ""
    if stage then
        local minStagePos = ArenaHelper.GetMinStagePos[tostring(stage)]
        if minStagePos then
            if stage < ArenaHelper.StageType.StoryStage then 
                minStageDesc = lang.transstr("reduce_num", minStage) 
            else
                minStageDesc = lang.transstr("star_num", minStage) 
            end
        end
    end
    self.currentgradeText.text = "(" .. arenaModel:GetGradeName(stage) .. minStageDesc .. ")"
end

return HonorBarView