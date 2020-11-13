local Skill = import("../Skill")
local OrganizeWall = import("./OrganizeWall")

local OrganizeWallEx1 = class(OrganizeWall, "OrganizeWallEx1")
OrganizeWallEx1.id = "E08_1"
OrganizeWallEx1.alias = "指挥人墙"

-- 门将全属性提升配置
local minAddConfig = 0.11
local maxAddConfig = 1.1
-- 门将获得人墙所有球员拦截总和加成配置
local minInterceptAddConfig = 0.25
local maxInterceptAddConfig = 0.25
-- 防守队员额外获得门将防线指挥属性加成配置
local minCommandingAddConfig = 0.8
local maxCommandingAddConfig = 0.8

function OrganizeWallEx1:ctor(level)
    OrganizeWall.ctor(self, level)

    self.ex1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
    self.ex1InterceptAddRatio = Skill.lerpLevel(minInterceptAddConfig, maxInterceptAddConfig, level)
    self.ex1CommandingAddRatio = Skill.lerpLevel(minCommandingAddConfig, maxCommandingAddConfig, level)

    self.ex1Buff = {
        skill = self,
        remark = "ignoreCannotAddBuffDebuff",
        removalCondition = function(remainingTime, caster, receiver)
            return false
        end,
        abilitiesAddRatio = function(caster, receiver)
            return self.ex1AddRatio
        end,
        persistent = true
    }

    self.ex1BuffCenter = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole() or receiver.match.frozenType == "CornerKick"
        end,
        abilitiesAddRatio = function(caster, receiver)
            local extraInterceptAbility = 0
            for i, a in ipairs(receiver.team.centerDirectFreeKickWall) do
                extraInterceptAbility = extraInterceptAbility + a:getAbilities().intercept
            end
            return extraInterceptAbility * self.ex1InterceptAddRatio / receiver:getAbilitiesSum()
        end
    }

    self.ex1BuffWing = {
        skill = self,
        removalCondition = function(remainingTime, caster, receiver)
            return receiver.team:isAttackRole() or receiver.match.frozenType == "CornerKick"
        end,
        abilitiesAddRatio = function(caster, receiver)
            return caster:getAbilities().commanding / receiver:getAbilitiesSum()
        end
    }
end

function OrganizeWallEx1:enterField(athlete)
    athlete:addBuff(self.ex1Buff, athlete)
end

return OrganizeWallEx1