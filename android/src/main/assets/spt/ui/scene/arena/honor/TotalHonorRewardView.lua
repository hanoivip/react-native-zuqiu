local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TotalHonorRewardView = class(unity.base)

function TotalHonorRewardView:ctor()
    self.scrollView = self.___ex.scrollView
    self:RegScrollViewHandle()
end

function TotalHonorRewardView:GetHonorBarRes()
    if not self.honorBarRes then 
        self.honorBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/HonorBar.prefab")
    end
    return self.honorBarRes
end

function TotalHonorRewardView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local honorBarRes = self:GetHonorBarRes()
        local obj = Object.Instantiate(honorBarRes)
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local barData = scrollSelf.itemDatas[index]
        spt:InitView(barData, self.arenaModel, self.arenaHonorModel)
        spt.clickReward = function(id)
            self:OnClickReward(id) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function TotalHonorRewardView:InitView(arenaModel, arenaHonorModel, pageType)
    self.arenaModel = arenaModel
    self.arenaHonorModel = arenaHonorModel
    local listData = arenaHonorModel:GetHonorData(pageType)
    self.scrollView:refresh(listData)
end

function TotalHonorRewardView:EnterScene()

end

function TotalHonorRewardView:onDestroy()
    self.honorBarRes = nil
end

function TotalHonorRewardView:OnClickReward(id)
    if self.clickReward then 
        self.clickReward(id)
    end
end

function TotalHonorRewardView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return TotalHonorRewardView