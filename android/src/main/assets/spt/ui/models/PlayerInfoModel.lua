local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local PlayerLevel = require("data.PlayerLevel")
local LevelLimit = require("data.LevelLimit")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local PlayerInfoModel = class(Model, "PlayerInfoModel")

local tonumber = tonumber

function PlayerInfoModel:ctor()
    PlayerInfoModel.super.ctor(self)
end

function PlayerInfoModel:Init(data)
    if not data then
        data = cache.getPlayerInfo()
    end
    self.data = data
end

function PlayerInfoModel:InitWithProtocol(data)
    cache.setPlayerInfo(data)
    self:Init(data)
end

-- Get method
function PlayerInfoModel:GetPower()
    return self.data.power or 1
end
function PlayerInfoModel:GetID()
    return self.data._id
end
function PlayerInfoModel:GetSID()
    return self.data.sid
end
function PlayerInfoModel:GetCareerPoint()
    return self.data.cp
end
function PlayerInfoModel:GetDiamond()
    return self.data.d
end
function PlayerInfoModel:GetBlackDiamond()
    return self.data.bkd
end
function PlayerInfoModel:GetPeakDiamond()
    return self.data.pp or 0
end
function PlayerInfoModel:GetHonorDiamond()
    return self.data.h or 0
end
function PlayerInfoModel:GetFancyPiece()
    return self.data.fancyPiece or 0
end
function PlayerInfoModel:GetFS()
    return self.data.fs or 0
end
--满级后能量条注满
function PlayerInfoModel:GetExp()
    return PlayerLevel[tostring(self:GetLevel() + 1)] and self.data.exp or (PlayerLevel[tostring(self:GetLevel())].playerExp)
end
function PlayerInfoModel:GetGuildHonor()
    return self.data.gh
end
function PlayerInfoModel:GetLevel()
    return self.data.lvl
end
function PlayerInfoModel:GetLucky()
    return self.data.lucky
end
function PlayerInfoModel:GetMoney()
    return self.data.m
end
function PlayerInfoModel:GetName()
    return self.data.name
end
function PlayerInfoModel:GetRedDiamond()
    return self.data.rd
end
function PlayerInfoModel:GetReputation()
    return self.data.reputation
end
function PlayerInfoModel:GetStrengthPower()
    return self.data.sp
end
function PlayerInfoModel:GetToken()
    return self.data.token
end
function PlayerInfoModel:IsSampleMatchEnd()
    return self.data.s_m
end
function PlayerInfoModel:GetEmailState()
    return self.data.mailIsShow
end
function PlayerInfoModel:GetVipLevel()
    return self.data.vip and self.data.vip.lvl
end
function PlayerInfoModel:GetVipCost()
    return self.data.vip and self.data.vip.d 
end
function PlayerInfoModel:GetFriendshipPoint()
    return self.data.fp
end
function PlayerInfoModel:GetLoginDate()
    return self.data.l_t
end
-- 获得天梯荣誉点
function PlayerInfoModel:GetLadderPoint()
    return self.data.lp or 0
end
function PlayerInfoModel:GetCreateDate()
    return os.date("%Y".."/" .. "%m" .. "/" .. "%d", self.data.c_t)
end
function PlayerInfoModel:GetCreateTime()
    return self.data.c_t
end
function PlayerInfoModel:GetShowHonorList()
    return self.data.honor
end
function PlayerInfoModel:GetTrophyNum()
    return self.data.honorCupNum
end
function PlayerInfoModel:GetFriendsCount()
    return self.data.friendsCount
end
function PlayerInfoModel:GetStardustCount()
    return self.data.sd or 0
end
function PlayerInfoModel:GetBenedictionCount()
    return self.data.bs or 0
end
function PlayerInfoModel:GetCompeteCurrency()
    return self.data.wtc or 0
end
-- 殿堂精华
function PlayerInfoModel:GetHeroHallSmdCurrency()
    return self.data.smd or 0
end
-- 殿堂升阶石
function PlayerInfoModel:GetHeroHallSmbCurrency()
    return self.data.smb or 0
end

-- 执教经验书
function PlayerInfoModel:GetCredentialExp()
    return self.data.ce or 0
end

-- 教练天赋点
function PlayerInfoModel:GetCoachTalentPoint()
    return self.data.ctp or 0
end

-- 助理教练经验书
function PlayerInfoModel:GetAssistantCoachExp()
    return self.data.ace or 0
