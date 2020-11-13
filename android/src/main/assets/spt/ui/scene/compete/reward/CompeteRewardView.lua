local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local EventSystem = require("EventSystem")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteRewardView = class(unity.base, "CompeteRewardView")

function CompeteRewardView:ctor()
    self.btnBack = self.___ex.btnBack
    self.tabView = self.___ex.tabView
    self.btnCollectAll = self.___ex.btnCollectAll
    self.btnCollectAllObj = self.___ex.btnCollectAllObj
    self.btnCollectedObj = self.___ex.btnCollected
    self.btnCollect = self.___ex.btnCollect
    self.tipsForMail = self.___ex.tipsForMail
    self.mailContent = self.___ex.mailContent
end

function CompeteRewardView:start()
    self.btnCollectAll:regOnButtonClick(function()
        if self.clickCollectAll then
            self.clickCollectAll()
        end
    end)
end

function CompeteRewardView:InitView(competeRewardModel)
    self.model = competeRewardModel
    self.btnBack:regOnButtonClick(function()
        if self.onClickBack then
            self.onClickBack()
        end
    end)

    self:InitTabView()
end

function CompeteRewardView:InitTabView()
    self.tabView.onItemClick = function(spt, index) self:OnItemClick(spt, index) end
end

function CompeteRewardView:OnItemClick(spt, index)
    self.tabView:ChangeSelectItem(spt, index)
end

return CompeteRewardView