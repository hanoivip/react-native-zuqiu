local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")
local AssetFinder = require("ui.common.AssetFinder")
local TrophyRoomCtrl = require("ui.controllers.honorPalace.TrophyRoomCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

-- 荣誉展示界面
local PlayerDetailHonorShowView = class(unity.base)

function PlayerDetailHonorShowView:ctor()
    self.cupTxt = self.___ex.cupTxt
    self.progressBar = self.___ex.progressBar
    self.progressTxt = self.___ex.progressTxt
    self.collectionTxt = self.___ex.collectionTxt
    self.collectionPercent = self.___ex.collectionPercent
    self.empty2 = self.___ex.empty2
    self.empty1 = self.___ex.empty1
    self.show1 = self.___ex.show1
    self.cupIcon1 = self.___ex.cupIcon1
    self.title1 = self.___ex.title1
    self.description1 = self.___ex.description1
    self.time1 = self.___ex.time1
    self.show2 = self.___ex.show2
    self.cupIcon2 = self.___ex.cupIcon2
    self.title2 = self.___ex.title2
    self.description2 = self.___ex.description2
    self.time2 = self.___ex.time2
    self.empty3 = self.___ex.empty3
    self.show3 = self.___ex.show3
    self.cupIcon3 = self.___ex.cupIcon3
    self.title3 = self.___ex.title3
    self.description3 = self.___ex.description3
    self.time3 = self.___ex.time3
    self.emptyTxt1 = self.___ex.emptyTxt1
    self.emptyTxt2 = self.___ex.emptyTxt2
    self.emptyTxt3 = self.___ex.emptyTxt3
    self.pos1Btn = self.___ex.pos1Btn
    self.pos2Btn = self.___ex.pos2Btn
    self.pos3Btn = self.___ex.pos3Btn

    EventSystem.AddEvent("Refresh_Player_Detail_Trophy", self, self.FillInTrophy)
end

function PlayerDetailHonorShowView:InitView(playerDetailModel, honorPalaceModel)
    self.cupTxt.text = lang.transstr("pd_honor_cup_num")
    self.collectionTxt.text = lang.transstr("honor_palace_collectionDegree")
    self.emptyTxt1.text = lang.transstr("pd_honor_empty_cup")
    self.emptyTxt2.text = lang.transstr("pd_honor_empty_cup")
    self.emptyTxt3.text = lang.transstr("pd_honor_empty_cup")

    self.honorPalaceModel = honorPalaceModel
    local playerTrophyNum = honorPalaceModel:GetTrophyNum()
    local honorNum = honorPalaceModel:GetHonorNumFromTable()
    local percent = playerTrophyNum / honorNum
    self.progressBar.value = percent
    self.progressTxt.text = tostring(playerTrophyNum) .. " / " .. tostring(honorNum)
    self.collectionPercent.text = tostring(honorPalaceModel:GetCollectedTrophyPercent(playerTrophyNum)) .. "%"
    self:FillInTrophy()
    self:InitRegister(honorPalaceModel)
    GameObjectHelper.FastSetActive(self.pos1Btn.gameObject, playerDetailModel:GetIsMe())
    GameObjectHelper.FastSetActive(self.pos2Btn.gameObject, playerDetailModel:GetIsMe())
    GameObjectHelper.FastSetActive(self.pos3Btn.gameObject, playerDetailModel:GetIsMe())
end

function PlayerDetailHonorShowView:InitRegister(honorPalaceModel)
    self.pos1Btn:regOnButtonClick(function ()
        local ctrl = TrophyRoomCtrl.new(1)
        ctrl:InitView(honorPalaceModel)
    end)
    self.pos2Btn:regOnButtonClick(function ()
        local ctrl = TrophyRoomCtrl.new(2)
        ctrl:InitView(honorPalaceModel)
    end)
    self.pos3Btn:regOnButtonClick(function ()
        local ctrl = TrophyRoomCtrl.new(3)
        ctrl:InitView(honorPalaceModel)
    end)
end

function PlayerDetailHonorShowView:FillInTrophy(data)
    if not self.honorPalaceModel then return end
    local showData = cache.getHonorShowData()
    local list = data or (type(showData) == "table" and showData or {})
    for i,v in pairs(list) do
        local itemModel = self.honorPalaceModel:GetTrophyByID(v)
        local honorPalaceItemModel = HonorPalaceItemModel.new(itemModel)
        local index = tostring(i)
        self["empty" .. index]:SetActive(false)
        self["show" .. index]:SetActive(true)
        self["title" .. index].text = honorPalaceItemModel:GetName()
        self["description" .. index].text = honorPalaceItemModel:GetDesc()
        self["time" .. index].text = honorPalaceItemModel:GetTime()
        self["cupIcon" .. index].sprite = AssetFinder.GetHonorPalaceTrophyIcon(honorPalaceItemModel:GetID())
        self["cupIcon" .. index]:SetNativeSize()
    end
end

function PlayerDetailHonorShowView:onDestroy()
    EventSystem.RemoveEvent("Refresh_Player_Detail_Trophy", self, self.FillInTrophy)
end

return PlayerDetailHonorShowView