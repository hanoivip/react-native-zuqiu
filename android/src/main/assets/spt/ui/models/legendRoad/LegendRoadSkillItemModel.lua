local SkillItemModel = require("ui.models.common.SkillItemModel")
local LegendRoadSkill = require("data.LegendRoadSkill")

-- 传奇之路技能
local LegendRoadSkillItemModel = class(SkillItemModel, "LegendRoadSkillItemModel")

function LegendRoadSkillItemModel:ctor(sid)
    LegendRoadSkillItemModel.super.ctor(self)
    if sid ~= nil then
        self:InitStaticData(sid)
    end
end

-- 根据球员的技能数据初始化，包含了球员技能数据
function LegendRoadSkillItemModel:InitWithCache(cache, slot)
    assert(cache, "cache can not be nil")
    self.slot = slot
    self.sid = cache.sid
    -- 特训技能，如果有，优先显示这个技能
    self.exSid = cache.exSid
    self.cacheData = cache
    self:InitStaticData(self.exSid or tostring(self.sid))
end

function LegendRoadSkillItemModel:InitStaticData(sid)
    self.staticData = LegendRoadSkill[sid] or {}
end

return LegendRoadSkillItemModel
