local BaseCtrl = require("ui.controllers.BaseCtrl")
local GreenswardCycleDetailModel = require("ui.models.greensward.cycleDetail.GreenswardCycleDetailModel")

local GreenswardCycleDetailCtrl = class(BaseCtrl, "GreenswardCycleDetailCtrl")

GreenswardCycleDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/CycleDetail/GreenswardCycleDetail.prefab"

GreenswardCycleDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardCycleDetailCtrl:ctor()
    GreenswardCycleDetailCtrl.super.ctor(self)
end

-- @param base: 服务器发送的base字段
-- @param weaBuildModel: GreenswardWeatherBuildModel
-- @param starBuildModel: GreenswardStarBuildModel
function GreenswardCycleDetailCtrl:Init(base, weaBuildModel, starBuildModel)
    self.model = GreenswardCycleDetailModel.new()
    self.model:InitWithProtocol(base, weaBuildModel, starBuildModel)
    self.view.onBtnStarLibClick = function() self:OnBtnStarLibClick() end
    self.view:InitView(self.model)
end

function GreenswardCycleDetailCtrl:Refresh()
    GreenswardCycleDetailCtrl.super.Refresh(self)
    self.view:RefreshView()
end

-- 点击星象图鉴按钮
function GreenswardCycleDetailCtrl:OnBtnStarLibClick()
    res.PushDialog("ui.controllers.greensward.star.GreenswardStarLibCtrl")
end

return GreenswardCycleDetailCtrl
