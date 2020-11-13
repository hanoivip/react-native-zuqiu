local CardHelper = require("ui.scene.cardDetail.CardHelper")

local AssistantCoachConstants = {}

AssistantCoachConstants.MaxQuality = 7

AssistantCoachConstants.MaxAttrNum = 5

-- 配表 AssistantCoachSkill
AssistantCoachConstants.SkillType = {
    ToSkill = 1, -- 上阵球员单技能加等级
    ToAttr = 2, -- 上阵球员加属性
    ToAllSkill = 3 -- 上阵球员全技能（不包含贴纸技能）加等级
}

-- 两个字的球员属性中添加空格的语言表翻译
local BLANK_NAME_MARK = "_blank"
function AssistantCoachConstants.GetAttrName(attrType, withColon)
    local colon = withColon and "：" or ""
    if CardHelper.NormalPlayerOrderShort[tostring(attrType)] then
        return lang.transstr(tostring(attrType) .. BLANK_NAME_MARK) .. colon
    else
        return lang.transstr(tostring(attrType)) .. colon
    end
end

return AssistantCoachConstants
