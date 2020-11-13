local CardTrainingConstant = {}

CardTrainingConstant.LetterPart = {
    Exp = 1,
    Item = 2,
    ItemWithCard = 3, -- 这个字段废弃，通过检测card字段是否为空
    Condition = 4,   -- 这个字段代表未满足开启第一关卡的界面
    FinishOnlyAttribute = 5,
    FinishWithSkill = 6,
    Empty = 7,
}

CardTrainingConstant.ImproveStyle = {
    AllImprove= 1,      -- 各属性均提升
    PartImprote = 2,    -- 部分属性提升
}

CardTrainingConstant.SkillImproveMap = {
    [1] = "firstSkillEx",
    [2] = "secondSkillEx",
    [3] = "thirdSkillEx",
    [4] = "fourthSkillEx",
    [5] = "fifthSkillEx"
}

CardTrainingConstant.MaxSubId = 5

CardTrainingConstant.AllSkillLvlImprove = "allSkillImprove"

return CardTrainingConstant