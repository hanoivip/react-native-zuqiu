local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local TurntablePieceView = class(unity.base)

function TurntablePieceView:ctor()
--------Start_Auto_Generate--------
    self.rewardTrans = self.___ex.rewardTrans
    self.itemNameTxt = self.___ex.itemNameTxt
    self.disableGo = self.___ex.disableGo
    self.selectGo = self.___ex.selectGo
    self.posAreaTrans = self.___ex.posAreaTrans
--------End_Auto_Generate----------
    self.currencyItemPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Turntable/RewardCurrencyItem.prefab"
end

function TurntablePieceView:InitView(pieceData)
    local status = pieceData.statu
    local isAccept = pieceData.isAccept
    local contents = pieceData.contents

    res.ClearChildren(self.rewardTrans)
    self:SetAcceptPieceState(isAccept)
    local rewardParams = {
        parentObj = self.rewardTrans,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = false,
        isHideLvl = true,
    }
    RewardDataCtrl.new(rewardParams)
    local itemName = RewardNameHelper.GetSingleContentName(contents)
    local first = string.sub(itemName, 1, 1)
    if first == " " then
        itemName = string.sub(itemName, 2, string.len(itemName))
    end
    if contents.morale or contents.fight then
        local nameColor = ""
        local plusSign = ""
        if status == 1 then
            plusSign = " +"
            nameColor = "#C7ED54FF>"
        else
            plusSign = " -"
            nameColor = "#FF6F6FFF>"
        end
        local num = contents.morale or contents.fight
        itemName = itemName .. "<color=" .. nameColor .. plusSign ..num .. "</color>"
    end
    self.itemNameTxt.text = itemName
end

function TurntablePieceView:SetPieceState(state)
    GameObjectHelper.FastSetActive(self.selectGo, state)
end

function TurntablePieceView:SetAcceptPieceState(isAccept)
    GameObjectHelper.FastSetActive(self.disableGo, isAccept)
    GameObjectHelper.FastSetActive(self.selectGo, false)
end

return TurntablePieceView
