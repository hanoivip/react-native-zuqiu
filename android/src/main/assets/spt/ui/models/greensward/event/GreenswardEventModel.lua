local AdventureEvent = require("data.AdventureEvent")
local AdventureFloor = require("data.AdventureFloor")
local AdventureEventTips = require("data.AdventureEventTips")
local AdventureRewardBase = require("data.AdventureRewardBase")
local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardEventActionEffectHelper = require("ui.models.greensward.event.GreenswardEventActionEffectHelper")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local Model = require("ui.models.Model")

local GreenswardEventModel = class(Model, "GreenswardEventModel")

--/// <summary>
--10.无法解锁——迷雾
--20.可解锁——带特效的迷雾
--15.高级怪影响的无法解锁——雷雨缭绕地块
--40.可视但无法直接进行操作的状态(无迷雾)：士气怪
--50.无法解锁，但有特殊标志提示——迷雾上边放个特殊标识(特殊BOSS小BOSS，对应普通事件状态10)
--55.直接可视，无任何操作(入口飞机场)
--60.BOSS脚踩飞机场，上来就可见无迷雾，但无法攻打BOSS
--65.可解锁——带特效带特殊标识的迷雾(特殊BOSS小BOSS，对应普通事件状态20)
--70.已解锁——无迷雾，格子上的事件可进行操作
--75.BOSS打掉后出口飞机场完整露出，可进行操作(出口飞机场)
--80.点出放大镜
--90.触发宝物大盗，可打可不打。攻打胜利后变为状态100
--100.事件完成后图标消失，恢复为空地块
--/// </summary>

GreenswardEventModel.EventStatus =
{
    Lock = 10,
    Unlock = 20,
    Lock_Effect = 15,
    ViewAndNotCtrl = 40,
    LockWithSign = 50,
    View = 55,
    ViewWithEvent = 60,
    UnlockWithSign = 65,
    BeOperable = 70,
    NeedEvent = 75,
    Observation = 80,
    TrigEvent = 90,
    Over = 100
}

--///消耗类型 <summary>
--(1为无任何消耗，2为士气，3为斗志，4为道具，5为士气斗志任选，6为士气道具任选，7为斗志道具任选，8为士气斗志道具任选)
--/// </summary>
GreenswardEventModel.ConsumeType =
{
    None = 1,
    Morale = 2,
    Power = 3,
    Item = 4,
    MoraleAndPower = 5,
    MoraleAndItem = 6,
    PowerAndItem = 7,
    All = 8
}

function GreenswardEventModel:ctor()
    GreenswardEventModel.super.ctor(self)
    self.isOpen = false 
    self.isIconKeep = false
    self.uiParam = {}
    self.tips = "" --事件提示
    self.passTips = "" -- 事件完成提示
    self.ctrlPath = ""
end

function GreenswardEventModel:InitData(key, data, buildModel)
    local group = string.split(key, '_')
    self.key = key
    self.data = data or {}
    self.staticData = AdventureEvent[tostring(self.data.type)]
    self.row = tonumber(group[1])
    self.col = tonumber(group[2])
    self.buildModel = buildModel
end

function GreenswardEventModel:RefreshData(data)
    self.data = data
end

function GreenswardEventModel:GetData()
    return self.data
end

function GreenswardEventModel:GetStaticData()
    return self.staticData
end

function GreenswardEventModel:GetEffectPos()
    local effectPos = {}
    local rP = tostring(self.row) .. "_" .. tostring(self.col + 1)
    local lP = tostring(self.row) .. "_" .. tostring(self.col - 1)
    local uP = tostring(self.row - 1) .. "_" .. tostring(self.col)
    local dP = tostring(self.row + 1) .. "_" .. tostring(self.col)
    table.insert(effectPos, rP)
    table.insert(effectPos, lP)
    table.insert(effectPos, uP)
    table.insert(effectPos, dP)
    return effectPos
end

-- 获取main model
function GreenswardEventModel:GetBuildModel()
    return self.buildModel
end

