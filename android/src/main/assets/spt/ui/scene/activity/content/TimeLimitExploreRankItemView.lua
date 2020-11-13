local GameObjectHelper = require("ui.common.GameObjectHelper")
local TimeLimitExploreRankItemView = class(unity.base)

function TimeLimitExploreRankItemView:ctor()
    self.bg1 = self.___ex.bg1
    self.bg2 = self.___ex.bg2
    self.nameTxt = self.___ex.name
    self.server = self.___ex.server
    self.nameNone = self.___ex.nameNone
    self.point = self.___ex.point
    self.rankNumberView = self.___ex.rankNumberView
end

function TimeLimitExploreRankItemView:InitView(itemModel, parentScrollRect, index)
    self.itemModel = itemModel
    self.index = index

    self.rankNumberView:InitView(itemModel.rank)
    
    if not itemModel.name then
        self.nameNone.gameObject:SetActive(true)
        self.nameTxt.gameObject:SetActive(false)
        self.nameNone.text = lang.trans("visit_pointNeed", tostring(itemModel.visitPoint))
        self.point.gameObject:SetActive(false)
    else
        self.nameNone.gameObject:SetActive(false)
        self.nameTxt.gameObject:SetActive(true)
        self.point.gameObject:SetActive(true)
        self.nameTxt.text = itemModel.name
        self.server.text = tostring(itemModel.serverName)
        self.point.text = tostring(itemModel.visitPoint)
    end
    
    self.bg1:SetActive(self.index % 2 == 1)
    self.bg2:SetActive(self.index % 2 == 0)
end



return TimeLimitExploreRankItemView
