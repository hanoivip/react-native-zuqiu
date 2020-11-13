local GameObjectHelper = require("ui.common.GameObjectHelper")

local CompeteChampionWallOverviewItemView = class(unity.base, "CompeteChampionWallOverviewItemView")

function CompeteChampionWallOverviewItemView:ctor()
    self.objNor = self.___ex.objNor
    self.objSpl = self.___ex.objSpl
    self.txtRank = self.___ex.txtRank
    self.txtServer = self.___ex.txtServer
    self.txtName = self.___ex.txtName
    self.txtCount = self.___ex.txtCount
    self.objRank_1 = self.___ex.objRank_1
    self.objRank_2 = self.___ex.objRank_2
    self.objRank_3 = self.___ex.objRank_3
end

function CompeteChampionWallOverviewItemView:InitView(data)
    self.data = data
    if data.rank <= 3 then
        GameObjectHelper.FastSetActive(self.objNor.gameObject, false)
        GameObjectHelper.FastSetActive(self.objSpl.gameObject, true)
        GameObjectHelper.FastSetActive(self.objRank_1.gameObject, data.rank == 1)
        GameObjectHelper.FastSetActive(self.objRank_2.gameObject, data.rank == 2)
        GameObjectHelper.FastSetActive(self.objRank_3.gameObject, data.rank == 3)
    else
        GameObjectHelper.FastSetActive(self.objNor.gameObject, true)
        GameObjectHelper.FastSetActive(self.objSpl.gameObject, false)
    end
    self.txtRank.text = tostring(data.rank)
    self.txtServer.text = tostring(data.serverName)
    self.txtName.text = tostring(data.name)
    self.txtCount.text = tostring(data.count)
end

return CompeteChampionWallOverviewItemView
