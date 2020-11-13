local PasterMainType = 
{
    Default = 0,
    General = -1,
    Week = 1,
    Month = 2,
    Honor = 3,
    Compete = 4,    -- 争霸赛贴纸
    Annual = 5
}

function PasterMainType.CanPasterSkillUpgrade(pasterType)
    -- 周贴月贴带来新技能，可升级
    if tonumber(pasterType) == PasterMainType.Week or tonumber(pasterType) == PasterMainType.Month then
        return true
    else
        return false
    end
end

return PasterMainType