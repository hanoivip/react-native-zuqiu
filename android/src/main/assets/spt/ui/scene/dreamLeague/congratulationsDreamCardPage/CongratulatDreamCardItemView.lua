local DreamLeagueCardHelper = require("ui.scene.dreamLeague.DreamLeagueCardHelper")
local CongratulatDreamCardItemView = class(unity.base)
function CongratulatDreamCardItemView:ctor()
    self.cardParent = self.___ex.cardParent
end

function CongratulatDreamCardItemView:InitView(cardModel, selectCallBack)
    cardModel.lockCallBack = function(lockState) self:LockStateChange(lockState) end
    cardModel.checkBoxCallBack = selectCallBack
    cardModel.selectMode = DreamLeagueCardHelper.CardSelectMode.REWARD
    local prefab, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamLeagueCard.prefab")
    prefab.transform:SetParent(self.cardParent, false)
    spt:InitView(cardModel)
end

function CongratulatDreamCardItemView:OnSelectClick(selectCallBack)
    -- if selectCallBack then
    --     self.selectState = not self.selectState
    --     GameObjectHelper.FastSetActive(self.isSelect, self.selectState)
    --     selectCallBack(self.selectState, self.dcid)
    -- end
end

function CongratulatDreamCardItemView:LockStateChange(lockState)
    -- GameObjectHelper.FastSetActive(self.checkObj, not lockState)
    -- if lockState then
    --     self.selectState = true
    --     self:OnSelectClick(self.selectCallBack)
    -- end
end

return CongratulatDreamCardItemView
