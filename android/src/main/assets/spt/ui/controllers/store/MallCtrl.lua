local MallPageType = require("ui.scene.store.MallPageType")
local ItemMallCtrl = require("ui.controllers.store.ItemMallCtrl")
local StoreModel = require("ui.models.store.StoreModel")
local PlayerPieceStoreCtrl = require("ui.controllers.playerList.PlayerPieceStoreCtrl")
local PasterPieceStoreCtrl = require("ui.controllers.paster.PasterPieceStoreCtrl")
local HonorStoreCtrl = require("ui.controllers.store.HonorStoreCtrl")
local MonthCardMallCtrl = require("ui.controllers.store.MonthCardMallCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local MallCtrl = class(nil, "MallCtrl")

function MallCtrl:ctor(content)
    self:Init(content)
end

function MallCtrl:Init(content)
    local mallObject, mallSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/Mall.prefab")
    mallObject.transform:SetParent(content.transform, false)
    self.mallView = mallSpt
    self.mallView.clickPage = function(key)
        self:OnBtnPage(key)
    end
    self.pageMap = {}
end

function MallCtrl:InitView(pageType)
    local page = pageType
    self.playerInfoModel = PlayerInfoModel.new()
    self.mallView:IsShowHonorStore(self.playerInfoModel:IsVip14())
    self.mallView:InitView(page)
end

function MallCtrl:OnBtnPage(key)
    if self.pageMap[self.page] then
        self.pageMap[self.page]:ShowPageVisible(false)
    end

    if not self.pageMap[key] then
        if key == MallPageType.Item then
            self.pageMap[key] = ItemMallCtrl.new(self.mallView.pageArea)
        elseif key == MallPageType.PlayerPiece then
            self.pageMap[key] = PlayerPieceStoreCtrl.new(self.mallView.pageArea)
        elseif key == MallPageType.PasterPiece then
            self.pageMap[key] = PasterPieceStoreCtrl.new(self.mallView.pageArea)
        elseif key == MallPageType.HonorStore then
            self.pageMap[key] = HonorStoreCtrl.new(self.mallView.pageArea)
        elseif key == MallPageType.MonthCard then
            self.pageMap[key] = MonthCardMallCtrl.new(self.mallView.pageArea)
        end
        self.pageMap[key]:EnterScene()
    end
    self.pageMap[key]:InitView()

    self.pageMap[key]:ShowPageVisible(true)
    self.page = key

    StoreModel.SetMallPageType(key)
end

function MallCtrl:OnExitScene()
    if self.pageMap[MallPageType.HonorStore] then
        self.pageMap[MallPageType.HonorStore]:OnExitScene()
    end
    if self.pageMap[MallPageType.MonthCard] then
        self.pageMap[MallPageType.MonthCard]:OnExitScene()
    end
end

return MallCtrl
