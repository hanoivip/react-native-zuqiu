local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local ItemBoxView = require("ui.common.part.ItemBoxView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CommonConstants = require("ui.common.CommonConstants")
local ItemsMapModel = require("ui.models.ItemsMapModel")

local CardTrainingItemBoxView = class(ItemBoxView)

function CardTrainingItemBoxView:ctor()
    self.countTxt = self.___ex.countTxt
    self.pic = self.___ex.pic
    self.plus = self.___ex.plus
    CardTrainingItemBoxView.super.ctor(self)
end

function CardTrainingItemBoxView:InitViewWithCount(itemModel, id, isShowName, isShowAddNum, isShowDetail, itemOriginType, cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    self.id = id
    self:InitView(itemModel, id, isShowName, isShowAddNum, isShowDetail, itemOriginType)
    local hadCount = self.itemModel:GetAddNum() or 0
    local needCount = 0
    local allCount = 0
    if id == CommonConstants.MoneyItemId then
        needCount = self.cardTrainingMainModel:GetNeedItemMaxCountByTypeAndId("m")
        allCount = PlayerInfoModel.new():GetMoney()
    else
        needCount = self.cardTrainingMainModel:GetNeedItemMaxCountByTypeAndId("item", id)
        self.mapModel = ItemsMapModel.new()
        allCount = self.mapModel:GetItemNum(id)
    end
    self.needCount = needCount
    self.countTxt.text = string.formatIntWithTenThousands(allCount) .. "-" .. string.formatIntWithTenThousands(needCount)

    if hadCount < needCount then
        for k, v in pairs(self.pic) do
            v.color = Color(0, 1, 1, 1)
        end
    else
        for k, v in pairs(self.pic) do
            v.color = Color(1, 1, 1, 1)
        end
        self.countTxt.text = "<color=#d7ff01>" .. string.formatIntWithTenThousands(hadCount) .. "-" .. string.formatIntWithTenThousands(needCount) .. "</color>"
    end
    GameObjectHelper.FastSetActive(self.plus, allCount >= needCount and hadCount < needCount)
end

function CardTrainingItemBoxView:OnItemClick()
    self:coroutine(function ()
        local pcid = self.cardTrainingMainModel:GetPcid()
        local trainId = self.cardTrainingMainModel:GetCurrLevelSelected()
        local subId = self.cardTrainingMainModel:GetSubIdByLevel(trainId)
        local contents = {}
        if self.id == CommonConstants.MoneyItemId then
            contents.m = self.needCount
        else
            contents.item = {}
            contents.item[self.id] = self.needCount
        end

        local response = req.cardTrainingDemand(pcid, trainId, subId, contents)
        if api.success(response) then
            local data = response.val
            if self.id == CommonConstants.MoneyItemId then
                if data.cost then
                    PlayerInfoModel.new():AddMoney(-data.cost.m)
                end
            end
            EventSystem.SendEvent("CardTraining_RefreshMainView")
        end
    end)
end

return CardTrainingItemBoxView