-- 对应格子第几行（从0开始）
function GreenswardEventModel:GetRow()
    return self.row
end

-- 对应格子第几列（从0开始）
function GreenswardEventModel:GetCol()
    return self.col
end

-- 获取基础图片
function GreenswardEventModel:GetBasePic()
    local basePic = self.data.base
    if not basePic or basePic == "" then
        basePic = "Grass1"
    end
    return basePic
end

-- 获取对手基础图标
function GreenswardEventModel:GetOpponentPic()
    local opRes = self.data.opView or {}
    return opRes
end

function GreenswardEventModel:GetKey()
    return self.key
end

function GreenswardEventModel:GetData()
    return self.data
end

-- 事件ID
function GreenswardEventModel:GetEventId()
    return self.data.type
end

-- 事件当前进度
function GreenswardEventModel:GetCurrentState()
    return self.data.st
end

function GreenswardEventModel:SetCurrentState(st)
    self.data.st = st
end

-- 是否有道具影响过该事件
function GreenswardEventModel:GetImpactResult()
    return self.data.rr or 0
end

function GreenswardEventModel:GetEventName()
    return self.staticData.eventName
end

function GreenswardEventModel:GetPicIndex()
    return self.staticData.picIndex
end

function GreenswardEventModel:GetConsumeType()
    return self.staticData.consumeType
end

function GreenswardEventModel:GetUseItemTip()
    return lang.trans("adventure_use_item_tip1")
end

function GreenswardEventModel:GetConsumeMorale(index)
    index = index or 1
    local starSymbol = 0
    local consumeMorale = self.staticData.consumeMorale or {}
    local consumeNum = tonumber(consumeMorale[index] or 0)
    consumeNum, starSymbol = self.buildModel:GetStarEffectMoraleNum(consumeNum)
    return consumeNum, starSymbol
end

-- 星象引起的消耗颜色变化
function GreenswardEventModel:GetConvertColor(starSymbol)
    if starSymbol == 0 then
        return 216, 204, 10
    elseif starSymbol == 1 then
        return 255, 0, 0
    elseif starSymbol == -1 then
        return 101, 210, 3
    else
        return 255, 255, 255
    end
end

function GreenswardEventModel:GetConsumeFight()
    local consumeFightArray = self.staticData.consumeFight or {}
    local currentFloor = self:GetCurrentFloor()

    local consumeFight = consumeFightArray[currentFloor] or 0
    return tonumber(consumeFight)
end

-- 获得可消耗道具通过该事件的道具列表
function GreenswardEventModel:GetConsumeItem()
    return self.staticData.consumeItem
end

-- 目前一个事件仅允许使用一种道具通过
-- 本函数获得配置中第1个数量满足配置数量的道具id
function GreenswardEventModel:GetConsumeItemId()
    local consumeItem = self:GetConsumeItem()
    if not table.isEmpty(consumeItem) then
        itemMapModel = GreenswardItemMapModel.new()
        for k, v in ipairs(consumeItem) do
            return tostring(v.id)
        end
    end
    return nil
end

-- 是否有配置的道具可以通过该事件且玩家拥有配置的道具
function GreenswardEventModel:CanConsumeItemFill()
    local consumeItem = self:GetConsumeItem()
    local hasItem = false
    if type(consumeItem) == "table" then
        hasItem = GreenswardItemMapModel.new():HasItemFill(consumeItem)
    end
    return not table.isEmpty(consumeItem) and hasItem
end

-- 获得可影响该事件的道具列表
function GreenswardEventModel:GetImpactItem()
    return self.staticData.impactItem
end

-- 是否有配置道具影响该事件且玩家拥有配置的道具
function GreenswardEventModel:CanImpactItemFill()
    local impactItem = self:GetImpactItem()
    local hasItem = false
    if type(impactItem) == "table" then
        hasItem = GreenswardItemMapModel.new():HasItemFill(impactItem)
    end
    return not table.isEmpty(impactItem) and hasItem
end

-- 获得通过该事件必需的道具列表，没有该道具在状态70操作无任何反应
function GreenswardEventModel:GetEssentialItem()
    return self.staticData.needItem
