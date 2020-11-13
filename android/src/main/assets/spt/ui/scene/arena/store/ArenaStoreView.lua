local ArenaStoreView = class(unity.base)

function ArenaStoreView:ctor()
    self.scroll = self.___ex.scroll
    self.infoBarDynParent = self.___ex.infoBarDynParent
end

function ArenaStoreView:InitView(arenaStoreModel)
    self:InitScrollView()
    self.scroll:refresh(arenaStoreModel:GetStoreData())
end

function ArenaStoreView:InitScrollView()
    self.scroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaStoreItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scroll:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        -- 初始化
        spt:InitView(data)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function ArenaStoreView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return ArenaStoreView