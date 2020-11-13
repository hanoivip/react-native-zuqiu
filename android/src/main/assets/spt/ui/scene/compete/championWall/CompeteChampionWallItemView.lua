local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")

local CompeteChampionWallItemView = class(unity.base, "CompeteChampionWallItemView")

function  CompeteChampionWallItemView:ctor()
    self.obj_Nor = self.___ex.obj_Nor
    self.txtTitle_Nor = self.___ex.txtTitle_Nor
    self.txtName_Nor = self.___ex.txtName_Nor
    self.obj_Sel = self.___ex.obj_Sel
    self.txtTitle_Sel = self.___ex.txtTitle_Sel
    self.txtName_Sel = self.___ex.txtName_Sel
    self.imgIcon_Sliver = self.___ex.imgIcon_Sliver
    self.imgIcon_Gold = self.___ex.imgIcon_Gold
    self.txtRank_Sliver = self.___ex.txtRank_Sliver
    self.txtRank_Gold = self.___ex.txtRank_Gold
    self.clickMask = self.___ex.clickMask
end

function CompeteChampionWallItemView:InitView(data)
    self.data = data
    self:SetIcon()
    self:SetTxtInfo()
    self:SetSelect()
end

function CompeteChampionWallItemView:SetIcon()
    if self.data.matchType == CompeteSchedule.Big_Ear_Match then
        GameObjectHelper.FastSetActive(self.imgIcon_Gold.gameObject, true)
        GameObjectHelper.FastSetActive(self.imgIcon_Sliver.gameObject, false)
    elseif self.data.matchType == CompeteSchedule.Small_Ear_Match then
        GameObjectHelper.FastSetActive(self.imgIcon_Gold.gameObject, false)
        GameObjectHelper.FastSetActive(self.imgIcon_Sliver.gameObject, true)
    end
    local season = string.sub(self.data.seasonName, 2, string.len(self.data.seasonName))
    self.txtRank_Sliver.text = season
    self.txtRank_Gold.text = season
end

function CompeteChampionWallItemView:SetTxtInfo()
    local title = ""
    local name = tostring(self.data.serverName) .. " " .. self.data.name
    if self.data.matchType == CompeteSchedule.Big_Ear_Match then
        title = tostring(self.data.seasonName) .. lang.transstr("competition_season") .. lang.transstr("compete_introduce_leagueName1")
    elseif self.data.matchType == CompeteSchedule.Small_Ear_Match then
        title = tostring(self.data.seasonName) .. lang.transstr("competition_season") .. lang.transstr("compete_introduce_leagueName4")
    end

    self.txtTitle_Nor.text = title
    self.txtName_Nor.text = name
    self.txtTitle_Sel.text = title
    self.txtName_Sel.text = name
end

function CompeteChampionWallItemView:SetSelect(isSelect)
    if isSelect == nil then
        isSelect = self.data.isSelect
    end
    GameObjectHelper.FastSetActive(self.obj_Nor.gameObject, not isSelect)
    GameObjectHelper.FastSetActive(self.obj_Sel.gameObject, isSelect)
end

return CompeteChampionWallItemView
