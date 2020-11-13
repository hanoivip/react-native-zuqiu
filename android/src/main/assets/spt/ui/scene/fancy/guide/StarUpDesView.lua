local FancyStarUp = require("data.FancyStarUp")
local StarUpDesView = class(unity.base)

function StarUpDesView:ctor()
--------Start_Auto_Generate--------
    self.tabBtnGroupSpt = self.___ex.tabBtnGroupSpt
    self.contentTrans = self.___ex.contentTrans
    self.starUpItemsSpt = self.___ex.starUpItemsSpt
--------End_Auto_Generate----------
end

function StarUpDesView:start()
    self:InitTab()
end

function StarUpDesView:InitTab()
    if not self.tabBtnGroupSpt.menu then
        self.tabBtnGroupSpt.menu = {}
    end
    self.infos = {}
    for i, v in pairs(FancyStarUp) do
        table.insert(self.infos,{ quality = tonumber(i), detail = v})
    end
    table.sort(self.infos, function(a, b)
        return a.quality < b.quality
    end)
    for i, v in pairs(self.infos) do
        if not self.tabBtnGroupSpt.menu[i] then
            local obj, objSpt  = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Fancy/Common/TabItem.prefab")
            obj.transform:SetParent(self.contentTrans, false)
            self.tabBtnGroupSpt.menu[i] = objSpt
        end
        self.tabBtnGroupSpt:BindMenuItem(i, function() self:OnTabClick(i) end)
        self.tabBtnGroupSpt.menu[i]:InitView(v.quality)
    end
    self.index = 1
    self.tabBtnGroupSpt:selectMenuItem(self.index)
    self:OnTabClick(self.index)
end

function StarUpDesView:OnTabClick(tag)
    self.index = tag
    local starDes = self:GetStarDes(tag)
    if not starDes then return end
    self.starUpItemsSpt:InitView(starDes)
end

function StarUpDesView:GetStarDes(quality)
    for i, v in pairs(self.infos) do
        if v.quality == tonumber(quality) then
            return v.detail
        end
    end
end

return StarUpDesView
