local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local ImproveType = require("ui.models.heroHall.main.HeroHallImproveType")

local HeroHallImproveItemView = class(unity.base, "HeroHallImproveItemView")

function HeroHallImproveItemView:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.objLine = self.___ex.objLine
    self.txtContent1 = self.___ex.txtContent1
    self.txtContent2 = self.___ex.txtContent2
end

function HeroHallImproveItemView:InitView(itemData)
    self.itemData = itemData
    if itemData.isTitle then
        GameObjectHelper.FastSetActive(self.txtTitle.gameObject, true)
        GameObjectHelper.FastSetActive(self.objLine.gameObject, true)
        GameObjectHelper.FastSetActive(self.txtContent1.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtContent2.gameObject, false)

        if self.itemData.improveType == ImproveType.quality.improveType then
            self.txtTitle.text = lang.trans("hero_hall_improve_title_quality")
        elseif self.itemData.improveType == ImproveType.upgrade.improveType then
            self.txtTitle.text = lang.trans("hero_hall_improve_title_upgrade")
        elseif self.itemData.improveType == ImproveType.ascend.improveType then
            self.txtTitle.text = lang.trans("hero_hall_improve_title_ascend")
        elseif self.itemData.improveType == ImproveType.TrainingBase.improveType then
            self.txtTitle.text = lang.trans("hero_hall_improve_title_TrainingBase")
        else
            dump("illegal improve type " .. self.itemData.improveType .. ", please check the config")
        end
    else
        GameObjectHelper.FastSetActive(self.txtTitle.gameObject, false)
        GameObjectHelper.FastSetActive(self.objLine.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtContent1.gameObject, true)
        GameObjectHelper.FastSetActive(self.txtContent2.gameObject, true)

        local content1 = ""
        local content2 = string.format("%.2f", tonumber(self.itemData.improvePercent) / 100) .. "%"
        if self.itemData.improveType == ImproveType.quality.improveType then
            local fixQuality = CardHelper.GetQualityFixed(tonumber(self.itemData.improveStatus), tonumber(self.itemData.improveSpecial))
            local content = CardHelper.GetQualitySign(fixQuality)
            content1 = lang.transstr("hero_hall_improve_item_title_quality", content)
        elseif self.itemData.improveType == ImproveType.upgrade.improveType then
            content1 = lang.transstr("hero_hall_improve_item_title_upgrade", self.itemData.improveStatus)
        elseif self.itemData.improveType == ImproveType.ascend.improveType then
            content1 = lang.transstr("hero_hall_improve_item_title_ascend", self.itemData.improveStatus)
        elseif self.itemData.improveType == ImproveType.TrainingBase.improveType then
            local content = self.itemData.improveStatus .. "-" .. self.itemData.improveSpecial
            content1 = lang.transstr("hero_hall_improve_item_title_TrainingBase", content)
        else
            dump("illegal improve type " .. self.itemData.improveType .. ", please check the config")
        end

        if itemData.isCurrLevel then
            content1 = "<color=#86BE0E>" .. content1 .. "</color>"
            content2 = "<color=#86BE0E>" .. content2 .. "</color>"
        end
        self.txtContent1.text = content1
        self.txtContent2.text = content2
    end
end

return HeroHallImproveItemView