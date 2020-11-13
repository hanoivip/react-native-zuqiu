local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamBagView = class(unity.base)

function DreamBagView:ctor()
    self.ownerNum = self.___ex.ownerNum
    self.lightNum = self.___ex.lightNum
    self.decomposeBtn = self.___ex.decomposeBtn
    self.searchBtn = self.___ex.searchBtn
    self.bagScrollView = self.___ex.bagScrollView
    self.searchObj = self.___ex.searchObj
    self.searchCloseBtn = self.___ex.searchCloseBtn
    self.searchScrollParent = self.___ex.searchScrollParent
    self.btnGroup = self.___ex.btnGroup
end

function DreamBagView:start()
    self.searchBtn:regOnButtonClick(function ()
        local searchObjState = self.searchObj.activeSelf
        GameObjectHelper.FastSetActive(self.searchObj, not searchObjState)
    end)

    self.searchCloseBtn:regOnButtonClick(function ()
        GameObjectHelper.FastSetActive(self.searchObj, false)
    end)

    self.decomposeBtn:regOnButtonClick(function ()
        if self.onDecomposeClick then
            self.onDecomposeClick()
        end
    end)
end

function DreamBagView:InitView(dreamBagModel, posIndex)
    self.dreamBagModel = dreamBagModel
    self.posIndex = posIndex
    self.dreamLeagueListModel = self.dreamBagModel:GetDreamLeagueListModel()
    self.ownerNum.text = lang.trans("dream_owner_num", self.dreamBagModel:GetOwnerNum())
    self.lightNum.text = lang.trans("dream_light", self.dreamBagModel:GetLightNum())
    self.searchScrollData = self.dreamBagModel:GetSearchScrollData()
    self:InitSearchScrollView()
    self:InitBagScrollView()
    
    local isSelectMode = self.dreamBagModel:GetSelectModeState()
    GameObjectHelper.FastSetActive(self.decomposeBtn.gameObject, not isSelectMode)
    GameObjectHelper.FastSetActive(self.ownerNum.gameObject, not isSelectMode)
    GameObjectHelper.FastSetActive(self.lightNum.gameObject, not isSelectMode)
end

function DreamBagView:InitSearchScrollView()
    res.ClearChildren(self.searchScrollParent)
    self.btnGroup:UnbindAll()
    self.btnGroup.menu = {}
    for k,v in ipairs(self.searchScrollData) do
        self.searchScrollData[k].needFilterPosIndex = self.posIndex
        local searchnObj, searchSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBag/NationSearchTitle.prefab")
        searchnObj.transform:SetParent(self.searchScrollParent, false)
        searchSpt:InitView(v)
        self.btnGroup.menu[k] = searchSpt
        self.btnGroup:BindMenuItem(k, function()
            if self.onSearchClick then
                self.onSearchClick(v.firstLetter)
                GameObjectHelper.FastSetActive(self.searchObj, false)
            end
        end)
    end
end

function DreamBagView:InitBagScrollView()
    local getItemTag = function(index)
        return "Prefab"
    end
    
    local creatItem = function(index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBag/NationGroupItem.prefab"
        local obj = res.Instantiate(prefab)
        return obj
    end

    local resetItem = function(scrollView, spt, index)
        local data = scrollView.itemDatas[index]
        local allCount = 0
        for nationName, nationInfo in pairs(data.nations) do
            for teamName, teamInfo in pairs(nationInfo) do
                if teamInfo.teamMember then
                    allCount = allCount + 1
                end
            end
        end
        local cellSize = Vector2(1075, 67)
        if allCount > 0 then
            allCount,t2 = math.modf(allCount / 3);
            if t2 ~= 0 then
                allCount = allCount + 1
            end
            cellSize = Vector2(1075, 67 + allCount * 180)
        end
        spt.transform.sizeDelta = cellSize
        spt:InitView(data, self.clickNationCallBack)
    end

    self.bagScrollView.getItemTag = getItemTag
    self.bagScrollView.createItemByTagPrefab = creatItem
    self.bagScrollView.resetItemByTagPrefab = resetItem
    self.bagScrollView:refresh(self.searchScrollData)
end
return DreamBagView

