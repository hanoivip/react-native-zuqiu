local FeatureSkillEnum = {}

-- 战力计算类型（1：草皮，2：天气，3主客场，4首发, 5，当前全算上）
FeatureSkillEnum.CategoryType = 
{
    Grass = 1,
    Weather = 2,
    HomeAndAway = 3,
    Starters = 4,
    CurrentAll = 5
}

-- 天赋技能提升的类别（1为技能，2为属性，3为属性百分比，4为技能栏位，5为自身携带全技能不包含贴纸，6为全技能包含贴纸）
FeatureSkillEnum.PlayerTalentType = 
{
    Skill = 1,
    Attr = 2,
    AttrPercent = 3,
    SkillSlot = 4,
    SkillWithOutPaster = 5,
    SkillAll = 6,
}

-- 与PlayerTalentSkill 表中对应
FeatureSkillEnum.GrassCategoryType = 
{
    {["key"] = "Common", ["label"] = "grass_normal"},
    {["key"] = "Mixed", ["label"] = "grass_mixed"},
    {["key"] = "NatureShort", ["label"] = "grass_natureShort"},
    {["key"] = "NatureLong", ["label"] = "grass_natureLong"},
    {["key"] = "ArtificialShort", ["label"] = "grass_artificialShort"},
    {["key"] = "ArtificialLong", ["label"] = "grass_artificialLong"},
}

FeatureSkillEnum.WeatherCategoryType = 
{
    {["key"] = "SunShine", ["label"] = "weather_sunShine"},
    {["key"] = "Rain", ["label"] = "weather_rain"},
    {["key"] = "Snow", ["label"] = "weather_snow"},
    {["key"] = "Wind", ["label"] = "weather_wind"},
    {["key"] = "Fog", ["label"] = "weather_fog"},
    {["key"] = "Sand", ["label"] = "weather_sand"},
    {["key"] = "Heat", ["label"] = "weather_heat"},
}

FeatureSkillEnum.TeamCategoryType = 
{
    {["key"] = "home", ["label"] = "match_homeCourt"},
    {["key"] = "away", ["label"] = "match_awayCourt"},
}

-- 根据PlayerTalentSkill表中 conditionType
FeatureSkillEnum.DefaultTeam = "home"
FeatureSkillEnum.DefaultStarters = "all"

--#region
-- 对应PlayerTalentSkill 中qualityPicIndex
FeatureSkillEnum.QualitySortType = 
{
    {["key"] = nil, ["label"] = "feature_itemList_quality"},
    {["key"] = 4, ["label"] = "feature_quality1"},
    {["key"] = 5, ["label"] = "feature_quality2"},
    {["key"] = 6, ["label"] = "feature_quality3"},
    {["key"] = 7, ["label"] = "feature_quality4"},
}

-- 对应PlayerTalentSkill 中qualityPicIndex
FeatureSkillEnum.KindSortType = 
{
    {["key"] = nil, ["label"] = "feature_itemList_kind"},
    {["key"] = "home", ["label"] = "match_homeCourt"},
    {["key"] = "away", ["label"] = "match_awayCourt"},
    {["key"] = "all", ["label"] = "whole_match"},
    {["key"] = "Common", ["label"] = "grass_normal"},
    {["key"] = "Mixed", ["label"] = "grass_mixed"},
    {["key"] = "NatureShort", ["label"] = "grass_natureShort"},
    {["key"] = "NatureLong", ["label"] = "grass_natureLong"},
    {["key"] = "ArtificialShort", ["label"] = "grass_artificialShort"},
    {["key"] = "ArtificialLong", ["label"] = "grass_artificialLong"},
    {["key"] = "SunShine", ["label"] = "weather_sunShine"},
    {["key"] = "Rain", ["label"] = "weather_rain"},
    {["key"] = "Snow", ["label"] = "weather_snow"},
    {["key"] = "Wind", ["label"] = "weather_wind"},
    {["key"] = "Fog", ["label"] = "weather_fog"},
    {["key"] = "Sand", ["label"] = "weather_sand"},
    {["key"] = "Heat", ["label"] = "weather_heat"},
}

-- 对应PlayerTalentType
FeatureSkillEnum.CategorySortType = 
{
    {["key"] = nil, ["label"] = "feature_itemList_type"},
    {["key"] = {FeatureSkillEnum.PlayerTalentType.Attr}, ["label"] = "feature_category_sort1"},
    {["key"] = {FeatureSkillEnum.PlayerTalentType.AttrPercent}, ["label"] = "feature_category_sort2"},
    {["key"] = {FeatureSkillEnum.PlayerTalentType.Skill, FeatureSkillEnum.PlayerTalentType.SkillSlot}, ["label"] = "feature_category_sort3"},
    {["key"] = {FeatureSkillEnum.PlayerTalentType.SkillWithOutPaster, FeatureSkillEnum.PlayerTalentType.SkillAll}, ["label"] = "feature_category_sort4"},
}

--品质：入门级/普通级/大师级/专家级
--类型：烈日/阴雨/冰雪/狂风/阴霾/沙尘/酷暑/普通草/混合草/天然短草/天然长草/人工短草/人工长草
--类别：属性/属性百分比/技能/全技能
FeatureSkillEnum.SortType = 
{
    Quality = 1,
    GrassAndWeather = 2,
    Category = 3
}
--#endregion

return FeatureSkillEnum
