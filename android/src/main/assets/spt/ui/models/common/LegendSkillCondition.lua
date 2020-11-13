local LegendSkillCondition = {}

-- 传奇之路专属技能增益效果
--1:全属性提升/2.个别属性提升/3.某技能栏位等级提升/4.自身不包含贴纸技能提升/5.全技能等级提升/6.全属性百分比提升/7.单属性百分比提升
LegendSkillCondition.LegendSkillImproveType = {
    Attr_All = 1, -- 全属性增加
    Attr_Single = 2, -- 个别属性提升
    Skill_Single = 3, -- 某技能栏位等级提升
    Skill_Base = 4, -- 自身不包含贴纸技能提升
    Skill_All = 5, -- 全技能等级提升(包含贴纸)
    AttrPercent_All = 6, -- 全属性百分比提升
    AttrPercent_Single = 7, -- 单属性百分比提升
}

--球员自身属性加成的条件（
--all:所有首发+替补，
--nation:所有首发+替补球员对应国籍，
--player：所有首发+替补对应的指定球员，
--start:所有首发，
--startnation:所有首发国籍，
--startposition:所有首发位置，
--startplayer所有首发指定球员，
--substitute:所有替补，
--substitutenation:替补国籍，
--substituteplayer替补指定球员）
LegendSkillCondition.PlayerImproveCondition = {
    All = "all",
    Nation = "nation",
    Player_All = "player",
    Starter_All = "start",
    Starter_Nation = "startnation",
    Starter_Pos = "startposition",
    Starter_Player = "startplayer",
    Rep_All = "substitute",
    Rep_Nation = "substitutenation",
    Rep_Player = "substituteplayer"
}

--球员给团队提供的属性加成的条件（
--start:所有先发，
--startnation:所有首发国籍，
--startposition:所有首发位置，
--startplayer所有首发指定球员）
LegendSkillCondition.TeamImproveCondition = {
    Starter_All = "start",
    Starter_Nation = "startnation",
    Starter_Pos = "startposition",
    Starter_Player = "startplayer",
}

return LegendSkillCondition