local CardBuilder = require("ui.common.card.CardBuilder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local PlayerCardCircle = require("ui.scene.formation.PlayerCardCircle")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local CompetePlayerCardCircle = class(PlayerCardCircle)

function CompetePlayerCardCircle:ctor()
    CompetePlayerCardCircle.super.ctor(self)
    -- 战力加成图标
    self.upFlag = self.___ex.upFlag
    -- 战力加成数值
    self.upTxt = self.___ex.upTxt

    -- PlayerCardCircle资源路径
    self.playerCardCirclePath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/CompetePlayerCardCircle.prefab"
end

--- 初始化数据
-- @param dataIndex 球员数据索引，在首发和替补阵容中对应的是球员位置，在候补阵容中对应的是索引index
-- @param pcId 卡牌Id
-- @param showType 卡牌的显示状态，据此决定卡牌上要显示的信息
-- @param playerClassify 在阵型中球员的分类：首发、替补、候补
-- @param isSubstituted 是否是被替换下的球员，仅用于比赛中
function CompetePlayerCardCircle:initData(dataIndex, pcId, showType, playerClassify, formationDataModel, isSubstituted, isDisableTouch, isDisableBeDraged)
    local playerCardModel
    if showType ~= FormationConstants.CardShowType.EMPTY then
        if formationDataModel then
            playerCardModel = CardBuilder.GetFormationCardModel(pcId, formationDataModel)
        else
            playerCardModel = PlayerCardModel.new(pcId)
        end
    end
    local specialEventsMatchId = formationDataModel and formationDataModel.specialEventsMatchId or nil
    local competeSpecialTeamData = formationDataModel and formationDataModel.competeSpecialTeamData or nil
    self:initDataByModel(dataIndex, playerCardModel, showType, playerClassify, isSubstituted, isDisableTouch, isDisableBeDraged, specialEventsMatchId, competeSpecialTeamData)
end

--- 根据PlayerCardModel初始化数据
-- @param dataIndex 球员数据索引，在首发和替补阵容中对应的是球员位置，在候补阵容中对应的是索引index
-- @param playerCardModel 卡牌模型
-- @param showType 卡牌的显示状态，据此决定卡牌上要显示的信息
-- @param playerClassify 在阵型中球员的分类：首发、替补、候补
-- @param isSubstituted 是否是被替换下的球员，仅用于比赛中
function CompetePlayerCardCircle:initDataByModel(dataIndex, playerCardModel, showType, playerClassify, isSubstituted, isDisableTouch, isDisableBeDraged, specialEventsMatchId, competeSpecialTeamData)
    self.dataIndex = dataIndex
    self.playerCardModel = playerCardModel
    self.nowShowType = tonumber(showType)
    self.playerClassify = playerClassify
    self.isSubstituted = isSubstituted or false
    self.isDisableTouch = isDisableTouch or false
    self.isDisableBeDraged = isDisableBeDraged or false
    self.specialEventsMatchId = specialEventsMatchId
    self.competeSpecialTeamData = competeSpecialTeamData
    self:CheckPosIsMatch()
end

--- 构建卡牌
function CompetePlayerCardCircle:BuildCard()
    CompetePlayerCardCircle.super.BuildCard(self)
    self:BuildForCompete()
end

function CompetePlayerCardCircle:GetPowerUpCount()
    if self.competeSpecialTeamData ~= nil then
        return self.competeSpecialTeamData.powerImprove * 0.001
    end
end

-- 获取战力
function CompetePlayerCardCircle:GetPower()
    local power = 0
    if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
        -- 是首发球员
        if self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT then
            local isSuitForCompete = self.playerCardModel:IsSuitForCompete()
            if isSuitForCompete == nil then
                isSuitForCompete = self:CheckIsMatchForCompete()
            end
            if self.competeSpecialTeamData ~= nil and self.posIsMatch == true and isSuitForCompete then
                power = math.floor(self.playerCardModel:GetPower() * self:GetPowerUpCount())
            else
                power = math.floor(self.playerCardModel:GetPower() * (100 - self:GetPowerDiscount()) / 100)
            end
        else
            power = self.playerCardModel:GetPower()
        end
    end
    return power
end

function CompetePlayerCardCircle:CheckIsMatchForCompete()
    if self.competeSpecialTeamData ~= nil and self.playerCardModel ~= nil then
        return self.playerCardModel:CheckIsMatchForCompete(self.competeSpecialTeamData)
    end
end

function CompetePlayerCardCircle:BuildForCompete()
    if self.competeSpecialTeamData ~= nil then
        GameObjectHelper.FastSetActive(self.suggestedBox, false)
        GameObjectHelper.FastSetActive(self.noFlag, false)
        GameObjectHelper.FastSetActive(self.upFlag, false)
        if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
            self:CheckIsMatchForCompete()
            if self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT then
                if self.playerCardModel:IsSuitForCompete() then
                    GameObjectHelper.FastSetActive(self.upFlag, true)
                    self.upTxt.text = tostring(self.competeSpecialTeamData.powerImprove * 0.1) .. "%"
                end
            else
                if self.playerCardModel:IsSuitForCompete() then
                    GameObjectHelper.FastSetActive(self.suggestedBox, true)
                    self.suggestedText.text = lang.trans("compete_formation_player")
                end
            end
        end
    end
end

return CompetePlayerCardCircle