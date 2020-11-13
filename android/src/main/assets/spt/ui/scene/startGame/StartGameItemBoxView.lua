local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3

local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")

local StartGameItemBoxView = class(unity.base)

function StartGameItemBoxView:ctor()
    -- 底图
    self.boxImg = self.___ex.boxImg
    -- 进入按钮
    self.enterBtn = self.___ex.enterBtn
    self.enterBtnButton = self.___ex.enterBtnButton
    -- 锁
    self.flash = self.___ex.flash
    -- 标题
    self.title = self.___ex.title
    -- 解锁数据模型
    self.unlockModel = nil
    -- 视图数据
    self.viewData = nil
    -- 是否开启
    self.isOpen = false
	-- 文字展现方式
	self.functionText = self.___ex.functionText
end

function StartGameItemBoxView:InitView(unlockModel, viewData)
    self.unlockModel = unlockModel
    self.viewData = viewData
    self.isOpen = unlockModel:GetStateById(self.viewData.LIMIT_ID)
    self:BuildView()
end

function StartGameItemBoxView:start()
    self:BindAll()
end

function StartGameItemBoxView:BindAll()
    self.enterBtn:regOnButtonClick(function ()
        if self.isOpen then
            EventSystem.SendEvent("StartGame.OnClickViewBtn", self.viewData.VIEW_ID)
		elseif self.unlockModel then
			local functionData = self.unlockModel:GetUnlockDataById(self.viewData.LIMIT_ID)
			local openLvl = functionData.unlockData.playerLevel or 0
			DialogManager.ShowToast(lang.trans("level_unlock", openLvl))
		else
			DialogManager.ShowToast(lang.trans("not_open"))
        end
    end)
end

function StartGameItemBoxView:BuildView()
    self.enterBtnButton.interactable = self.isOpen
    self.title.enabled = self.isOpen
    self.flash.enabled = self.isOpen
    if self.isOpen then
        self.boxImg.color = Color.white
    else
        self.boxImg.color = Color(0.1, 0.67, 1)
    end

	if self.functionText then 
		self.functionText.enabled = self.isOpen
	end
end

return StartGameItemBoxView