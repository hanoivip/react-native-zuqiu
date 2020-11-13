local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local TransportMatchDetailView = class(unity.base)

function TransportMatchDetailView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.comfirmBtn = self.___ex.comfirmBtn
    self.comfirmTxt = self.___ex.comfirmTxt
    self.handBtn = self.___ex.handBtn
    self.autoBtn = self.___ex.autoBtn
    self.upScroll = self.___ex.upScroll
    self.downScroll = self.___ex.downScroll
    self.downItemSpt = self.___ex.downItemSpt
    self.finshArea = self.___ex.finshArea
    self.continueArea = self.___ex.continueArea
    self.rewardArea = self.___ex.rewardArea
    self.selectBtn = self.___ex.selectBtn
    self.selectBtnImg = self.___ex.selectBtnImg
    self.showResultTxt = self.___ex.showResultTxt
end

function TransportMatchDetailView:SetButtonStyle(index)
    for k, v in pairs(self.selectBtnImg) do
        if k == tostring(index) then
            v:SetActive(true)
        else
            v:SetActive(false)
        end
    end
end

function TransportMatchDetailView:start()
    self:BindButtonHandler()
    DialogAnimation.Appear(self.transform, nil)
end

-- 多人劫，胜利了没奖励的情况下，初始化num
local Num = 1000
function TransportMatchDetailView:InitView(matchModel)
    self:ClearItemBox()
    matchTitleData = matchModel:GetMatchResultDataList()
    self.finshArea:SetActive(not matchTitleData.isContinue)
    self.continueArea:SetActive(matchTitleData.isContinue)
    self.downScroll:SetActive(not (#matchTitleData == 1))
    self.isContinue = matchTitleData.isContinue
    if matchTitleData.isContinue then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportMatchDetailItem.prefab")
        self:AddItemBox(obj)
        spt.onInitTeamLogo = self.onInitTeamLogo
        spt:InitView(matchTitleData[1])
        self:SetButtonStyle(matchModel:GetTeamID())
    else
        if #matchTitleData == 1 then
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportMatchDetailFinshItem.prefab")
            self:AddItemBox(obj)
            spt.onInitTeamLogo = self.onInitTeamLogo
            spt:InitView(matchTitleData[1])
        else
            for i=1, #matchTitleData - 1 do
                local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportMatchDetailItem.prefab")
                self:AddItemBox(obj)
                spt.onInitTeamLogo = self.onInitTeamLogo
                spt:InitView(matchTitleData[i])
            end
            self.downItemSpt.onInitTeamLogo = self.onInitTeamLogo
            self.downItemSpt:InitView(matchTitleData[3])
        end

        res.ClearChildren(self.rewardArea.transform)
        local isHaveReward = false

        local num = Num
        if matchTitleData.robberyReward.baseReward then
            for k, v in pairs(matchTitleData.robberyReward.baseReward.contents) do
                if type(v) == "table" then
                    num = v[1].num
                elseif type(v) == "number" then
                    num = v
                end
            end
        end
        --金币
        if num < 1 then
            self.showResultTxt.text = lang.trans("transport_win_challenge_nil_reward_2")
            return
        end
        if matchTitleData.robberyReward.baseReward then
            isHaveReward = true
            local rewardParams = {
                parentObj = self.rewardArea,
                rewardData = matchTitleData.robberyReward.baseReward.contents,
                isShowName = false,
                isReceive = false,
                isShowBaseReward = true,
                isShowCardReward = true,
                isShowDetail = false,
            }
            RewardDataCtrl.new(rewardParams)
        end
        if matchTitleData.robberyReward.specialReward then
            isHaveReward = true
            local rewardParams = {
                parentObj = self.rewardArea,
                rewardData = matchTitleData.robberyReward.specialReward.contents,
                isShowName = false,
                isReceive = false,
                isShowBaseReward = true,
                isShowCardReward = true,
                isShowDetail = false,
            }
            RewardDataCtrl.new(rewardParams)
        end
        if isHaveReward then
            CongratulationsPageCtrl.new(matchTitleData.reward)
            self.showResultTxt.text = lang.trans("transport_robbery_reward_title")
        else
            self.showResultTxt.text = lang.trans("transport_robbery_reward_nil_title")
        end
    end
end

function TransportMatchDetailView:AddItemBox(itemBox)
    itemBox.transform:SetParent(self.upScroll.transform, false)
end

function TransportMatchDetailView:ClearItemBox()
    local count = self.upScroll.transform.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.upScroll.transform:GetChild(count - 1 - i).gameObject)
    end
end

function TransportMatchDetailView:BindButtonHandler()
    self.comfirmBtn:regOnButtonClick(function ()
        if self.onChallengeOver then
            self.onChallengeOver()
        end
    end)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    for k, v in pairs(self.selectBtn) do
        v:regOnButtonClick(function ()
            if self.onChangeStyle then
                self.onChangeStyle(k)
            end
        end)
    end
    self.handBtn:regOnButtonClick(function ()
        if self.onContinueChallenge then
            self.onContinueChallenge()
        end
    end)
    self.autoBtn:regOnButtonClick(function ()
        if self.onContinueChallenge then
            self.onContinueChallenge(1)
        end
    end)
    self.autoBtn:onPointEventHandle(false)

end

function TransportMatchDetailView:Close()
    if self.isContinue then 
        return
    end
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function TransportMatchDetailView:CloseImmediate()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return TransportMatchDetailView
