local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local MySceneModel = require("ui.models.myscene.MySceneModel")
local MySceneEnterView = class(unity.base)

function MySceneEnterView:ctor()
    self.leftbtn = self.___ex.leftbtn
    self.rightbtn = self.___ex.rightbtn
    self.setbtn = self.___ex.setbtn
    self.viewBtn = self.___ex.viewBtn
    self.add = self.___ex.add
    self.add1 = self.___ex.add1
    self.away = self.___ex.away
    self.home = self.___ex.home
    self.weather = self.___ex.weather
    self.cloud = self.___ex.cloud
    self.scene = self.___ex.scene
    self.rightIcon = self.___ex.rightIcon
    self.leftIcon = self.___ex.leftIcon
    self.setIcon = self.___ex.setIcon
    self.viewIcon = self.___ex.viewIcon
    self.content = self.___ex.content

    self.mySceneModel = MySceneModel.new()
end

function MySceneEnterView:start()
    self.leftbtn:regOnButtonClick(function ()
        self:OnLeftClick()
    end)
    self.rightbtn:regOnButtonClick(function ()
        self:OnRightClick()
    end)
    self.setbtn:regOnButtonClick(function ()
        self:OnSetClick()
    end)
    self.viewBtn:regOnButtonClick(function()
        self:OnLookClick()
    end)

    EventSystem.AddEvent("MySceneUpdate", self, self.OnMySceneUpdate)
end

function MySceneEnterView:OnMySceneUpdate()
    self:RefreshHomeInfo()
    self:RefreshScene()
end

function MySceneEnterView:onDestroy()
    EventSystem.RemoveEvent("MySceneUpdate", self, self.OnMySceneUpdate)
end

function MySceneEnterView:OnLeftClick()
    self.hide = false
    self:RefreshButtonInfo()
    self:RefreshHomeInfo()
end

function MySceneEnterView:OnRightClick()
    self.hide = true
    self:RefreshButtonInfo()
    self:RefreshHomeInfo()
end

function MySceneEnterView:OnSetClick()
    res.PushDialogImmediate("ui.controllers.myScene.MySceneCtrl")
end

function MySceneEnterView:OnLookClick()
    if self.lookClick then
        self.lookClick()
    end
end
--nType
--1 主界面
--2 阵容界面
--3 查看玩家阵容界面
--4 球员界面
function MySceneEnterView:InitView(nType)
    self.nType = nType
    self.hide = false --主界面是否回收 每次重新打开回收
    self.content.padding.right = nType == 1 and 50 or nType == 2 and 50 or 10
    self:RefreshButtonInfo()
    self:RefreshHomeInfo()
    self:RefreshScene()
end

function MySceneEnterView:RefreshButtonInfo()
    local mainShow = self.nType ~= 1 or not self.hide
    GameObjectHelper.FastSetActive(self.leftIcon.gameObject, self.nType == 1 and self.hide)
    GameObjectHelper.FastSetActive(self.rightIcon.gameObject, self.nType == 1 and not self.hide)
    GameObjectHelper.FastSetActive(self.setIcon.gameObject, self.nType == 2)
    GameObjectHelper.FastSetActive(self.viewIcon.gameObject, self.nType == 4)
    GameObjectHelper.FastSetActive(self.cloud, self.nType == 1)
    GameObjectHelper.FastSetActive(self.add, mainShow)
    GameObjectHelper.FastSetActive(self.add1, mainShow)
    GameObjectHelper.FastSetActive(self.weather.gameObject, mainShow)
    GameObjectHelper.FastSetActive(self.scene.gameObject, mainShow)
end

function MySceneEnterView:RefreshHomeInfo()
    local mainShow = self.nType ~= 1 or not self.hide
    local bHome = self.mySceneModel:IsHome()
    GameObjectHelper.FastSetActive(self.away, mainShow and not bHome)
    GameObjectHelper.FastSetActive(self.home, mainShow and bHome)
end

function MySceneEnterView:RefreshScene()
    self.weather.overrideSprite = CourtAssetFinder.GetTechnologyIcon(self.mySceneModel:GetWeather())
    self.scene.overrideSprite = CourtAssetFinder.GetTechnologyIcon(self.mySceneModel:GetGrass())
end

return MySceneEnterView