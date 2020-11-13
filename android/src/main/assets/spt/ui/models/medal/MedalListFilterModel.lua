-- local MedalListFilterModel = require("ui.models.medal.MedalListFilterModel")
local MedalListFilterModel = {}

MedalListFilterModel.FilterType = {
    Equip = "Equip",
    State = "State",
    Quality = "Quality",
    Shape = "Shape",
}

MedalListFilterModel.FirstStyle = {
    Equip = 3
}

MedalListFilterModel.EquipVar = {
    Equip = 1,
    NotEquip = 0
}

MedalListFilterModel.Equip = {
    { id = 1, name = "medal_new_filter_equiped", filterVar = nil },  -- 全部勋章
    { id = 2, name = "medal_new_filter_equiped_1", filterVar = 1 },  -- 已携带
    { id = 3, name = "medal_new_filter_equiped_2", filterVar = 0 }  -- 未携带
}

MedalListFilterModel.State = {
    { id = 1, name = "medal_new_filter_state", filterVar = nil },  -- 勋章状态
    { id = 2, name = "medal_new_filter_state_1", filterVar = 0 },  -- 良好
    { id = 3, name = "medal_new_filter_state_2", filterVar = 1 }  -- 破损
}

MedalListFilterModel.Quality = {
    { id = 1, name = "medal_new_filter_quality", filterVar = nil },  -- 勋章品质
    { id = 2, name = "quality_sign_2", filterVar = 1 },  -- C
    { id = 3, name = "quality_sign_3", filterVar = 2 },  -- B
    { id = 4, name = "quality_sign_4", filterVar = 3 },  -- A
    { id = 5, name = "quality_sign_5", filterVar = 4 },  -- S
    { id = 6, name = "quality_sign_6", filterVar = 5 },  -- SS
    { id = 7, name = "quality_sign_7", filterVar = 6 }  -- SSS
}

MedalListFilterModel.Shape = {
    { id = 1, name = "medal_new_filter_shape", filterVar = nil },  -- 勋章形状
    { id = 2, name = "medal_new_filter_shape_1", filterVar = 1 },  -- 圆形
    { id = 3, name = "medal_new_filter_shape_2", filterVar = 2 },  -- 方形
    { id = 4, name = "medal_new_filter_shape_3", filterVar = 3 },  -- 三角形
    { id = 5, name = "medal_new_filter_shape_4", filterVar = 4 },  -- 五角星形
    { id = 6, name = "medal_new_filter_shape_5", filterVar = 5 },  -- 菱形
    { id = 7, name = "medal_new_filter_shape_6", filterVar = 6 },  -- 扇形
    { id = 8, name = "medal_new_filter_shape_7", filterVar = 7 },  -- 倒扇形
    { id = 9, name = "medal_new_filter_shape_8", filterVar = 8 },  -- 水滴形
    { id = 10, name = "medal_new_filter_shape_9", filterVar = 9 },  -- 心形
    { id = 11, name = "medal_new_filter_shape_10", filterVar = 10 }  -- 六边形
}

return MedalListFilterModel
