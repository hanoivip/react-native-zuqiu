local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local MemoryItemDetailView = class(unity.base, "MemoryItemDetailView")

-- 描述文本激活或未激活颜色
local Color_Txt_Active = Color(54 / 255, 39 / 255, 0, 1)
local Color_Txt_Inactive = Color(66 / 255, 66 / 255, 66 / 255, 1)
-- 横线激活或未激活颜色
local Color_ImgSplit_Active = Color(50 / 255, 36 / 255, 0, 0.5)
local Color_ImgSplit_Inactive = Color(81 / 255, 83 / 255, 104 / 255, 0.5)

function MemoryItemDetailView:ctor()
    self.imgIcon = self.___ex.imgIcon
    self.txtDesc = self.___ex.txtDesc
    self.imgSplit = self.___ex.imgSplit
    self.txtAttr = self.___ex.txtAttr
    self.imgActiveBg = self.___ex.imgActiveBg
    self.imgInactiveBg = self.___ex.imgInactiveBg
    self.sptStars = self.___ex.sptStars
    self.imgLock = self.___ex.imgLock
end

function MemoryItemDetailView:start()
end

function MemoryItemDetailView:InitView(memoryData)
    self.data = memoryData
    local isActive = self.data.isActive
    local activeKey = isActive and "active" or "inactive"
    -- 图标
    self.imgIcon.overrideSprite = self.data.iconRes[activeKey]
    -- 锁头
    GameObjectHelper.FastSetActive(self.imgLock.gameObject, not isActive)
    -- 星星
    GameObjectHelper.FastSetActive(self.sptStars.gameObject, isActive)
    self.sptStars:InitView(self.data.idx)
    -- 描述文本
    self.txtDesc.text = lang.trans("memory_desc_" .. activeKey .. "_" .. self.data.type, self.data.qualityStr, self.data.cardName, self.data.typeDetail)
    self.txtDesc.color = isActive and Color_Txt_Active or Color_Txt_Inactive
    -- 分割线
    self.imgSplit.color = isActive and Color_ImgSplit_Active or Color_ImgSplit_Inactive
    -- 全属性提升xxx
    self.txtAttr.text = lang.trans("card_training_rule_allAttr", self.data.attributeImprove)
    self.txtAttr.color = isActive and Color_Txt_Active or Color_Txt_Inactive
end

return MemoryItemDetailView
