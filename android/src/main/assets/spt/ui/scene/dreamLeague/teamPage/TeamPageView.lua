local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local TeamPageView = class(unity.base)

function TeamPageView:ctor()
    self.ownerNum = self.___ex.ownerNum
    self.lightNum = self.___ex.lightNum
    self.decomposeBtn = self.___ex.decomposeBtn
    self.teamFlag = self.___ex.teamFlag
    self.teamName = self.___ex.teamName
    self.teamscrollView = self.___ex.teamscrollView
end

function TeamPageView:InitView(teamPageModel, onlyNeedPlayerName)
    self.teamPageModel = teamPageModel
    self.onlyNeedPlayerName = onlyNeedPlayerName
    self:InitScrollView()

    local ownerText, lightText = self.teamPageModel:GetOwnerAndLightNum()
    local teamCode = self.teamPageModel:GetTeamCode()
    local teamName = self.teamPageModel:GetTeamName()
    local nationRes = AssetFinder.GetNationIcon(teamCode)
    self.ownerNum.text = lang.trans("dream_owner_num", ownerText)
    self.lightNum.text = lang.trans("dream_light", lightText)
    self.teamFlag.overrideSprite = nationRes
    self.teamName.text = teamName
    local isSelectMode = self.teamPageModel:GetSelectModeState()
    GameObjectHelper.FastSetActive(self.decomposeBtn.gameObject, not isSelectMode)
    GameObjectHelper.FastSetActive(self.ownerNum.gameObject, not isSelectMode)
    GameObjectHelper.FastSetActive(self.lightNum.gameObject, not isSelectMode)

    self.decomposeBtn:regOnButtonClick(function ()
        if self.onDecomposeClick then
            self.onDecomposeClick()
        end
    end)
end

function TeamPageView:InitScrollView()
    local getItemTag = function(index)
        return "Prefab"
    end
    
    local creatItem = function(index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/TeamPage/TeamGroupItem.prefab"
        local obj = res.Instantiate(prefab)
        return obj
    end

    local resetItem = function(scrollView, spt, index)
        local data = scrollView.itemDatas[index]
        local allCount = 0
        for k, models in pairs(data.player) do
            allCount = allCount + 1
        end
        local cellSize = Vector2(1075, 51)
        if allCount > 0 then
            allCount,t2 = math.modf(allCount / 5)
            if t2 ~= 0 then
                allCount = allCount + 1
            end
            cellSize = Vector2(1075, 67 + allCount * 320)
        end
        spt.transform.sizeDelta = cellSize
        spt:InitView(data, self.onPlayerClickCallBack, self.onlyNeedPlayerName)
    end

    self.teamscrollView.getItemTag = getItemTag
    self.teamscrollView.createItemByTagPrefab = creatItem
    self.teamscrollView.resetItemByTagPrefab = resetItem
    local scrollData = self.teamPageModel:GetScrollData()
    self.teamscrollView:refresh(scrollData)
end

return TeamPageView
