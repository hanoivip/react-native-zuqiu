local Object = clr.UnityEngine.Object
local GuildMistWarMap = require("data.GuildMistWarMap")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MistMapStoreDetailView = class(unity.base)

function MistMapStoreDetailView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.mapItemTrans = self.___ex.mapItemTrans
--------End_Auto_Generate----------
end

function MistMapStoreDetailView:start()
    self:RegOnBtn()
end

function MistMapStoreDetailView:InitView(mapData)
    self.mapData = mapData
    local previewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistPreviewMapItem.prefab"
    local resObj = res.LoadRes(previewPath)
    local obj = Object.Instantiate(resObj)
    obj.transform:SetParent(self.mapItemTrans, false)
    local objScript = obj:GetComponent("CapsUnityLuaBehav")
    obj.script = objScript
    local mapId = tostring(mapData.mapId)
    local data = {}
    data.staticData = GuildMistWarMap[mapId]
    objScript:InitView(data)
end

function MistMapStoreDetailView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function MistMapStoreDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return MistMapStoreDetailView