end

-- 是否有配置必需道具且玩家拥有配置道具
-- 若配置道具有其他需求，如藏宝图要求层数，请继承覆盖
function GreenswardEventModel:CanEssentialItemFill()
    local needItem = self:GetEssentialItem()
    local hasItem = false
    if type(needItem) == "table" then
        hasItem = GreenswardItemMapModel.new():HasItemFill(needItem)
    end
    return not table.isEmpty(needItem) and hasItem
end

function GreenswardEventModel:GetPicIndex()
    return self.staticData.picIndex
end

function GreenswardEventModel:GetEventIcon()
    return self.staticData.eventIndex
end

function GreenswardEventModel:HasEffectEvent()
    return tobool(tonumber(self.staticData.effect) == 1)
end

function GreenswardEventModel:HasWeatherEffectEvent()
    return tobool(tonumber(self.staticData.effect) == 2)
end

function GreenswardEventModel:GetEffectText()
    return ""
end

-- 特殊事件在云上有特效
function GreenswardEventModel:GetCloudEffectRes()
    local st = self:GetCurrentState()
    if tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect) then
        return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectLight.prefab"
    else
        return nil
    end
end

function GreenswardEventModel:GetStarEffectCondition()
    local starModel = self.buildModel:GetStarModel()

    local hasEffect = false
    local starDesc = lang.transstr("none")
    if starModel then
        hasEffect = starModel:CheckHasEffect(self:GetEventId())
        starDesc = hasEffect and starModel:GetDesc() or lang.transstr("none")
    end
    return hasEffect, starDesc
end

function GreenswardEventModel:GetChallengeText()
    return lang.trans("adventure_challenge_tip")
end

-- 在事件额外表示的时候处理操作（例如事件完成后再次点击提示）
function GreenswardEventModel:HandleEventExtension()

end

-- 在没有事件时，格子点击操作（例如 雷云等）
function GreenswardEventModel:HandleClickEvent()
    local st = self:GetCurrentState()
    if tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect) then 
        DialogManager.ShowToast(lang.trans("thunderstorm_tip"))
    end
end

-- 是否达到策划配置的完成度
function GreenswardEventModel:IsReachCompleteRate()
    return tonumber(self:GetCurrentState()) == tonumber(self.staticData.completeRate)
end

function GreenswardEventModel:GetDescMap()
    return self.staticData.desc or {}
end

function GreenswardEventModel:GetDescText()
    local descMap = self:GetDescMap()
    local st = self:GetCurrentState()
    local descIndex = descMap[tostring(st)]
    local desc = ""
    if descIndex then
        desc = AdventureEventTips[tostring(descIndex)].desc or AdventureEventTips[tonumber(descIndex)].desc or  ""
    end

    return desc
end

function GreenswardEventModel:HasReward()
    return tonumber(self.staticData.reward) ~= 0
end

function GreenswardEventModel:GetReward()
    local reward = tonumber(self.staticData.reward)
    local rewardData = AdventureRewardBase[tostring(reward)] or {}
    return rewardData.contents
end

-- 是否开启
function GreenswardEventModel:IsOpen()
    return self.isOpen
end

-- 是否保留事件图标
function GreenswardEventModel:IsIconKeep()
    return self.isIconKeep
end

-- 是否可以操作
function GreenswardEventModel:IsOperable()
    local st = self:GetCurrentState()
    return tobool(tonumber(st) == GreenswardEventModel.EventStatus.BeOperable)
end

-- 是否可以显示事件信息
function GreenswardEventModel:IsShowDialog()
    local st = self:GetCurrentState()
    return tobool(tonumber(st) == GreenswardEventModel.EventStatus.BeOperable) or
            tobool(tonumber(st) == GreenswardEventModel.EventStatus.ViewAndNotCtrl) or
            tobool(tonumber(st) == GreenswardEventModel.EventStatus.ViewWithEvent)
end

-- 是否为源点
function GreenswardEventModel:IsOriginPoint()
    return false
