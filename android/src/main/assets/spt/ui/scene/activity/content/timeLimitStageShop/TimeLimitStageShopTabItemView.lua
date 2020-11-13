local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local TimeLimitStageShopTabItemView = class(LuaButton)

function TimeLimitStageShopTabItemView:ctor()
    self.super.ctor(self)
--------Start_Auto_Generate--------
    self.selectImgGo = self.___ex.selectImgGo
    self.selectEndImgGo = self.___ex.selectEndImgGo
    self.iconSelectImg = self.___ex.iconSelectImg
    self.selectNameTxt = self.___ex.selectNameTxt
    self.normalImgGo = self.___ex.normalImgGo
    self.normalEndImgGo = self.___ex.normalEndImgGo
    self.iconNormalImg = self.___ex.iconNormalImg
    self.normalNameTxt = self.___ex.normalNameTxt
    self.saleGo = self.___ex.saleGo
--------End_Auto_Generate----------
    self.normalImgPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitStageShop/Image/Normal_%s.png"
    self.selectImgPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitStageShop/Image/Select_%s.png"
end

function TimeLimitStageShopTabItemView:start()

end

function TimeLimitStageShopTabItemView:InitView(storeData)
    local isLast = tobool(storeData.isLast)
    local storeName = storeData.storeName
    local picName = storeData.picName
    local isOpen = storeData.isOpen
    local normalImgRes = res.LoadRes(string.format(self.normalImgPath, picName))
    local selectImgRes = res.LoadRes(string.format(self.selectImgPath, picName))

    self.selectNameTxt.text = storeName
    self.normalNameTxt.text = storeName
    self.iconNormalImg.overrideSprite = normalImgRes
    self.iconSelectImg.overrideSprite = selectImgRes

    GameObjectHelper.FastSetActive(self.normalEndImgGo, isLast)
    GameObjectHelper.FastSetActive(self.selectEndImgGo, isLast)
    GameObjectHelper.FastSetActive(self.normalImgGo, not isLast)
    GameObjectHelper.FastSetActive(self.selectImgGo, not isLast)
    GameObjectHelper.FastSetActive(self.saleGo, isOpen)
end

return TimeLimitStageShopTabItemView