end

-- [绿茵征途]士气
function PlayerInfoModel:GetMorale()
    return self.data.morale or 0
end

-- [绿茵征途]斗志
function PlayerInfoModel:GetFight()
    return self.data.fight or 0
end

-- 1 使用球员真名  2 使用球员假名
function PlayerInfoModel:GetDreamLeagueOpenState()
    return self.data.dreamLeagueOpen or 0
end

-- 梦幻币
function PlayerInfoModel:GetDreamCoin()
    return self.data.dc or 0
end

-- 梦幻碎片
function PlayerInfoModel:GetDreamPiece()
    return self.data.dp or 0
end

-- 争霸赛开启加入时间机制
function PlayerInfoModel:GetCompeteRemainTime()
    return self.data.worldTournamentRemainTime   or 0
end

-- 争霸赛等级标志
function PlayerInfoModel:GetCompeteSign()
    return self.data.worldTournamentLevel
end

-- 兼容旧账号里边的命名方式
function PlayerInfoModel.TransTeamLogoData(data)
    if data.frameId == "Frame1" or data.frameId == "Frame2" or data.frameId == "Frame3" or data.frameId == "Frame4" then
        data.frameId = data.frameId .. "_1"
    end

    local ret = {
        boardId = data.boardId,
        borderId = data.frameId or data.borderId,
        iconId = data.figureId or data.iconId,
        ribbonId = data.ribbonId,
        colorId = data.colorId,
    }
    return ret
end

-- 设置特殊队徽队服数据
function PlayerInfoModel:IsUseSpecificTeam()
    local specificTeam = self:GetSpecificTeam()
    return type(specificTeam) == "string" and string.len(specificTeam) > 0
end

function PlayerInfoModel:GetSpecificTeam()
    return self.data.specificTeam
end

function PlayerInfoModel:SetSpecificTeam(specificTeam)
    self.data.specificTeam = specificTeam
    EventSystem.SendEvent("UpdateSuitSkin")
end

function PlayerInfoModel:GetTeamLogo()
    local SpecificTeamData = require("cloth.SpecificTeamData")
    local specificTeam = self:GetSpecificTeam()
    if type(specificTeam) == "string" and SpecificTeamData[specificTeam] then
        return SpecificTeamData[specificTeam].logo
    else
        local logo = self.data.logo
        return type(logo) == "table" and PlayerInfoModel.TransTeamLogoData(logo) or logo
    end
end
-- uniformType可以为TeamUniformModel.UniformType.Home, TeamUniformModel.UniformType.Away, TeamUniformModel.UniformType.Gk
function PlayerInfoModel:GetTeamUniform(uniformType)
    return self.data.shirt and self.data.shirt[uniformType]
end

function PlayerInfoModel:GetSmallTeamUniform()
    return self.data.shirt and self.data.shirt.small
end

function PlayerInfoModel:GetSpectators()
    if self.data.spectators then
        return self.data.spectators
    else
        local homeShirt = self:GetTeamUniform(require("ui.models.common.TeamUniformModel").UniformType.Home)
        return {
            firstColor = homeShirt.maskRedChannel,
            secondColor = homeShirt.maskGreenChannel,
            maskTex = "SpectatorsMask1",
        }
    end
end

-- 升级总共需要累计多少经验
function PlayerInfoModel:GetLevelUpTotalExp()
    local nextLevelStaticData = PlayerLevel[tostring(self:GetLevel() + 1)] or PlayerLevel[tostring(self:GetLevel())]
    if nextLevelStaticData then
        return nextLevelStaticData.cumPlayerExp
    end
end

-- 升级到下一级需要多少经验
function PlayerInfoModel:GetLevelUpExp()
    local nextLevelStaticData = PlayerLevel[tostring(self:GetLevel() + 1)] or PlayerLevel[tostring(self:GetLevel())]
    if nextLevelStaticData then
        return nextLevelStaticData.playerExp
    end
end

-- 当前等级可持有的卡牌上限
function PlayerInfoModel:GetCardNumberLimit()
    return tonumber(PlayerLevel[tostring(self:GetLevel())].cardNumber)
end

function PlayerInfoModel:IsLeagueLock()
    return tonumber(self.level) < 10
end

function PlayerInfoModel:IsGuildLock()
    return tonumber(self.level) < 25
end

