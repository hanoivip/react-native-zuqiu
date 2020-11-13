local ReqEventModel = require("ui.models.event.ReqEventModel")
local DialogManager = require("ui.control.manager.DialogManager")

-- 如果需要在无论有无带有event字段(例如reward)的情况下执行注册的函数，需要用到reqResultPrepareListeners
function reqResultPrepareListeners.reward(www)
    if www.event then
        ReqEventModel.SetInfo("reward", tonumber(www.event.reward))
    else
        ReqEventModel.SetInfo("reward", 0)
    end
end

function reqResultPrepareListeners.email(www)
    if www.event then
        ReqEventModel.SetInfo("email", tonumber(www.event.email))
    else
        ReqEventModel.SetInfo("email", 0)
    end
end

function reqResultPrepareListeners.letter(www)
    if www.event then
        ReqEventModel.SetInfo("letter", tonumber(www.event.letter))
    else
        ReqEventModel.SetInfo("letter", 0)
    end
end

function reqResultPrepareListeners.letterUnReceive(www)
    if www.event then
        ReqEventModel.SetInfo("letterUnReceive", tonumber(www.event.letterUnReceive))
    else
        ReqEventModel.SetInfo("letterUnReceive", 0)
    end
end

function reqResultPrepareListeners.honor(www)
    if www.event then
        ReqEventModel.SetInfo("honor", tonumber(www.event.honor))
    else
        ReqEventModel.SetInfo("honor", 0)
    end
end

function reqResultPrepareListeners.honorReward(www)
    if www.event then
        ReqEventModel.SetInfo("honorReward", tonumber(www.event.honorReward))
    else
        ReqEventModel.SetInfo("honorReward", 0)
    end
end

function reqResultPrepareListeners.letterOpen(www)
    if www.event then
        ReqEventModel.SetInfo("letterOpen", tonumber(www.event.letterOpen))
    else
        ReqEventModel.SetInfo("letterOpen", 0)
    end
end

function reqResultPrepareListeners.letterUnread(www)
    if www.event then
        ReqEventModel.SetInfo("letterUnread", tonumber(www.event.letterUnread))
    else
        ReqEventModel.SetInfo("letterUnread", 0)
    end
    cache.setHasNoReadMessage(tonumber(ReqEventModel.GetInfo("letterUnread")) > 0)
end

function reqResultPrepareListeners.letterFinish(www)
    if www.event then
        ReqEventModel.SetInfo("letterFinish", tonumber(www.event.letterFinish))
    else
        ReqEventModel.SetInfo("letterFinish", 0)
    end
    cache.setHasFinishMessage(tonumber(ReqEventModel.GetInfo("letterFinish")) > 0)
end

function reqResultPrepareListeners.friend(www)
    if www.event then
        ReqEventModel.SetInfo("friend", tonumber(www.event.friend))
    else
        ReqEventModel.SetInfo("friend", 0)
    end
end

function reqResultPrepareListeners.friendSp(www)
    if www.event then
        ReqEventModel.SetInfo("friendSp", tonumber(www.event.friendSp))
    else
        ReqEventModel.SetInfo("friendSp", 0)
    end
end

function reqResultPrepareListeners.friendReq(www)
    if www.event then
        ReqEventModel.SetInfo("friendReq", tonumber(www.event.friendReq))
    else
        ReqEventModel.SetInfo("friendReq", 0)
    end
end

-- 记录玩家好友的变动，以后实现
function reqResultPrepareListeners.friendAcp(www)
    if www.event then
        ReqEventModel.SetInfo("friendAcp", tonumber(www.event.friendAcp))
    else
        ReqEventModel.SetInfo("friendAcp", 0)
    end
end

function reqResultPrepareListeners.friendMatch(www)
    if www.event then
        ReqEventModel.SetInfo("friendMatch", tonumber(www.event.friendMatch))
    else
        ReqEventModel.SetInfo("friendMatch", 0)
    end
end

