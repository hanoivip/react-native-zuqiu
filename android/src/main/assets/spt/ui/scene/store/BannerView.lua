local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local Timer = require("ui.common.Timer")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local BannerView = class(unity.base)
local Vector3 = UnityEngine.Vector3
local UI = UnityEngine.UI
local Image = UI.Image

--纠正顺序
local normalizeIndex = {
    ["Banner0"] = {1,2,3,6,5,4},
    ["Banner1"] = {1,3,2,4,6,5},
    ["Banner2"] = {1,2,3,4,7,6,5},
    ["Banner3"] = {1,2,5,3,4},
}

function BannerView:ctor()
    self.artWords = self.___ex.artWords
    self.leftTimeArea = self.___ex.leftTimeArea
    self.leftTimeValue = self.___ex.leftTimeValue
    self.banner = self.___ex.banner
    for i = 1, 7 do
        local name = format("card%d", i)
        self[name] = self.___ex[name]
    end

    self.cardDisplay = self.___ex.cardDisplay

    self.residualTimer = nil

    self:ReplaceBackCard()
end

--添加到现卡片对象下，以免动画失效   只显示背面的时候禁用方法
function BannerView:ReplaceBackCard()
    local CName = 9
    for i = 1,self.cardDisplay.transform.childCount do
        local tempTr = self.cardDisplay.transform:GetChild(i - 1)
        Object.Destroy(tempTr:GetComponent(Image))
        Object.Destroy(tempTr:GetComponent(clr.CapsUnityLuaBehav))
        Object.Destroy(tempTr:GetComponent(clr.CapsUnityLuaBehavStart))
        res.ClearChildren(tempTr)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        local currTr = obj.transform
        currTr:SetParent(tempTr, true)
        currTr.localEulerAngles = Vector3.zero
        currTr.localScale = Vector3.one
        --个别父节点的pivot并非中心
        currTr.localPosition = Vector3(0, 260 * (0.5 -tempTr:GetComponent(UnityEngine.RectTransform).pivot.y ), 0)  --Lua assist checked flag
        currTr = currTr:GetChild(0)
        GameObjectHelper.FastSetActive(currTr:GetChild(CName).gameObject, false)
        local name = format("card%d", i)
        self[name] = spt
    end
end

function BannerView:Init(bannerPic, artWordsPic, leftTime, cardDisplay)
    -- 下面这行代码启用的话，需要把Store.prefab中Banner下self.banner的材质球改为PackedSpritesDynamic
    -- self.banner.sprite = res.LoadRes(format("Assets/CapstonesRes/Game/UI/Scene/Store/Images/Banner/%s.png", bannerPic))
    self.artWords.sprite = res.LoadRes(format("Assets/CapstonesRes/Game/UI/Scene/Store/Images/TrueColor/%s.png", artWordsPic))

    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
        self.residualTimer = nil
    end

    if self.leftTimeArea and self.leftTimeValue then
        if type(leftTime) == "number" then
            GameObjectHelper.FastSetActive(self.leftTimeArea.gameObject, true)
            self.residualTimer = Timer.new(leftTime, function(time)
                self.leftTimeValue.text = lang.transstr("gacha_left_time_2") .. string.convertSecondToTime(time)
            end)
        else
            GameObjectHelper.FastSetActive(self.leftTimeArea.gameObject, false)
        end
    end

    if type(cardDisplay) == "table" then
        for i, v in ipairs(cardDisplay) do
            if normalizeIndex[self.name][tonumber(i)] then
                local name = format("card%d", normalizeIndex[self.name][tonumber(i)])
                if self[name] then
                    local model = StaticCardModel.new(v)
                    self[name]:InitView(model)
                end
            end
        end
    end

    self:InitCardDisplay()
end

function BannerView:InitCardDisplay()
    self:coroutine(function ()
        GameObjectHelper.FastSetActive(self.cardDisplay, false)
        coroutine.yield()
        GameObjectHelper.FastSetActive(self.cardDisplay, true)
    end)
end

function BannerView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end


return BannerView
