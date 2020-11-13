local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local BuffDetailView = class(unity.base)

function BuffDetailView:ctor()
    self.floor = self.___ex.floor
    self.buffNum = self.___ex.buffNum
--------Start_Auto_Generate--------
    self.myTitleGo = self.___ex.myTitleGo
    self.myRegionTxt = self.___ex.myRegionTxt
    self.scrollSpt = self.___ex.scrollSpt
    self.tempBuffGo = self.___ex.tempBuffGo
    self.tempBuffValueTxt = self.___ex.tempBuffValueTxt
    self.tempBuffNumTxt = self.___ex.tempBuffNumTxt
    self.tempBuffRoundTxt = self.___ex.tempBuffRoundTxt
    self.tempBuffSignImg = self.___ex.tempBuffSignImg
    self.starBuffGo = self.___ex.starBuffGo
    self.starBuffValueTxt = self.___ex.starBuffValueTxt
    self.starBuffNumTxt = self.___ex.starBuffNumTxt
    self.starBuffRoundTxt = self.___ex.starBuffRoundTxt
    self.starBuffSignImg = self.___ex.starBuffSignImg
    self.noneBuffGo = self.___ex.noneBuffGo
    self.noneStarGo = self.___ex.noneStarGo
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
    self.btnClose = self.___ex.btnClose
end

function BuffDetailView:GetItemRes()
    if not self.itemRes then
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/BuffFrame.prefab")
    end
    return self.itemRes
end

function BuffDetailView:start()
    self.scrollSpt:regOnCreateItem(function(scrollSelf, index)
        local obj = Object.Instantiate(self:GetItemRes())
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scrollSpt:regOnResetItem(function(scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:InitView(self.greenswardBuildModel, index, data, self.greenswardResourceCache)
    end)

    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)

    DialogAnimation.Appear(self.transform)
end

function BuffDetailView:onDestroy()
    self.itemRes = nil
end

function BuffDetailView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

local function BuildInfo(value, round, buffValueTxt, buffNumTxt, buffRoundTxt, buffSignImg, greenswardResourceCache)
    local symbol = value >= 0 and "+" or ""
    local num = 1
    local valueTxt = lang.transstr("allAttribute") .. ": " .. symbol .. value .. "%"
    buffValueTxt.text = valueTxt
    buffNumTxt.text = tostring(num)
    buffRoundTxt.text = lang.trans("round_remain", round)
    buffSignImg.overrideSprite = greenswardResourceCache:GetArrowRes(value)
end

function BuffDetailView:InitView(greenswardBuildModel, greenswardResourceCache)
    self.greenswardBuildModel = greenswardBuildModel
    self.greenswardResourceCache = greenswardResourceCache
    local currentFloor = greenswardBuildModel:GetCurrentFloor()
    local buffNum = greenswardBuildModel:GetActiveBuffPlus()
    local floorData = greenswardBuildModel:GetFloorData()

    local symbol = buffNum >= 0 and "+" or ""
    if buffNum == 0 then
        self.buffNum.text = lang.trans("none")
    else
        self.buffNum.text = lang.transstr("allAttribute") .. ": " .. symbol .. buffNum .. "%"
    end
    self.floor.text = tostring(currentFloor)

    local totalFloor = greenswardBuildModel:GetTotalFloor()
    local floorMap = {}
    for i = 1, totalFloor do
        local singleFloor = floorData[tostring(i)]
        if singleFloor then
            floorMap[i] = singleFloor
        else
            floorMap[i] = {}
        end
    end

    self.scrollSpt:refresh(floorMap)

    local drinkBuff = greenswardBuildModel:GetDrinkBuff()
    local hasDrink = false
    if next(drinkBuff) then
        hasDrink = true
        local value = tonumber(drinkBuff.buff)
        local round = tonumber(drinkBuff.round)
        BuildInfo(value, round, self.tempBuffValueTxt, self.tempBuffNumTxt, self.tempBuffRoundTxt, self.tempBuffSignImg, greenswardResourceCache)
    end
    GameObjectHelper.FastSetActive(self.tempBuffGo.gameObject, hasDrink)
    GameObjectHelper.FastSetActive(self.noneBuffGo.gameObject, not hasDrink)

    local starAttr = greenswardBuildModel:GetStarAttr()
    local hasStarAttr = tobool(starAttr ~= 0)
    if hasStarAttr then
        local round = greenswardBuildModel:GetStarRemainRound()
        BuildInfo(starAttr, round, self.starBuffValueTxt, self.starBuffNumTxt, self.starBuffRoundTxt, self.starBuffSignImg, greenswardResourceCache)
        local isPromote = starAttr >= 0 and true or false
        starAttr = starAttr .. "%"
        self.starBuffValueTxt.text = isPromote and lang.trans("extra_promote", starAttr) or lang.trans("extra_reduction", starAttr)
    end
    GameObjectHelper.FastSetActive(self.starBuffGo.gameObject, hasStarAttr)
    GameObjectHelper.FastSetActive(self.noneStarGo.gameObject, not hasStarAttr)
end

return BuffDetailView
