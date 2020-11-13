local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamMainMatchNationItemParentView = class(unity.base)

function DreamMainMatchNationItemParentView:ctor()
    self.nationMatchPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamMain/MatchNationItem.prefab"
    self.parentTrans = self.___ex.parentTrans
    self.titleTxt = self.___ex.titleTxt
    self.sptList = {}
end

function DreamMainMatchNationItemParentView:InitView(matchData)
    for i=1,#self.sptList do
        GameObjectHelper.FastSetActive(self.sptList[i].gameObject, false)
    end
    for i, v in ipairs(matchData or {}) do
        if not self.sptList[i] then
            local obj, spt = res.Instantiate(self.nationMatchPath)
            obj.transform:SetParent(self.parentTrans, false)
            spt:InitView(v)
            table.insert(self.sptList, spt)
        else
            GameObjectHelper.FastSetActive(self.sptList[i].gameObject, true)
            self.sptList[i]:InitView(v)
        end
    end

    self.titleTxt.text = lang.trans("dream_title_" .. matchData.dateMark)
end

return DreamMainMatchNationItemParentView