end

-- 是否保存事件图标
function GreenswardEventModel:IsPreserveEvent()
    return false
end

-- 事件是否结束
function GreenswardEventModel:IsTheEventOver()
    local st = self:GetCurrentState()
    return tobool(tonumber(st) == GreenswardEventModel.EventStatus.Over)
end

-- 是否带事件操作
function GreenswardEventModel:HasEvent()
    return false
end

-- 是否可以解锁清除迷雾状态
function GreenswardEventModel:HasUnlock()
    local st = self:GetCurrentState()
    return tobool(tonumber(st) == GreenswardEventModel.EventStatus.Unlock) or
            tobool(tonumber(st) == GreenswardEventModel.EventStatus.UnlockWithSign)
end

-- 是否带迷雾
function GreenswardEventModel:HasFog()
    local st = self:GetCurrentState()
    local hasFog = tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock) or
            tobool(tonumber(st) == GreenswardEventModel.EventStatus.Unlock) or
            tobool(tonumber(st) == GreenswardEventModel.EventStatus.LockWithSign) or
            tobool(tonumber(st) == GreenswardEventModel.EventStatus.UnlockWithSign) or
            tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect)
    return hasFog
end

function GreenswardEventModel:GetFogRes()
    local st = self:GetCurrentState()
    if tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect) then
        return "Cloud2"
    else
        return "Cloud1"
    end
end

--///uiParam <summary> 美术资源大小和中心点不一样，调整美观
--{
--	icon_pos = {x = , y = , z = }
--	icon_size = {x = , y = }
--	icon_rotation = {x = , y = , z = }
--	icon_scale = {x = , y = , z = }
--}
--///uiParam </summary>
function GreenswardEventModel:SetUIParam(uiParam)
    self.uiParam = uiParam
end

function GreenswardEventModel:GetUIParam()
    return self.uiParam
end

function GreenswardEventModel:GetTip()
    return self.tips
end

function GreenswardEventModel:SetTip(tip)
    self.tips = tip
end

function GreenswardEventModel:GetPassTip()
    return self.passTips
end

function GreenswardEventModel:SetPassTip(passTips)
    self.passTips = passTips
end

-- 获得事件名字边框
function GreenswardEventModel:GetNameBorderName()
    return "Name_Border"
end

-- 事件名字颜色
function GreenswardEventModel:GetNameColorParam()
    return 255, 255, 255
end

-- 获取事件标记
function GreenswardEventModel:GetSignPrefabName()
    return nil
end

function GreenswardEventModel:ConsumeByMorale()
    local consumeType = self:GetConsumeType()
    return tobool(consumeType == GreenswardEventModel.ConsumeType.Morale) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.MoraleAndPower) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.MoraleAndItem) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.All)
end

function GreenswardEventModel:ConsumeByPower()
    local consumeType = self:GetConsumeType()
    return tobool(consumeType == GreenswardEventModel.ConsumeType.Power) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.MoraleAndPower) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.PowerAndItem) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.All)
end

function GreenswardEventModel:ConsumeByItem()
    local consumeType = self:GetConsumeType()
    return tobool(consumeType == GreenswardEventModel.ConsumeType.Item) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.MoraleAndItem) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.PowerAndItem) or
            tobool(consumeType == GreenswardEventModel.ConsumeType.All)
end

-- 判断道具是否与本事件有关
-- 包括配置中的consumeItem, impactItem, needItem
function GreenswardEventModel:IsItemCorrelation(id)
    id = tostring(id)
    local flag = false
    local consumeItem = self:GetConsumeItem() or {}
    for k, config in ipairs(consumeItem) do
        if id == tostring(config.id) then
            flag = true
            break
        end
    end
    if not flag then
        local impactItem = self:GetImpactItem() or {}
        for k, config in ipairs(impactItem) do
            if id == tostring(config.id) then
                flag = true
                break
            end
        end
    end
    if not flag then
        local needItem = self:GetEssentialItem() or {}
        for k, config in ipairs(needItem) do
            if id == tostring(config.id) then
                flag = true
                break
            end
        end
    end
    return flag
