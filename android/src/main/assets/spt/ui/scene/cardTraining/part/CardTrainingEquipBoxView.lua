local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local EquipBoxView = require("ui.common.part.EquipBoxView")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MenuType = require("ui.controllers.itemList.MenuType")
local EquipPieceModel = require("ui.models.EquipPieceModel")

local CardTrainingEquipBoxView = class(EquipBoxView)

function CardTrainingEquipBoxView:ctor()
    self.countTxt = self.___ex.countTxt
    self.pic = self.___ex.pic
    self.plus = self.___ex.plus
    self.showDetail = self.___ex.showDetail
    CardTrainingEquipBoxView.super.ctor(self)

    self.showDetail:regOnButtonClick(function()
        self:ShowDetail()
    end)
end

function CardTrainingEquipBoxView:InitViewWithCount(equipItemModel, id, isShowName, isShowAddNum, isShowPiece, isShowDetail, itemOriginType, cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    self.id = id
    self:InitView(equipItemModel, id, isShowName, isShowAddNum, isShowPiece, isShowDetail, itemOriginType)
    self.needCount = self.cardTrainingMainModel:GetNeedItemMaxCountByTypeAndId("eqs", id)
    self.mapModel = EquipsMapModel.new()
    self:InitSelfView()

    EventSystem.AddEvent("EquipsMapModel_ResetEquipNum", self, self.RefreshCount)
end

function CardTrainingEquipBoxView:InitSelfView()
    local allCount = self.mapModel:GetEquipNum(self.id)
    local hadCount = self.equipItemModel:GetAddNum() or 0
    self.countTxt.text = allCount .. "-" .. self.needCount
    self.allCount = allCount

    if hadCount < self.needCount then
        for k, v in pairs(self.pic) do
            v.color = Color(0, 1, 1, 1)
        end
    else
        for k, v in pairs(self.pic) do
            v.color = Color(1, 1, 1, 1)
        end
        self.countTxt.text = "<color=#d7ff01>" .. hadCount .. "-" .. self.needCount .. "</color>"
    end
    GameObjectHelper.FastSetActive(self.plus, allCount >= self.needCount and hadCount < self.needCount)
    GameObjectHelper.FastSetActive(self.showDetail.gameObject, not self.plus.activeSelf)
end

function CardTrainingEquipBoxView:OnEquipBoxClick()
    self:coroutine(function ()
        local pcid = self.cardTrainingMainModel:GetPcid()
        local trainId = self.cardTrainingMainModel:GetCurrLevelSelected()
        local subId = self.cardTrainingMainModel:GetSubIdByLevel(trainId)
        local contents = {}
        contents.eqs = {}
        contents.eqs[self.id] = self.needCount
        local response = req.cardTrainingDemand(pcid, trainId, subId, contents)
        if api.success(response) then
            local data = response.val
            if data.cost then
                self.mapModel:ResetEquipNum(data.cost[1].id, data.cost[1].curr_num)
            end
            EventSystem.SendEvent("CardTraining_RefreshMainView")
        end
    end)
end

function CardTrainingEquipBoxView:ShowDetail()
    self.count = tonumber(self.needCount) - tonumber(self.allCount)
    if self.count <= 0 then
        self.count = 1
    end
    cache.setRequiredEquipId(self.id)
    cache.setRequiredEquipCount(self.count)
    res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", MenuType.EQUIPPIECE, EquipPieceModel.new(self.id), self.id)
end

function CardTrainingEquipBoxView:onDestroy()
    EventSystem.RemoveEvent("EquipsMapModel_ResetEquipNum", self, self.RefreshCount)
    if self.count then
        cache.setRequiredEquipCount(self.count)
    end
end

function CardTrainingEquipBoxView:RefreshCount(eid, num)
    if tonumber(eid) == tonumber(self.id) then
        self:InitSelfView()
    end
end

return CardTrainingEquipBoxView