local UnityEngine = clr.UnityEngine
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color


local LotteryHistoryBarView = class(unity.base)

function LotteryHistoryBarView:ctor()
    self.homeName = self.___ex.homeName
    self.guestName = self.___ex.guestName
    self.resultTransform = self.___ex.resultTransform
    self.amountValue = self.___ex.amountValue
    self.oddsValue = self.___ex.oddsValue
    self.statusTransform = self.___ex.statusTransform
    self.prizedButton = self.___ex.prizedButton
end

function LotteryHistoryBarView:InitView(model)
    self.model = model
    self.homeName.text = model.homeTeam
    self.guestName.text = model.guestTeam
    for i = 1, self.resultTransform.childCount do
        self.resultTransform:GetChild(i - 1).gameObject:SetActive(i == model.stakeResult)
    end
    
    self.amountValue.text = string.format(lang.transstr("betting_amount"), model.stakeNumber * 100)
    self.oddsValue.text = string.format("%.2f", model.odds)
    for i = 1, self.statusTransform.childCount do
        local child = self.statusTransform:GetChild(i - 1).gameObject
        if i ~= self.statusTransform.childCount then
            child:SetActive(model.stakeStatus == i)
        else
            -- last one is canceled
            child:SetActive(model.stakeStatus >= i or model.stakeStatus <= 0)
        end
        
    end
end


return LotteryHistoryBarView
