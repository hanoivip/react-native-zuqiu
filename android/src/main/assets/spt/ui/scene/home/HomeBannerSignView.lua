local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local HomeBannerSignView = class(unity.base)

function HomeBannerSignView:ctor()
    self.signScriptMap = {}
end

function HomeBannerSignView:GetSignRes()
    if not self.prefabRes then 
        self.prefabRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Home/Banner/BannerSign.prefab")
    end
    return self.prefabRes
end

function HomeBannerSignView:Clear()
    for i, v in ipairs(self.signScriptMap) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
end

local DefaultSelectIndex = 1
function HomeBannerSignView:ChangeSign(signIndex)
    local index = signIndex or DefaultSelectIndex
    for i, v in ipairs(self.signScriptMap) do
        local isSelect = i == index
        v:ShowNodeState(isSelect)
    end
end

function HomeBannerSignView:InitView(bannerCount)
    self:Clear()
    local prefabRes = self:GetSignRes()
    for i = 1, bannerCount do
        local sign = self.signScriptMap[i]
        if not sign then 
            local object = Object.Instantiate(prefabRes)
            object.transform:SetParent(self.transform, false)
            local script = res.GetLuaScript(object)
            self.signScriptMap[i] = script
        end
        local object = self.signScriptMap[i].gameObject
        GameObjectHelper.FastSetActive(object, true)
    end
end

return HomeBannerSignView
