local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color

local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local ArenaGrade = require("data.ArenaGrade")
local ArenaRankItemView = class(unity.base)

function ArenaRankItemView:ctor()
    -- 排名
    self.rankNum = self.___ex.rankNum
    -- logo
    self.teamLogo = self.___ex.teamLogo
    -- 队伍名称
    self.teamName = self.___ex.teamName
    -- 背景图
    self.bgColor = self.___ex.bgColor
    -- 前三名排行组
    self.rankGroup = self.___ex.rankGroup
    self.teamStage = self.___ex.teamStage
    self.teamStageLogo = self.___ex.teamStageLogo
    self.btnViewDetail = self.___ex.btnViewDetail
    -- 索引
    self.index = nil
    -- 排行数据
    self.rankData = nil
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function ArenaRankItemView:InitView(rankData, index)
    self.rankData = rankData
    self.index = index
    self:InitTeamLogo()
    self:BuildPage()
end

function ArenaRankItemView:start()
    self.btnViewDetail:regOnButtonClick(function()
        if self.onViewDetail then
            self.onViewDetail()
        end
    end)
end

function ArenaRankItemView:BuildPage()
    local rankNum = self.rankData.rank
    self.teamName.text = self.rankData.name
    if self.playerInfoModel:GetID() == self.rankData.pid then
        self.teamName.color = Color(0.98, 0.92, 0.275, 1)
    else
        self.teamName.color = Color.white
    end
    self.bgColor.gameObject:SetActive(self.index % 2 == 0)

    for i = 1, 3 do
        if rankNum <= 3 then
            GameObjectHelper.FastSetActive(self.rankGroup["num" .. i], i == rankNum)
            self.rankNum.text = ""
        else
            GameObjectHelper.FastSetActive(self.rankGroup["num" .. i], false)
            self.rankNum.text = tostring(rankNum)
        end
    end

    local stage, star, openStar, minStage = self.arenaMainModel:GetAreaState(self.rankData.score)
    for i = 1, 6 do
        GameObjectHelper.FastSetActive(self.teamStageLogo["Img" .. i], i == stage)
    end
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
    self.teamStage.text = "—" .. self.arenaMainModel:GetGradeName(stage) .. minStageDesc .. "—"

end

function ArenaRankItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function ArenaRankItemView:GetTeamLogo()
    return self.teamLogo
end

return ArenaRankItemView