function PlayerInfoModel:AddStrength(num)
    self.data.sp = tonumber(self.data.sp) + num
    
    self:OnPlayerInfoChanged()
end    

function PlayerInfoModel:AddDiamond(num)
    self:SetDiamond(tonumber(self.data.d) + num)
end

function PlayerInfoModel:AddBKDiamond(num)
    self:SetBlackDiamond(tonumber(self.data.bkd) + num)
end

function PlayerInfoModel:ReduceDiamond(num)
    self:SetDiamond(tonumber(self.data.d) - num)
end

function PlayerInfoModel:AddMoney(money)
    assert(type(money) == "number")
    self.data.m = tonumber(self.data.m) + money

    self:OnPlayerInfoChanged() 
end

function PlayerInfoModel:AddDreamPiece(dp)
    assert(type(dp) == "number")
    self.data.dp = tonumber(self.data.dp) + dp
    self:OnPlayerInfoChanged() 
end

function PlayerInfoModel:AddDreamCoin(dc)
    assert(type(dc) == "number")
    self.data.dc = tonumber(self.data.dc) + dc
    self:OnPlayerInfoChanged() 
end

function PlayerInfoModel:AddStardustCount(sd)
    self:SetStardustCount(tonumber(self.data.sd) + sd)
end

function PlayerInfoModel:AddBenedictionCount(bs)
    self:SetBenedictionCount(tonumber(self.data.bs) + bs)
end

function PlayerInfoModel:AddPeakPointCount(pp)
    self:SetPeakDiamond(tonumber(self.data.pp) + pp)
end

function PlayerInfoModel:AddHonorCount(h)
    self:SetHonorDiamond(tonumber(self.data.h) + h)
end

function PlayerInfoModel:AddLadderPoint(lp)
    self:SetLadderPoint(tonumber(self.data.lp) + lp)
end

function PlayerInfoModel:AddCompeteCurrency(wtc)
    self:SetCompeteCurrency(tonumber(self.data.wtc) + wtc)
end

function PlayerInfoModel:AddHeroHallSmdCurrency(smd)
    self:SetHeroHallSmdCurrency(tonumber(self.data.smd) + smd)
end

function PlayerInfoModel:AddHeroHallSmbCurrency(smb)
    self:SetHeroHallSmbCurrency(tonumber(self.data.smb) + smb)
end

-- 执教经验书
function PlayerInfoModel:AddCredentialExp(ce)
    self:SetCredentialExp(tonumber(self.data.ce) + ce)
end

-- 教练天赋点
function PlayerInfoModel:AddCoachTalentPoint(ctp)
    self:SetCoachTalentPoint(tonumber(self.data.ctp) + ctp)
end

-- 助理教练经验书
function PlayerInfoModel:AddAssistantCoachExp(ace)
    self:SetAssistantCoachExp(tonumber(self.data.ace) + ace)
end

-- [绿茵征途]士气
function PlayerInfoModel:AddMorale(morale)
    self:SetMorale(tonumber(self.data.morale) + morale)
end

-- [绿茵征途]斗志
function PlayerInfoModel:AddFight(fight)
    self:SetFight(tonumber(self.data.fight) + fight)
end

--[梦幻卡]梦幻碎片
function PlayerInfoModel:AddFancyPiece(num)
    self:SetFancyPiece(tonumber(self.data.fancyPiece) + num)
end

--[梦幻卡]球魂
function PlayerInfoModel:AddFS(num)
    self:SetFs(tonumber(self.data.fs) + num)
end

function PlayerInfoModel:SetLevel(level)
    self.data.lvl = tonumber(level)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetDreamPiece(dp)
    self:SetHonorDiamond(tonumber(dp))
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetDreamCoin(dc)
    self.data.dc = tonumber(dc) or 0
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetLucky(lucky)
    self.data.lucky = tonumber(lucky)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetExp(exp)
    self.data.exp = tonumber(exp)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetMoney(money)
    self.data.m = tonumber(money)
    EventSystem.SendEvent("PlayerInfoModel_SetMoney", self.data.m)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetDiamond(diamond)
    local consumeDiamondNumber = tonumber(self.data.d) - tonumber(diamond)
    self.data.d = tonumber(diamond)

    EventSystem.SendEvent("ConsumeDiamond", consumeDiamondNumber)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetCompeteCurrency(wtc)
    self.data.wtc = tonumber(wtc)
    EventSystem.SendEvent("PlayerInfoModel_SetCompeteCurrency", self.data.wtc)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetHeroHallSmdCurrency(smd)
    self.data.smd = tonumber(smd)
    EventSystem.SendEvent("PlayerInfoModel_SetHeroHallSmdCurrency", self.data.smd)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetHeroHallSmbCurrency(smb)
    self.data.smb = tonumber(smb)
    EventSystem.SendEvent("PlayerInfoModel_SetHeroHallSmbCurrency", self.data.smb)
    self:OnPlayerInfoChanged()
