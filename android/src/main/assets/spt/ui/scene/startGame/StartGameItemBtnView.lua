local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3

local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")

local StartGameItemBtnView = class(unity.base)

function StartGameItemBtnView:ctor()
    -- 进入按钮
    self.enterBtn = self.___ex.enterBtn
    -- 解锁数据模型
    self.unlockModel = nil
    -- 视图数据
    self.viewData = nil
    -- 是否开启
    self.isOpen = false
end

function StartGameItemBtnView:InitView(unlockModel, viewData)
    self.unlockModel = unlockModel
    self.viewData = viewData
    self.isOpen = unlockModel:GetStateById(self.viewData.LIMIT_ID)
    self:BuildView()
end

function StartGameItemBtnView:start()
    self:BindAll()
end

function StartGameItemBtnView:BindAll()
    self.enterBtn:regOnButtonClick(function ()
        if self.isOpen then
            EventSystem.SendEvent("StartGame.OnClickViewBtn", self.viewData.VIEW_ID)
        end
    end)
end

function StartGameItemBtnView:BuildView()
    GameObjectHelper.FastSetActive(self.enterBtn.gameObject.transform.parent.gameObject, self.isOpen)
end

return StartGameItemBtnView