function reqResultPrepareListeners.friendInvite(www)
    if www.event then
        ReqEventModel.SetInfo("friendInvite", tonumber(www.event.friendInvite))
    else
        ReqEventModel.SetInfo("friendInvite", 0)
    end
end

function reqResultPrepareListeners.questLimit(www)
    if www.event then
        ReqEventModel.SetInfo("questLimit", tonumber(www.event.questLimit))
    else
        ReqEventModel.SetInfo("questLimit", 0)
    end
end

function reqResultPrepareListeners.leagueLimit(www)
    if www.event then
        ReqEventModel.SetInfo("leagueLimit", tonumber(www.event.leagueLimit))
    else
        ReqEventModel.SetInfo("leagueLimit", 0)
    end
end

function reqResultPrepareListeners.ladderRecord(www)
    if www.event then
        ReqEventModel.SetInfo("ladderRecord", tonumber(www.event.ladderRecord))
    else
        ReqEventModel.SetInfo("ladderRecord", 0)
    end
end

function reqResultPrepareListeners.activity(www)
    if www.event and type(www.event.activity) == "table" then
        ReqEventModel.SetInfo("activity", www.event.activity)
    else
        ReqEventModel.SetInfo("activity", {})
    end
end

function reqResultPrepareListeners.lotteryStake(www)
    if www.event then
        ReqEventModel.SetInfo("lotteryStake", tonumber(www.event.lotteryStake))
    else
        ReqEventModel.SetInfo("lotteryStake", 0)
    end
end

function reqResultPrepareListeners.freeGacha(www)
    if www.event then
        ReqEventModel.SetInfo("freeGacha", tonumber(www.event.freeGacha))
    else
        ReqEventModel.SetInfo("freeGacha", 0)
    end
end

function reqResultPrepareListeners.team(www)
    if www.event then
        ReqEventModel.SetInfo("team", tonumber(www.event.team))
    else
        ReqEventModel.SetInfo("team", 0)
    end
end

function reqResultPrepareListeners.msgPlayer(www)
    if www.event then
        ReqEventModel.SetInfo("msgPlayer", tonumber(www.event.msgPlayer))
    else
        ReqEventModel.SetInfo("msgPlayer", 0)
    end
end

function reqResultPrepareListeners.msgGuild(www)
    if www.event then
        ReqEventModel.SetInfo("msgGuild", tonumber(www.event.msgGuild))
    else
        ReqEventModel.SetInfo("msgGuild", 0)
    end
end

function reqResultPrepareListeners.guildSign(www)
    if www.event then
        ReqEventModel.SetInfo("guildSign", tonumber(www.event.guildSign))
    else
        ReqEventModel.SetInfo("guildSign", 0)
    end
end

function reqResultPrepareListeners.guildChlg(www)
    if www.event then
        ReqEventModel.SetInfo("guildChlg", tonumber(www.event.guildChlg))
    else
        ReqEventModel.SetInfo("guildChlg", 0)
    end
end

function reqResultPrepareListeners.guildWar(www)
    if www.event then
        ReqEventModel.SetInfo("guildWar", tonumber(www.event.guildWar))
    else
        ReqEventModel.SetInfo("guildWar", 0)
    end
end

function reqResultPrepareListeners.guildRequest(www)
    if www.event then
        ReqEventModel.SetInfo("guildRequest", tonumber(www.event.guildRequest))
    else
        ReqEventModel.SetInfo("guildRequest", 0)
    end
end

function reqResultPrepareListeners.arenaHonor(www)
    if www.event then
        ReqEventModel.SetInfo("arenaHonor", tonumber(www.event.arenaHonor))
    else
        ReqEventModel.SetInfo("arenaHonor", 0)
    end
end

function reqResultPrepareListeners.arenaZone(www)
    if www.event then
        ReqEventModel.SetInfo("arenaZone", tonumber(www.event.arenaZone))
    else
        ReqEventModel.SetInfo("arenaZone", 0)
    end
end