end

-- 执教经验书
function PlayerInfoModel:SetCredentialExp(ce)
    self.data.ce = tonumber(ce)
    EventSystem.SendEvent("PlayerInfoModel_SetCredentialExpCurrency", self.data.ce)
    self:OnPlayerInfoChanged()
end

-- 教练天赋点
function PlayerInfoModel:SetCoachTalentPoint(ctp)
    self.data.ctp = tonumber(ctp)
    EventSystem.SendEvent("PlayerInfoModel_SetCoachTalentPointCurrency", self.data.ctp)
    self:OnPlayerInfoChanged()
end

-- 助理教练经验书
function PlayerInfoModel:SetAssistantCoachExp(ace)
    self.data.ace = tonumber(ace)
    EventSystem.SendEvent("PlayerInfoModel_SetAssistantCoachExpCurrency", self.data.ace)
    self:OnPlayerInfoChanged()
end

-- 助理教练经验书
function PlayerInfoModel:SetMorale(morale)
    self.data.morale = tonumber(morale)
    EventSystem.SendEvent("PlayerInfoModel_SetMoraleCurrency", self.data.morale)
    self:OnPlayerInfoChanged()
end

-- 助理教练经验书
function PlayerInfoModel:SetFight(fight)
    self.data.fight = tonumber(fight)
    EventSystem.SendEvent("PlayerInfoModel_SetFightCurrency", self.data.fight)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetPeakDiamond(diamond)
    self.data.pp = tonumber(diamond)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetHonorDiamond(diamond)
    self.data.h = tonumber(diamond)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetDreamPoint(point)
    self.data.dp = tonumber(point)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetLadderPoint(lp)
    self.data.lp = tonumber(lp)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:IsVip14()
    return tonumber(self:GetVipLevel()) >= self.HonorDiamondLvl
end

function PlayerInfoModel:SetBlackDiamond(bDiamond)
    local consumeBdNumber = tonumber(self.data.bkd) - tonumber(bDiamond)
    self.data.bkd = tonumber(bDiamond)
    self:OnPlayerInfoChanged()

    EventSystem.SendEvent("ConsumeBlackDiamond", consumeBdNumber)
end

function PlayerInfoModel:SetStrength(sp)
    self.data.sp = tonumber(sp)
    EventSystem.SendEvent("Refresh_Strength")
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetName(name)
    self.data.name = tostring(name)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetTeamLogo(logo)
    self.data.logo = logo
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetShowHonorList(honorList)
    self.data.honor = honorList
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetTrophyNum(trophyNum)
    self.data.honorCupNum = trophyNum
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetFriendsCount(friendsCount)
    self.data.friendsCount = friendsCount
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetStardustCount(sd)
    self.data.sd = sd
    EventSystem.SendEvent("ConsumeStardust", sd)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetBenedictionCount(bs)
    self.data.bs = bs
    EventSystem.SendEvent("ConsumeBenediction", bs)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetVipLevel(lvl)
    if not self.data.vip then 
        self.data.vip = {}
    end
    if tonumber(self:GetVipLevel()) < lvl then
        luaevt.trig("HoolaiBISendMilestone", "vip", lvl)
        EventSystem.SendEvent("VIPLevelUpInVIPPage", lvl)
    end
    self.data.vip.lvl = lvl
    EventSystem.SendEvent("VIPLevelUpEnd", lvl)
end

--[梦幻卡]梦幻碎片
function PlayerInfoModel:SetFancyPiece(fancyPiece)
    self.data.fancyPiece = tonumber(fancyPiece)
    EventSystem.SendEvent("PlayerInfo", self)
end

--[梦幻卡]球魂
function PlayerInfoModel:SetFs(fs)
    self.data.fs = tonumber(fs)
    EventSystem.SendEvent("PlayerInfo", self)
end

