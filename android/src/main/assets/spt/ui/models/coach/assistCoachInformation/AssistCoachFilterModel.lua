local AssistCoachFilterModel = {}

-- 筛选的类别
AssistCoachFilterModel.FilterType = {
    Quality = "Quality",
    Type = "Type",
    Rarity = "Rarity"
}

-- 类别在界面中排序
AssistCoachFilterModel.FilterTypeSiblingIndex = {
    Quality = 1,
    Type = 2,
    Rarity = 3
}

-- 每个类别中的配置
-- 根据id排序
-- 根据name读语言表显示
-- filterVar为表格配置，或者自定义值，用于筛选时比较
-- Quality、Type等须和上面定义FilterType中字段一致
AssistCoachFilterModel.Quality = {
    { id = 1, name = "star_lvl", filterVar = nil },  -- 星级
    { id = 2, name = "assist_coachinfo_star_lvl_1", filterVar = 1 },
    { id = 3, name = "assist_coachinfo_star_lvl_2", filterVar = 2 },
    { id = 4, name = "assist_coachinfo_star_lvl_3", filterVar = 3 },
    { id = 5, name = "assist_coachinfo_star_lvl_4", filterVar = 4 },
    { id = 6, name = "assist_coachinfo_star_lvl_5", filterVar = 5 },
    { id = 7, name = "assist_coachinfo_star_lvl_6", filterVar = 6 },
    { id = 8, name = "assist_coachinfo_star_lvl_7", filterVar = 7 }
}

AssistCoachFilterModel.Type = {
    { id = 1, name = "type", filterVar = nil },  -- 类别
    { id = 2, name = "assist_coachinfo_type_1", filterVar = 1 },  -- 属性类别
    { id = 3, name = "assist_coachinfo_type_2", filterVar = 2 },  -- 基础数值
    { id = 4, name = "assist_coachinfo_type_3", filterVar = 3 },  -- 属性成长
    { id = 5, name = "assist_coachinfo_type_4", filterVar = 4 },  -- 单技能提升
    { id = 6, name = "assist_coachinfo_type_5", filterVar = 5 }   -- 全技能提升
}

AssistCoachFilterModel.Rarity = {
    { id = 1, name = "rarity", filterVar = nil },  -- 稀有度
    { id = 2, name = "assist_coachinfo_rarity_1", filterVar = 0 },  -- 普通情报
    { id = 3, name = "assist_coachinfo_rarity_2", filterVar = 1 }   -- 特殊情报
}

-- 每个筛选项的样式
AssistCoachFilterModel.Style = {
    Quality = {
        normal = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/Image/AssistantCoachInformation_Filter_Btn_L_Normal.png",
        opened = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/Image/AssistantCoachInformation_Filter_Btn_L_Select.png",
        icon = nil,
        txt_nor = {r = 1, g = 1, b = 1, a = 0.7},
        txt_sel = {r = 0.2, g = 0.2, b = 0.2, a = 1},
        arrow_nor = nil,
        arrow_sel = nil,
        box = nil
    },
    Type = {
        normal = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/Image/AssistantCoachInformation_Filter_Btn_M_Normal.png",
        opened = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/Image/AssistantCoachInformation_Filter_Btn_M_Select.png",
        icon = nil,
        txt_nor = {r = 1, g = 1, b = 1, a = 0.7},
        txt_sel = {r = 0.2, g = 0.2, b = 0.2, a = 1}
    },
    Rarity = {
        normal = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/Image/AssistantCoachInformation_Filter_Btn_R_Normal.png",
        opened = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/Image/AssistantCoachInformation_Filter_Btn_R_Select.png",
        icon = nil,
        txt_nor = {r = 1, g = 1, b = 1, a = 0.7},
        txt_sel = {r = 0.2, g = 0.2, b = 0.2, a = 1}
    }
}

return AssistCoachFilterModel
