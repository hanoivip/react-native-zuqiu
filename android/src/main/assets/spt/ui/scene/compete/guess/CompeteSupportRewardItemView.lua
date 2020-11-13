local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CompeteSupportRewardItemView = class(unity.base, "CompeteSupportRewardItemView")

function CompeteSupportRewardItemView:ctor()
    -- 奖励名字
    self.txtTitle_1 = self.___ex.txtTitle_1
    self.txtTitle_2 = self.___ex.txtTitle_2
    -- 选中背景
    self.imgChoosed = self.___ex.imgChoosed
    -- 礼盒图片
    self.imgBag = self.___ex.imgBag
    -- 竞猜所需金额
    self.txtMoney = self.___ex.txtMoney
    -- 点击
    self.btnClick = self.___ex.btnClick
end

function CompeteSupportRewardItemView:start()
end

function CompeteSupportRewardItemView:InitView(data)
    self.data = data
    self.txtTitle_1.text = lang.trans("compete_guess_reward_1", data.idx)
    local picIndex = data.picIndex or "Red"
    self.imgBag.overrideSprite = AssetFinder.GetCompeteGuessReward("Pkg_" .. picIndex)
    self.txtMoney.text = "X" .. string.formatNumWithUnit(data.mConsume)
end

return CompeteSupportRewardItemView