--荣誉币根据充值积分进行转换
PlayerInfoModel.HonorDiamondLvl = 14 -- 超过vip14赠与荣耀币
PlayerInfoModel.DiamondToHonorDiamond = 0.1 -- 钻石与荣耀币汇率
function PlayerInfoModel:SetVipCost(cost, VIPModel)
    if not self.data.vip then 
        self.data.vip = {}
    end
    local addDiamondNumber = nil
    if self.data.vip.d then
        if self:IsVip14() then
            local threshold = VIPModel[self.HonorDiamondLvl].cumDiamond
            local currVipDiamond = tonumber(self.data.vip.d)
            -- 超过vip14部分的钻石转换成荣耀币
            addDiamondNumber = tonumber(cost) - math.clamp(currVipDiamond, threshold, currVipDiamond)
            self.data.h = tonumber(self.data.h) + math.floor(addDiamondNumber * self.DiamondToHonorDiamond)
        end
    end
    EventSystem.SendEvent("PayAddDiamond", addDiamondNumber)
    self.data.vip.d = cost
end

-- 判断欲消的该类型的货币是否充足
function PlayerInfoModel:IsCostEnough(cType, cost)
    cost = math.clamp(cost, 0, cost)
    local curr_num = 0
    if cType == CurrencyType.Money then
        curr_num = self:GetMoney()
    elseif cType == CurrencyType.Diamond then
        curr_num = self:GetDiamond()
    elseif cType == CurrencyType.BlackDiamond then
        curr_num = self:GetBlackDiamond()
    elseif cType == CurrencyType.Fight then
        curr_num = self:GetFight()
    elseif cType == CurrencyType.Morale then
        curr_num = self:GetMorale()
    end
    return curr_num - cost >= 0
end

------------
-- 消费钻石或金币时，服务器固定格式
-- cost = {
--     curr_num = 100, -- 当前剩余
--     num = 6400, -- 本次消耗
--     type = "d", -- 货币类型
-- }
------------
function PlayerInfoModel:CostDetail(cost)
    assert(type(cost) == "table")
    if cost.type == nil then return end
    if cost.curr_num == nil then return end
    if cost.num == nil then return end

    local cType = cost.type -- 货币类型
    local pre_num = 0
    local cost_num = cost.num -- 消耗数
    local curr_num = cost.curr_num -- 服务器告知的消耗剩余
    local callBack = nil

    if cType == CurrencyType.Money then
        pre_num = self:GetMoney()
        callBack = function() self:SetMoney(curr_num) end
    elseif cType == CurrencyType.Diamond then
        pre_num = self:GetDiamond()
        callBack = function() self:SetDiamond(curr_num) end
    elseif cType == CurrencyType.BlackDiamond then
        pre_num = self:GetBlackDiamond()
        callBack = function() self:SetBlackDiamond(curr_num) end
    elseif cType == CurrencyType.Fight then
        pre_num = self:GetFight()
        callBack = function() self:SetFight(curr_num) end
    end

    self:CheckCostNum(pre_num, cost_num, curr_num, callBack)
end

function PlayerInfoModel:CheckCostNum(pre, cost, curr, callBack)
    if math.clamp(pre - cost, 0, pre) ~= curr then
        dump("invalid cost input")
        return
    else
        if callBack ~= nil and type(callBack) == "function" then
            callBack()
        end
    end
end

-- uniformType可以为TeamUniformModel.UniformType.Home, TeamUniformModel.UniformType.Away, TeamUniformModel.UniformType.Gk
function PlayerInfoModel:SetTeamUniform(uniformType, data)
    if type(self.data.shirt) ~= "table" then
        self.data.shirt = {}
    end
    self.data.shirt[uniformType] = data
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:SetSmallTeamUniform(id)
    if type(self.data.shirt) ~= "table" then
        self.data.shirt = {}
    end
    self.data.shirt.small = id
end

function PlayerInfoModel:SetGkSmallTeamUniform(id)
    if type(self.data.shirt) ~= "table" then
        self.data.shirt = {}
    end
    self.data.shirt.gkSmall = id
end

function PlayerInfoModel:SetFriendshipPoint(fp)
    self.data.fp = tonumber(fp)
    EventSystem.SendEvent("FriendsShipChanged", self)
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:ClearTeamUniform()
    self.data.shirt = nil
end