function reqResultPrepareListeners.arenaZoneAdvance(www)
    if www.event then
        ReqEventModel.SetInfo("arenaZoneAdvance", tonumber(www.event.arenaZoneAdvance))
    else
        ReqEventModel.SetInfo("arenaZoneAdvance", 0)
    end
end

function reqResultPrepareListeners.specific(www)
    if www.event then
        ReqEventModel.SetInfo("specific", tonumber(www.event.specific))
    else
        ReqEventModel.SetInfo("specific", 0)
    end
end

function reqResultPrepareListeners.peak(www)
    if www.event then
        ReqEventModel.SetInfo("peak", tonumber(www.event.peak))
    else
        ReqEventModel.SetInfo("peak", 0)
    end
end

function reqResultPrepareListeners.transport(www)
    if www.event then
        ReqEventModel.SetInfo("transport", tonumber(www.event.transport))
    else
        ReqEventModel.SetInfo("transport", 0)
    end
end

function reqResultPrepareListeners.transportApply(www)
    if www.event then
        ReqEventModel.SetInfo("transportApply", tonumber(www.event.transportApply))
    else
        ReqEventModel.SetInfo("transportApply", 0)
    end
end

function reqResultPrepareListeners.transportLog(www)
    if www.event then
        ReqEventModel.SetInfo("transportLog", tonumber(www.event.transportLog))
    else
        ReqEventModel.SetInfo("transportLog", 0)
    end
end

function reqResultPrepareListeners.peakDailyTask(www)
    if www.event then
        ReqEventModel.SetInfo("peakDailyTask", tonumber(www.event.peakDailyTask))
    else
        ReqEventModel.SetInfo("peakDailyTask", 0)
    end
end

function reqResultPrepareListeners.peakRecord(www)
    if www.event then
        ReqEventModel.SetInfo("peakRecord", tonumber(www.event.peakRecord))
    else
        ReqEventModel.SetInfo("peakRecord", 0)
    end
end

--- 跨天事件
function reqEventListeners.spanDay(spanDay)
    if tonumber(spanDay) == 1 then
        clr.coroutine(function()
            req.questInfo()
        end)
    end
end

function reqEventListeners.cardFull(evtVal)
    if tonumber(evtVal) == 1 then
        DialogManager.ShowConfirmPopByLang("", "Card_Full_Board_Message", function() require("ui.controllers.playerList.PlayerLimitCtrl").new() end)
    elseif tonumber(evtVal) == 2 then
        DialogManager.ShowToastByLang("Card_Full_Max_Limit_Alert")
    end
end

function reqResultPrepareListeners.item(www)
    if www.event then
        ReqEventModel.SetInfo("item", tonumber(www.event.item))
    else
        ReqEventModel.SetInfo("item", 0)
    end
end

function reqResultPrepareListeners.medal(www)
    if www.event then
        ReqEventModel.SetInfo("medal", tonumber(www.event.medal))
    else
        ReqEventModel.SetInfo("medal", 0)
    end
end

function reqResultPrepareListeners.BeginnerCarnivalSelf(www)
    if www.event then
        ReqEventModel.SetInfo("BeginnerCarnivalSelf", tonumber(www.event.BeginnerCarnivalSelf))
    else
        ReqEventModel.SetInfo("BeginnerCarnivalSelf", 0)
    end
end

function reqResultPrepareListeners.competeRewardMail(www)
    if www.event then
        ReqEventModel.SetInfo("worldTournamentEmail", tonumber(www.event.worldTournamentEmail))
    else
        ReqEventModel.SetInfo("worldTournamentEmail", 0)
    end
end

function reqResultPrepareListeners.competeGuess(www)
    if www.event then
        ReqEventModel.SetInfo("worldTournamentGuess", tonumber(www.event.worldTournamentGuess))
    else
        ReqEventModel.SetInfo("worldTournamentGuess", 0)
    end
end

function reqResultPrepareListeners.competeGuessReward(www)
    if www.event then
        ReqEventModel.SetInfo("worldTournamentGuessBonus", tonumber(www.event.worldTournamentGuessBonus))
    else
        ReqEventModel.SetInfo("worldTournamentGuessBonus", 0)
    end
