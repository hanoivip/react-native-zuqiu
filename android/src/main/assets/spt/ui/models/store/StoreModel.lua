local MallPageType = require("ui.scene.store.MallPageType")
local EventSystem = require("EventSystem")
local StoreModel = class()

StoreModel.MenuTags = { 
    GACHA = "gacha",
    ITEM = "item",
    GiftBox = "giftBox",
    Agent = "agent",
}

StoreModel.HotColor = {
    RED = "Red",
}

local storeData = {}

function StoreModel.InitData(tag, data)
    storeData[tag] = clone(data)
end

function StoreModel.GetItemDatas(tag)
    return storeData[tag]
end

function StoreModel.GetMallPageType()
    return StoreModel.mallPageType or MallPageType.Item
end

function StoreModel.SetMallPageType(mallPageType)
    StoreModel.mallPageType = mallPageType
end

function StoreModel.GetPlayerPieceCacheScrollPos()
    return StoreModel.playerPieceCacheScrollPos
end

function StoreModel.SetPlayerPieceCacheScrollPos(playerPieceCacheScrollPos)
    StoreModel.playerPieceCacheScrollPos = playerPieceCacheScrollPos
end

function StoreModel.GetPlayerPasterCacheScrollPos()
    return StoreModel.playerPasterCacheScrollPos
end

function StoreModel.SetPlayerPasterCacheScrollPos(playerPasterCacheScrollPos)
    StoreModel.playerPasterCacheScrollPos = playerPasterCacheScrollPos
end

function StoreModel.GetShowPasterType()
    return StoreModel.pasterType
end

function StoreModel.SetShowPasterType(pasterType)
    StoreModel.pasterType = pasterType
end

function StoreModel.ResetStateDefault()
    StoreModel.mallPageType = nil
    StoreModel.playerPieceCacheScrollPos = nil
    StoreModel.playerPasterCacheScrollPos = nil
    StoreModel.pasterType = nil
end

return StoreModel