function PlayerInfoModel:SetSpectators(spectators)
    self.data.spectators = spectators
end

-- 从奖励中增加
function PlayerInfoModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    -- 金钱
    if rewardTable.m and tonumber(rewardTable.m) > 0 then
        self.data.m = tonumber(self.data.m) + tonumber(rewardTable.m)
    end
    -- 钻石
    if rewardTable.d and tonumber(rewardTable.d) > 0 then
        self:AddDiamond(tonumber(rewardTable.d))
    end
    -- 友情点
    if rewardTable.fp and tonumber(rewardTable.fp) > 0 then
        self.data.fp = tonumber(self.data.fp) + tonumber(rewardTable.fp)
    end
    -- 天梯荣誉
    if rewardTable.lp and tonumber(rewardTable.lp) > 0 then
        self:AddLadderPoint(tonumber(rewardTable.lp))
    end
    -- 星辰
    if rewardTable.sd and tonumber(rewardTable.sd) > 0 then
        self:AddStardustCount(tonumber(rewardTable.sd))
    end
    -- 祝福
    if rewardTable.bs and tonumber(rewardTable.bs) > 0 then
        self:AddBenedictionCount(tonumber(rewardTable.bs))
    end
    -- 巅峰币
    if rewardTable.pp and tonumber(rewardTable.pp) > 0 then
        self:AddPeakPointCount(tonumber(rewardTable.pp))
    end
    -- 争霸赛产出货币
    if rewardTable.wtc and tonumber(rewardTable.wtc) > 0 then
        self:AddCompeteCurrency(tonumber(rewardTable.wtc))
    end

    if rewardTable.exp then
        if rewardTable.exp.exp then
            self.data.exp = tonumber(rewardTable.exp.exp)
        end
        if rewardTable.exp.sp then
            self.data.sp = tonumber(rewardTable.exp.sp)
        end
        local level = tonumber(rewardTable.exp.lvl)
        if level then
            if self.data.lvl and self.data.lvl < level then
                local levelData = {}
                levelData.befLvl = self.data.lvl
                levelData.aftLvl = level
                levelData.befSp = rewardTable.exp.sp - rewardTable.exp.addSp
                levelData.aftSp = rewardTable.exp.sp
                self.data.lvl = level

                local levelUpLock = cache.getLevelUpLock()
                if levelUpLock then
                    cache.setLevelUpData(levelData)
                else
                    EventSystem.SendEvent("UserLevelUp", levelData)
                end
            else
                self.data.lvl = level
            end
            EventSystem.SendEvent("LevelChange")
        end
    end
    -- 体力
    if rewardTable.sp and tonumber(rewardTable.sp) > 0 then
        self.data.sp = tonumber(self.data.sp) + tonumber(rewardTable.sp)
    end
    -- 公会荣誉
    if rewardTable.gh and tonumber(rewardTable.gh) > 0 then
        self.data.gh = tonumber(self.data.gh) + tonumber(rewardTable.gh)
    end

    -- 日文版专用
    if rewardTable.csp and tonumber(rewardTable.csp) > 0 then
        self.data.csp = tonumber(self.data.csp) + tonumber(rewardTable.csp)
    end

    -- 中文版专用
    -- VIP等级升级
    if rewardTable.vip and rewardTable.vip.lvl then
        if not self.data.vip then self.data.vip = {} end

        if rewardTable.vip.lvl > (self.data.vip and self.data.vip.lvl or 0) then
            self.data.vip.lvl = rewardTable.vip.lvl

            local isLock = cache.getVIPLevelUpLock()
            if isLock then
                cache.setVIPLevelUpData(rewardTable.vip.lvl)
            else
                EventSystem.SendEvent("VIPLevelUp", rewardTable.vip.lvl)
            end
        end
    end

    -- 梦幻币
    if rewardTable.dc and tonumber(rewardTable.dc) > 0 then
        self.data.dc = tonumber(self.data.dc) + tonumber(rewardTable.dc)
    end

    -- 梦幻碎片
    if rewardTable.dp and tonumber(rewardTable.dp) > 0 then
        self.data.dp = tonumber(self.data.dp) + tonumber(rewardTable.dp)
    end

    -- 殿堂精华
    if rewardTable.smd and tonumber(rewardTable.smd) > 0 then
        self:AddHeroHallSmdCurrency(tonumber(rewardTable.smd))
    end
    -- 殿堂升阶石
    if rewardTable.smb and tonumber(rewardTable.smb) > 0 then
        self:AddHeroHallSmbCurrency(tonumber(rewardTable.smb))
    end
    -- 执教经验书
    if rewardTable.ce and tonumber(rewardTable.ce) > 0 then
        self:AddCredentialExp(tonumber(rewardTable.ce))
    end
    -- 教练天赋点
    if rewardTable.ctp and tonumber(rewardTable.ctp) > 0 then
        self:AddCoachTalentPoint(tonumber(rewardTable.ctp))
    end
    -- 助理教练经验书
    if rewardTable.ace and tonumber(rewardTable.ace) > 0 then
        self:AddAssistantCoachExp(tonumber(rewardTable.ace))
    end
    -- [绿茵征途]士气
    if rewardTable.morale and tonumber(rewardTable.morale) > 0 then
        self:AddMorale(tonumber(rewardTable.morale))
    end
    -- [绿茵征途]斗志
    if rewardTable.fight and tonumber(rewardTable.fight) > 0 then
        self:AddFight(tonumber(rewardTable.fight))
    end
    -- [梦幻卡]球魂
    if rewardTable.fs and tonumber(rewardTable.fs) > 0 then
        self:AddFS(tonumber(rewardTable.fs))
    end
    -- [梦幻卡]梦幻卡碎片
    if rewardTable.fancyPiece and tonumber(rewardTable.fancyPiece) > 0 then
        self:AddFancyPiece(tonumber(rewardTable.fancyPiece))
    end

    -- TODO : add others

    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:OnPlayerInfoChanged()
    EventSystem.SendEvent("PlayerInfo", self)
