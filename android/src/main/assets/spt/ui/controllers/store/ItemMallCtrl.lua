local Mall = require("data.Mall")
local StoreItemCtrl = require("ui.controllers.store.StoreItemCtrl")
local StoreModel = require("ui.models.store.StoreModel")
local ItemMallCtrl = class(nil, "ItemMallCtrl")

function ItemMallCtrl:ctor(content)
    self:Init(content)
end

function ItemMallCtrl:Init(content)
    local object, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/ItemMall.prefab")
    object.transform:SetParent(content, false)
    self.view = spt
end

function ItemMallCtrl:EnterScene()
    self.view:EnterScene()
end

function ItemMallCtrl:InitView()
   clr.coroutine(function()
        local response = req.storeItemList(nil, nil, true)
        if api.success(response) then
            local data = response.val
            local itemList = { }
            local items = {}
            for id, item in pairs(data) do
                local mallData = Mall[tostring(id)]
                if mallData then
                    table.merge(item, mallData)
                    item.id = id
                    table.insert(itemList, item)
                end
            end
            table.sort(itemList, function(a, b) return a.order < b.order end)
            StoreModel.InitData(StoreModel.MenuTags.ITEM, itemList)
            local data = StoreModel.GetItemDatas(StoreModel.MenuTags.ITEM)
            for i, v in ipairs(data) do
                local item = StoreItemCtrl.new(v)
                table.insert(items, item.view)
            end
            self.view:InitView(items)
        end
    end)
end

function ItemMallCtrl:ShowPageVisible(isShow)
    self.view:ShowPageVisible(isShow)
end

return ItemMallCtrl