end

-- 获取解锁积分
function GreenswardEventModel:GetBlockPoint()
    local floorData = self:GetAdventureFloorData()
    local blockPoint = floorData.blockPoint or 0
    return blockPoint
end

function GreenswardEventModel:GetAdventureFloorData()
    local curFloor = self.buildModel:GetCurrentFloor()
    local floorData = AdventureFloor[tostring(curFloor)] or {}
    return floorData
end

function GreenswardEventModel:GetCurrentFloor()
    local curFloor = self.buildModel:GetCurrentFloor()
    return curFloor
end

function GreenswardEventModel:GetTotalFloor()
    local totalFloor = self.buildModel:GetTotalFloor()
    return totalFloor
end

function GreenswardEventModel:GetMoraleEffectTriggerData()
    local floorData = self:GetAdventureFloorData()
	return tonumber(floorData.moraleDownCycle), tonumber(floorData.moraleMonsterMoraleDown)
end

-- 设置底板使用资源名称
function GreenswardEventModel:SetBottomBoardName(bgName)
    self.bottomBoardName = bgName
end

function GreenswardEventModel:GetBottomBoardName(bgName)
    return self.bottomBoardName
end

function GreenswardEventModel:SetDialogCtrl(ctrlPath)
    self.ctrlPath = ctrlPath
end

function GreenswardEventModel:GetDialogCtrl()
    return self.ctrlPath
end

-- 点击判断的时候只有一种需求道具
function GreenswardEventModel:ConsumeNotEnough()
    local notEnough = false

    if self:ConsumeByMorale() then
        notEnough = self:HasMoraleConsumeNotEnough()
    elseif self:ConsumeByPower() then
        notEnough = self:HasFightConsumeNotEnough()
    end

    return notEnough
end

function GreenswardEventModel:HasMoraleConsumeNotEnough()
    local notEnough = false
    local consumeByMorale = self:ConsumeByMorale()
    if consumeByMorale then
        local needMoraleNum = self:GetConsumeMorale()
        local buildModel = self:GetBuildModel()
        local ownerMoraleNum = buildModel:GetMoraleNum()
        if needMoraleNum > ownerMoraleNum then
            notEnough = true
            local titleText = lang.trans("tips")
            local contentText = lang.trans("need_morale_enough2")
            local callback = function() res.PushDialog("ui.controllers.greensward.GreenswardMoraleDialogCtrl", buildModel) end
            DialogManager.ShowMessageBox(titleText, contentText, callback)
        end
    end
    return notEnough
end

function GreenswardEventModel:HasFightConsumeNotEnough()
    local notEnough = false
    local consumeByPower = self:ConsumeByPower()
    if consumeByPower then
        local needPowerNum = self:GetConsumeFight()
        local buildModel = self:GetBuildModel()
        local ownerPowerNum = buildModel:GetPowerNum()
        if needPowerNum > ownerPowerNum then
            notEnough = true
            DialogManager.ShowToast(lang.trans("need_power_enough"))
        end
    end
    return notEnough
end

-- 是否带动效
function GreenswardEventModel:HasTweenExtension()
    return false
end

function GreenswardEventModel:CreatePingPongExtensions(transform, posY, time)
    return GreenswardEventActionEffectHelper.CreatePingPongExtensions(transform, posY, time)
end

function GreenswardEventModel:CreateFadeOutExtensions(canvasGroup)
    return GreenswardEventActionEffectHelper.CreateFadeOutExtensions(canvasGroup)
end

function GreenswardEventModel:CreateFadeInExtensions(canvasGroup)
    return GreenswardEventActionEffectHelper.CreateFadeInExtensions(canvasGroup)
end

function GreenswardEventModel:DestroyExtensions(tween)
    GreenswardEventActionEffectHelper.DestroyExtensions(tween)
end

function GreenswardEventModel:TriggerEvent()

end

function GreenswardEventModel:HandleEvent()

end

return GreenswardEventModel