end

-- 是否已经向cache中缓存过数据
function PlayerInfoModel:IsCached()
    return self.data ~= nil
end

-- 是否开启转会市场
function PlayerInfoModel:IsTransferOpen()
    local levelLimitTable = LevelLimit["transfer"]
    return self:GetLevel() >= levelLimitTable.playerLevel
end

function PlayerInfoModel:IsLeagueOpen()
    local levelLimitTable = LevelLimit["league"]
    return self:GetLevel() >= levelLimitTable.playerLevel
end

function PlayerInfoModel:IsTrainOpen()
    local levelLimitTable = LevelLimit["littleGame"]
    return self:GetLevel() >= levelLimitTable.playerLevel
end

function PlayerInfoModel:IsCardSkillLevelUpOpen()
    local levelLimitTable = LevelLimit["skillLvlUp"]
    return self:GetLevel() >= levelLimitTable.playerLevel
end

--- 设置升级锁，满足升级条件时不发送升级事件
function PlayerInfoModel:LockLevelUp()
    cache.setLevelUpLock(true)
end

--- 解锁升级锁
-- @return 是否升级
function PlayerInfoModel:UnlockLevelUp()
    cache.setLevelUpLock(false)
    local levelUpData = cache.getLevelUpData()
    local isLevelUp = false
    if levelUpData ~= nil then
        isLevelUp = true
        EventSystem.SendEvent("UserLevelUp", levelUpData)
    end
    cache.setLevelUpData()
    return isLevelUp
end

function PlayerInfoModel:LockVIPLevelUp()
    cache.setVIPLevelUpLock(true)
end

function PlayerInfoModel:UnLockVIPLevelUp()
    cache.setVIPLevelUpLock(false)
    local VIPLevel = cache.getVIPLevelUpData()
    if VIPLevel ~= nil then
        EventSystem.SendEvent("VIPLevelUp", VIPLevel)
    end
    cache.setVIPLevelUpData()
end

function PlayerInfoModel:GetLeagueRankPos()
    return self.data.rankPos
end

function PlayerInfoModel:GetLeagueScorePos()
    return self.data.scorePos
end

function PlayerInfoModel:GetCsp()
    return self.data.csp or 0
end

function PlayerInfoModel:SetCsp(num)
    self.data.csp = num
    self:OnPlayerInfoChanged()
end

function PlayerInfoModel:GetChangeNameTimes()
    return tonumber(self.data.changeName)
end

function PlayerInfoModel:AddChangeNameTimes()
    self.data.changeName = self.data.changeName + 1
end

function PlayerInfoModel:GetGuild()
    return self.data.guild
end

function PlayerInfoModel:SetGuild(value)
    self.data.guild = value
end

return PlayerInfoModel
