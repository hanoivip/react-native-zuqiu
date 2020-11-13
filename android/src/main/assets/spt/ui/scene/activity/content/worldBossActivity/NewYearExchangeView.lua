local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local WorldBossItem = require("data.WorldBossItem")
local WorldBossItem = require("data.WorldBossItem")
local EventSystem = require("EventSystem")

local NewYearExchangeView = class(ActivityParentView)

function NewYearExchangeView:ctor()
    self.residualTime = self.___ex.residualTime
    self.giftItemAear = self.___ex.giftItemAear
    self.giftItemNum = self.___ex.giftItemNum
    self.infoText = self.___ex.infoText
    self.scrollView = self.___ex.scrollView
    self.mName = self.___ex.mName
    self.helpBtn = self.___ex.helpBtn
end

function NewYearExchangeView:start()
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpBtnClick()
    end)
end

function NewYearExchangeView:OnHelpBtnClick()
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossRuleBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:InitView(lang.trans("instruction"), lang.trans("newYearExchange_help"))
end

local MyContents = {exchangeItem = {{id = "", num = 1}}}
function NewYearExchangeView:InitView(exchangeModel)
    self.exchangeModel = exchangeModel
    self.infoText.text = exchangeModel:GetActivityDesc()
    self.mName["1"].text = exchangeModel:GetName()
    self.mName["2"].text = exchangeModel:GetName()
    self.residualTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.exchangeModel:GetBeginTime()), 
                                    string.convertSecondToMonth(self.exchangeModel:GetEndTime()))
    local contentsCount = exchangeModel:GetContents()
    local index = 1
    for k,v in pairs(contentsCount.item) do
        local contents = MyContents
        contents.exchangeItem[1].id = k
        res.ClearChildren(self.giftItemAear[tostring(index)].transform)
        local rewardParams = {
            parentObj = self.giftItemAear[tostring(index)],
            rewardData = contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            hideCount = true
        }
        RewardDataCtrl.new(rewardParams)
        self.giftItemNum[tostring(index)].text = "X" .. (contentsCount and contentsCount.item[k] or 0)
        index = index + 1
    end
end

return NewYearExchangeView