local CustomEvent = {}

-- 1.钻石 获得 钻石获得時
function CustomEvent.GetDiamond(get_type, value, info)
    dump(format("GetDiamond, type:%s, value:%s", tostring(get_type), tostring(value)), info)
    if luaevt.trig("HasSgpSDK") then
        require("ui.common.SgpCustomEvent").GetDiamond(get_type, value, info)
    end
end

-- 2.钻石 消费 钻石消费時
function CustomEvent.ConsumeDiamond(spend_type, value, info)
    dump(format("ConsumeDiamond, type:%s, value:%s", tostring(spend_type), tostring(value)), info)
    if luaevt.trig("HasSgpSDK") then
        require("ui.common.SgpCustomEvent").ConsumeDiamond(spend_type, value, info)
    end  
end

-- hmb 获得 v获得時
function CustomEvent.GetBlackDiamond(get_type, value, info)
    dump(format("GetBlackDiamond, type:%s, value:%s", tostring(get_type), tostring(value)), info)
    if luaevt.trig("HasSgpSDK") then
        require("ui.common.SgpCustomEvent").GetBlackDiamond(get_type, value, info)
    end
end

-- hmb 消费 hmb消费時
function CustomEvent.ConsumeBlackDiamond(spend_type, value, info)
    dump(format("ConsumeBlackDiamond, type:%s, value:%s", tostring(spend_type), tostring(value)), info)
    if luaevt.trig("HasSgpSDK") then
        require("ui.common.SgpCustomEvent").ConsumeBlackDiamond(get_type, value, info)
    end
end

