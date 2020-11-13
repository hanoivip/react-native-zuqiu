local VIP = require("data.VIP")
local VIPBag = require("data.VIPBag")
local VIPModel = {}

for i, v in ipairs(VIP) do
    VIPModel[v.vipLv] = clone(v)
    if v.vipLv > 0 then
        --[[
        local desc = ""
        if v.cumDiamond > 0 then
            desc = desc .. format("累计充值%s钻石即可享受该等级特权。\n", v.cumDiamond)
        end
        if v.vipLv > 1 then
            desc = desc .. format("包含VIP%s等级所有特权。\n", v.vipLv - 1)
        end
        if v.sp > 0 then
            desc = desc .. format("每天可购买%s次体力。\n", v.sp)
        end
        if v.transfer > 0 then
            desc = desc .. format("每天可手动刷新转会市场%s次。\n", v.transfer)
        end
        if v.skillUp == 1 then
            desc = desc .. format("可以使用钻石升级技能。\n")
        end
        if v.reset > 0 then
            desc = desc .. format("每天可重置副本%s次。\n", v.reset)
        end
        if v.ladderTime == 1 then
            desc = desc .. format("天梯挑战无冷却。\n")
        end
        if v.trainSweep == 1 then
            desc = desc .. format("解锁训练基地扫荡功能。\n")
        end
        if v.leagueTimes > 0 then
            desc = desc .. format("联赛额外%s次。\n", v.leagueTimes)
        end
        if v.leagueTimes > 0 then
            desc = desc .. format("联赛额外%s次。\n", v.leagueTimes)
        end
        if v.guildQuestReward > 0 then
            desc = desc .. format("公会副本产出增加%s%%。\n", v.guildQuestReward)
        end
        if v.mystery == 1 then
            desc = desc .. format("解锁神秘经纪人功能。\n")
        end
        if v.autoSP == 1 then
            desc = desc .. format("自动领取每日体力。\n")
        end
        if v.guildQuestSweep == 1 then
            desc = desc .. format("解锁公会扫荡功能。\n")
        end
        if v.specialQuestSweep == 1 then
            desc = desc .. format("解锁特殊副本扫荡功能。\n")
        end
        desc = desc .. format("可在商城中购买VIP%s礼包。", v.vipLv)
        VIPModel[v.vipLv].desc = desc
        --]]
        local bagInfo = VIPBag[tostring(v.vipLv)]
        VIPModel[v.vipLv].price = bagInfo.cost
        VIPModel[v.vipLv].bagContents = bagInfo.contents
        VIPModel[v.vipLv].bagId = v.vipLv
    end
end

return VIPModel
