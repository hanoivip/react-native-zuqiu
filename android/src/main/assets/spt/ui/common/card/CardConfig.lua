local CardConfig = {}

CardConfig.QUALITY = {
    WHITE = 1,
    GREEN = 2,
    BLUE = 3,
    PURPLE = 4,
    ORANGE = 5,
    RED = 6,
    GOLD = 7,
}
CardConfig.QUALITY_MAP = {
    [1] = "white",
    [2] = "green",
    [3] = "blue",
    [4] = "purple",
    [5] = "orange",
    [6] = "red",
    [7] = "gold",
}

-- 场上位置的字母表示到球场上12个位置的映射
CardConfig.POSITION_LETTER_MAP = {
    FL = 1,
    ML = 2,
    DL = 3,
    FR = 4,
    MR = 5,
    DR = 6,
    FC = 7,
    AMC = 8,
    MC = 9,
    DMC = 10,
    DC = 11,
    GK = 12,
}

-- 场上位置1-12到字母的映射
CardConfig.POSITION_NUM_MAP = {
    [1] = "FL",
    [2] = "ML",
    [3] = "DL",
    [4] = "FR",
    [5] = "MR",
    [6] = "DR",
    [7] = "FC",
    [8] = "AMC",
    [9] = "MC",
    [10] = "DMC",
    [11] = "DC",
    [12] = "GK",
}

-- 场上位置1-12到字母的映射(uk海外地区描述)
CardConfig.POSITION_NUM_MAP2 = {
    [1] = "LWF",
    [2] = "LM",
    [3] = "LB",
    [4] = "RWF",
    [5] = "RM",
    [6] = "RB",
    [7] = "CF",
    [8] = "CAM",
    [9] = "CM",
    [10] = "CDM",
    [11] = "CB",
    [12] = "GK",
}

return CardConfig