end

function reqResultPrepareListeners.advMorale(www)
    if www.event then
        ReqEventModel.SetInfo("advMorale", tonumber(www.event.advMorale))
    else
        ReqEventModel.SetInfo("advMorale", 0)
    end
end

function reqResultPrepareListeners.advReward(www)
    if www.event then
        ReqEventModel.SetInfo("advReward", tonumber(www.event.advReward))
    else
        ReqEventModel.SetInfo("advReward", 0)
    end
end

function reqResultPrepareListeners.advDaily(www)
    if www.event then
        ReqEventModel.SetInfo("advDaily", tonumber(www.event.advDaily))
    else
        ReqEventModel.SetInfo("advDaily", 0)
    end
end

-- 【绿茵征途】好友赠送士气
function reqResultPrepareListeners.advFriend(www)
    if www.event then
        ReqEventModel.SetInfo("advFriend", tonumber(www.event.advFriend))
    else
        ReqEventModel.SetInfo("advFriend", 0)
    end
end

-- 【工会捐赠】有捐赠次数
function reqResultPrepareListeners.guildDonation(www)
    if www.event then
        ReqEventModel.SetInfo("guildDonation", tonumber(www.event.guildDonation))
    else
        ReqEventModel.SetInfo("guildDonation", 0)
    end
end

-- 【豪门阶梯商店】有可领取的任务奖励
function reqResultPrepareListeners.stageShopTask(www)
    if www.event then
        ReqEventModel.SetInfo("stageShopTask", tonumber(www.event.stageShopTask))
    else
        ReqEventModel.SetInfo("stageShopTask", 0)
    end
end

-- 【幸运弹球活动】有可兑换的奖励
function reqResultPrepareListeners.marblesExchange(www)
    if www.event then
        ReqEventModel.SetInfo("marblesExchange", tonumber(www.event.marblesExchange))
    else
        ReqEventModel.SetInfo("marblesExchange", 0)
    end
end

-- 【幸运弹球活动】有可领取的任务奖励
function reqResultPrepareListeners.marblesTask(www)
    if www.event then
        ReqEventModel.SetInfo("marblesTask", tonumber(www.event.marblesTask))
    else
        ReqEventModel.SetInfo("marblesTask", 0)
    end
end

-- 【幸运弹球活动】有可领取的次数奖励
function reqResultPrepareListeners.marblesCount(www)
    if www.event then
        ReqEventModel.SetInfo("marblesCount", tonumber(www.event.marblesCount))
    else
        ReqEventModel.SetInfo("marblesCount", 0)
    end
end

function reqResultPrepareListeners.fbShare(www)
    if www.event then
        ReqEventModel.SetInfo("fbShare", tonumber(www.event.fbShare))
    else
        ReqEventModel.SetInfo("fbShare", 0)
    end
end

function reqResultPrepareListeners.auctionTip(www)
    if www.event then
        ReqEventModel.SetInfo("auctionTip", tonumber(www.event.auctionTip))
    else
        ReqEventModel.SetInfo("auctionTip", 0)
    end
end

-- -1 没有可购买的vip奖励 0 -- 16 可购买vip奖励中最大的
function reqResultPrepareListeners.auctionTip(www)
    if www.event then
        ReqEventModel.SetInfo("vipRewardBuyState", tonumber(www.event.vipRewardBuyState))
    else
        ReqEventModel.SetInfo("vipRewardBuyState", -1)
    end
end

-- 梦幻11人红点
function reqResultPrepareListeners.fancyGacha(www)
    if www.event and type(www.event.fancyCard) == "table" then
        ReqEventModel.SetInfo("fancyGacha", www.event.fancyCard)
    else
        ReqEventModel.SetInfo("fancyGacha", {})
    end
end

-- 只有返回的event含有reward字段，才执行注册的函数时用reqEventListeners
-- function reqEventListeners.reward(data)
--     dump(data)
-- end
