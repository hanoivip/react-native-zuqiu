local Model = require("ui.models.Model")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local CoachItemBaseModel = require("ui.models.coach.common.CoachItemBaseModel")
local PlayerTalentFunctionalityItem = require("data.PlayerTalentFunctionalityItem")

local CoachPlayerTalentFuncItemModel = class(CoachItemBaseModel, "CoachPlayerTalentFuncItemModel")

function CoachPlayerTalentFuncItemModel:ctor()
    CoachPlayerTalentFuncItemModel.super.ctor(self)
end

function CoachPlayerTalentFuncItemModel:GetStaticConfig(id)
    return PlayerTalentFunctionalityItem[tostring(id)] or {}
end

-- 获得图标的背景栏
function CoachPlayerTalentFuncItemModel:GetPicBackGround()
    return self.staticData.picBackGround
end

function CoachPlayerTalentFuncItemModel:GetIconIndex()
    return self.staticData.picIndex
end

-- 物品类型（1为锁定型道具，2为增加型道具，3为指定替换道具，4为选择替换道具）
function CoachPlayerTalentFuncItemModel:GetItemFunction()
    return self.staticData.itemFunction
end

-- 道具可作用的数量
function CoachPlayerTalentFuncItemModel:GetItemFunctionAmount()
    return self.staticData.itemFunctionAmount
end

-- 显示在玩家选择该道具后，面板上的描述
function CoachPlayerTalentFuncItemModel:GetPageDesc()
    return self.staticData.pageDesc
end

-- 教练商城上线时基础价格
function CoachPlayerTalentFuncItemModel:GetBaseMallPrice()
    return self.staticData.baseMallPrice
end

-- 获取特定描述
function CoachPlayerTalentFuncItemModel:GetPageDesc()
    return self.staticData.pageDesc
end

return CoachPlayerTalentFuncItemModel