-- 3.抽卡 抽卡 抽卡实行
function CustomEvent.GachaOne(scout_type, diamond_value)
    dump(format("GachaOne, type:%s, value:%s", tostring(scout_type), tostring(diamond_value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").GachaOne(scout_type, diamond_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").GachaOne(scout_type, diamond_value)
    end
end

-- 4.抽卡 抽卡10连 抽卡实行
function CustomEvent.GachaTen(scout_type, diamond_value)
    dump(format("GachaTen, type:%s, value:%s", tostring(scout_type), tostring(diamond_value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").GachaTen(scout_type, diamond_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").GachaTen(scout_type, diamond_value)
    end
end

-- 5.主线 比赛start 比赛开始时
function CustomEvent.StoryMatchStart(stage_no, power_value)
    dump(format("StoryMatchStart, stage_no:%s, power_value:%s", tostring(stage_no), tostring(power_value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").StoryMatchStart(stage_no, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").StoryMatchStart(stage_no, power_value)
    end
    if luaevt.trig("HasReyunSDK") then
        require("ui.common.ReyunCustomEvent").StoryMatchStart(stage_no, power_value)
    end
end

-- 6.主线 比赛end 比赛结束时
function CustomEvent.StoryMatchEnd(stage_no, is_win, power_value)
    dump(format("StoryMatchEnd, stage_no:%s, power_value:%s, is_win:%s", tostring(stage_no), tostring(power_value), tostring(is_win)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").StoryMatchEnd(stage_no, is_win, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").StoryMatchEnd(stage_no, is_win, power_value)
    end

    if luaevt.trig("HasReyunSDK") then
        require("ui.common.ReyunCustomEvent").StoryMatchEnd(stage_no, is_win, power_value)
    end
end

-- 7.特殊副本 比赛start 比赛开始时
function CustomEvent.StorySpecialMatchStart(stage_no, power_value)
    dump(format("StorySpecialMatchStart, stage_no:%s, power_value:%s", tostring(stage_no), tostring(power_value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").StorySpecialMatchStart(stage_no, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").StorySpecialMatchStart(stage_no, power_value)
    end
end

-- 8.特殊副本 比赛end 比赛结束时
function CustomEvent.StorySpecialMatchEnd(stage_no, is_win, power_value)
    dump(format("StorySpecialMatchEnd, stage_no:%s, power_value:%s, is_win:%s", tostring(stage_no), tostring(power_value), tostring(is_win)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").StorySpecialMatchEnd(stage_no, is_win, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").StorySpecialMatchEnd(stage_no, is_win, power_value)
    end
end

-- 9.联赛 比赛start 比赛开始时
function CustomEvent.LeagueMatchStart(league_level, power_value)
    dump(format("LeagueMatchStart, league_level:%s, power_value:%s", tostring(league_level), tostring(power_value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").LeagueMatchStart(league_level, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").LeagueMatchStart(league_level, power_value)
    end
end

-- 10.联赛 比赛end 比赛结束时
function CustomEvent.LeagueMatchEnd(league_level, is_win, power_value)
    dump(format("LeagueMatchEnd, league_level:%s, power_value:%s, is_win:%s", tostring(league_level), tostring(power_value), tostring(is_win)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").LeagueMatchEnd(league_level, is_win, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").LeagueMatchEnd(league_level, is_win, power_value)
    end
end

-- 11.公会主线 比赛start 比赛开始时
function CustomEvent.GuildStoryMatchStart(stage_no, power_value)
    dump(format("GuildStoryMatchStart, stage_no:%s, power_value:%s", tostring(stage_no), tostring(power_value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").GuildStoryMatchStart(stage_no, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").GuildStoryMatchStart(stage_no, power_value)
    end
end

-- 12.公会主线 比赛end 比赛结束时
function CustomEvent.GuildStoryMatchEnd(stage_no, is_win, power_value)
    dump(format("GuildStoryMatchEnd, stage_no:%s, power_value:%s, is_win:%s", tostring(stage_no), tostring(power_value), tostring(is_win)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").GuildStoryMatchEnd(stage_no, is_win, power_value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").GuildStoryMatchEnd(stage_no, is_win, power_value)
    end
end

-- 13.公会 guild 公会主线解放时
function CustomEvent.GuildStoryBuy(stage_no, spend_point)
    dump(format("GuildStoryBuy, stage_no:%s, spend_point:%s", tostring(stage_no), tostring(spend_point)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").GuildStoryBuy(stage_no, spend_point)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").GuildStoryBuy(stage_no, spend_point)
    end
end

-- 14.公会战 guild_war 工会战挑战時
function CustomEvent.GuildWarChallenge(is_win)
    dump(format("GuildWarChallenge, is_win:%s", tostring(is_win)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").GuildWarChallenge(is_win)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").GuildWarChallenge(is_win)
    end
end

-- 15.欧元 获得 欧元获得時
function CustomEvent.GetMoney(get_type, value)
    dump(format("GetMoney, type:%s, value:%s", tostring(get_type), tostring(value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").GetMoney(get_type, value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").GetMoney(get_type, value)
    end
end

-- 16.欧元 消费 欧元消费時
function CustomEvent.ConsumeMoney(spend_type, value)
    dump(format("ConsumeMoney, type:%s, value:%s", tostring(spend_type), tostring(value)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").ConsumeMoney(spend_type, value)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").ConsumeMoney(spend_type, value)
    end
end

-- 17.运动员卡牌 育成_升级 升级实行時
function CustomEvent.CardLevelUp()
    dump("CardLevelUp")
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").CardLevelUp()
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").CardLevelUp()
    end
end

-- 18.运动员卡牌 育成_進級 進級实行時
function CustomEvent.CardGradeUp()
    dump("CardGradeUp")
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").CardGradeUp()
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").CardGradeUp()
    end
end

-- 19.运动员卡牌 育成_skill升级 skill升级实行時
function CustomEvent.CardSkillUp()
    dump("CardSkillUp")
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").CardSkillUp()
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").CardSkillUp()
    end
end

-- 20.运动员卡牌 育成_潜能 潜能实行時
function CustomEvent.CardPotential()
    dump("CardPotential")
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").CardPotential()
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").CardPotential()
    end
end

-- 21.运动员卡牌 育成_转生 转生实行時
function CustomEvent.CardReincarnation()
    dump("CardReincarnation")
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").CardReincarnation()
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").CardReincarnation()
    end
end

-- 22.运动员卡牌 出售 出售实行時
function CustomEvent.CardSell()
    dump("CardSell")
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").CardSell()
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").CardSell()
    end
end

-- 23.训练 训练 训练实行時
function CustomEvent.Training()
    dump("Training")
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").Training()
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").Training()
    end
end

-- 24.球场 强化设施 球场强化设施实行時
function CustomEvent.StatiumDevelop(facility)
    dump(format("StatiumDevelop, facility:%s", tostring(facility)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").StatiumDevelop(facility)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").StatiumDevelop(facility)
    end
end

-- 25.mission mission根据情况，也许记录时要细分mission种类 mission达成
function CustomEvent.MissionArchive(mission_no)
    dump(format("MissionArchive, mission_no:%s", tostring(mission_no)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").MissionArchive(mission_no)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").MissionArchive(mission_no)
    end
end

-- 26.设置用户id
function CustomEvent.SetUserId(id)
    dump(format("SetUserId, id:%s", tostring(id)))
    if luaevt.trig("HasTapjoySDK") then
        require("ui.common.TapjoyCustomEvent").SetUserId(id)
    end
    if luaevt.trig("HasMetapsSDK") then
        require("ui.common.MetapsCustomEvent").SetUserId(id)
    end
end

return CustomEvent
