local GameObjectHelper = require("ui.common.GameObjectHelper")
local LoginModel = require("ui.models.login.LoginModel")
local RankingScrollItemView = class(unity.base)

function RankingScrollItemView:ctor()
    self.districtTxt = self.___ex.districtTxt
    self.pointsTxt = self.___ex.pointsTxt
    self.rankAndNameTxt = self.___ex.rankAndNameTxt
    self.rankInfoObj = self.___ex.rankInfoObj
    self.pointsTipObj = self.___ex.pointsTipObj
    self.pointsTipTxt = self.___ex.pointsTipTxt
    self.deepColorBg = self.___ex.deepColorBg
    self.delicateColorBg = self.___ex.delicateColorBg

    self.mapServers = {}
    self:MakeMapOfServers()
end

function RankingScrollItemView:MakeMapOfServers()
    local servers = LoginModel.GetServers()
    for k, v in pairs(servers) do
        self.mapServers[tostring(v.id)] = v.displayId
    end
end

function RankingScrollItemView:InitView(goldCupModel, itemModel)
    self.goldCupModel = goldCupModel
    self.itemModel = itemModel

    local playerRank = self.itemModel:GetPlayerRank()
    local isPlayerSatisfyCondition = self.itemModel:IsPlayerSatisfyCondition()
    GameObjectHelper.FastSetActive(self.rankInfoObj, isPlayerSatisfyCondition)
    GameObjectHelper.FastSetActive(self.pointsTipObj, not isPlayerSatisfyCondition)
    GameObjectHelper.FastSetActive(self.delicateColorBg, playerRank % 2 == 0)
    GameObjectHelper.FastSetActive(self.deepColorBg, playerRank % 2 ~= 0)

    if isPlayerSatisfyCondition then
        self.rankAndNameTxt.text = self.itemModel:GetPlayerRankAndNameStr()
        self.districtTxt.text = self.mapServers[self.itemModel:GetDistrictID()] or ""
        self.pointsTxt.text = self.itemModel:GetPointsValue()
    else
        local condition = self.goldCupModel:GetConditionWithRank(playerRank)
        self.pointsTipTxt.text = playerRank .. ". " .. lang.transstr("goldCup_desc5", condition)
    end
end

return RankingScrollItemView