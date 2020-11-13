local CompeteChampionWallFilterModel = {}

-- 大耳朵杯
CompeteChampionWallFilterModel.BigEar = {}

-- 筛选的类别
CompeteChampionWallFilterModel.BigEar.FilterType = {
    Group = "Group",
}

-- 类别在界面中排序
CompeteChampionWallFilterModel.BigEar.FilterTypeSiblingIndex = {
    Group = 1,
}

-- 不需要筛选title
CompeteChampionWallFilterModel.BigEar.HasTitle = false

-- 每个类别中的配置
-- 根据id排序
-- 根据name读语言表显示
-- filterVar为表格配置，或者自定义值，用于筛选时比较
-- CompeteChampionWallModel中根据赛季动态添加
CompeteChampionWallFilterModel.BigEar.Group = {
    -- { id = 1, name = "assist_coachinfo_star_lvl_1", filterVar = 1 },
}

-- 小耳朵杯
CompeteChampionWallFilterModel.SmallEar = {}

-- 筛选的类别
CompeteChampionWallFilterModel.SmallEar.FilterType = {
    Group = "Group",
}

-- 类别在界面中排序
CompeteChampionWallFilterModel.SmallEar.FilterTypeSiblingIndex = {
    Group = 1,
}

-- 不需要筛选title
CompeteChampionWallFilterModel.SmallEar.HasTitle = false

CompeteChampionWallFilterModel.SmallEar.Group = {}

return CompeteChampionWallFilterModel
