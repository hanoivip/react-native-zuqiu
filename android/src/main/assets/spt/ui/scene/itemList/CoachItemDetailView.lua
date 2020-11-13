local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AssetFinder = require("ui.common.AssetFinder")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local EventSystem = require("EventSystem")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CoachItemDetailView = class(unity.base)

function CoachItemDetailView:ctor()
    self.itemName = self.___ex.itemName
    self.canvasGroup = self.___ex.canvasGroup
    self.btnClose = self.___ex.btnClose
    self.itemQualityBoard = self.___ex.itemQualityBoard
    self.itemDesc = self.___ex.itemDesc
    self.itemNumForOther = self.___ex.itemNumForOther
    self.itemNumForItemList = self.___ex.itemNumForItemList
    self.itemNumAreaForItemList = self.___ex.itemNumAreaForItemList
    self.itemBoardArea = self.___ex.itemBoardArea
    self.itemNumAreaForOther = self.___ex.itemNumAreaForOther
    self.itemIcon = self.___ex.itemIcon
    self.decorate = self.___ex.decorate
	self.skillIcon = self.___ex.skillIcon
end

function CoachItemDetailView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
 
    self:PlayInAnimator()
end

function CoachItemDetailView:InitView(model)
    self.model = model
    self.itemType = model:GetCoachItemType()
    local name = model:GetName() or lang.trans("retry_login")
    self.itemName.text = name
    
    self.itemQualityBoard.overrideSprite = AssetFinder.GetItemQualityBoard(model:GetQuality())
    local desc = model:GetDesc() or lang.trans("retry_login_desc")
    self.itemDesc.text = desc
	self.itemNumForOther.text = lang.trans("itemDetail_number",self.model:GetOwnNum())

	local isShowDecorate = false
    if self.itemType == CoachItemType.PlayerTalentSkillBook then
		isShowDecorate = true
		self.decorate.overrideSprite = AssetFinder.GetCoachFeatureDecorateIcon(self.model:GetDecoratePicIcon())
		self.skillIcon.overrideSprite = AssetFinder.GetCoachItemIcon(self.model:GetIconIndex(), self.itemType)
	else
		self.itemIcon.overrideSprite = AssetFinder.GetCoachItemIcon(self.model:GetIconIndex(), self.itemType)
    end
	GameObjectHelper.FastSetActive(self.decorate.gameObject, isShowDecorate)
	GameObjectHelper.FastSetActive(self.itemIcon.gameObject, not isShowDecorate)
end

function CoachItemDetailView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachItemDetailView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function CoachItemDetailView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function CoachItemDetailView:Close()
    self:PlayOutAnimator()
end

function CoachItemDetailView:EnterScene()

end

function CoachItemDetailView:ExitScene()

end

return CoachItemDetailView