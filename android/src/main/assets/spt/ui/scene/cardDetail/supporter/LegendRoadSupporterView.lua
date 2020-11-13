local GameObjectHelper = require("ui.common.GameObjectHelper")
local SupporterType = require("ui.models.cardDetail.supporter.SupporterType")
local SlrType = SupporterType.SlrType
local DialogManager = require("ui.control.manager.DialogManager")
local LegendRoadSupporterView = class(unity.base, "LegendRoadSupporterView")

function LegendRoadSupporterView:ctor()
--------Start_Auto_Generate--------   
    self.legendRoadGo = self.___ex.legendRoadGo
    self.scheduleTxt = self.___ex.scheduleTxt
    self.noSupportTxt = self.___ex.noSupportTxt
    self.supportGo = self.___ex.supportGo
    self.otherTog = self.___ex.otherTog
    self.lockGo = self.___ex.lockGo
    self.lockTxt = self.___ex.lockTxt
    self.lockConditionTxt = self.___ex.lockConditionTxt
    self.scheduleMeTxt = self.___ex.scheduleMeTxt
    self.supportMeGo = self.___ex.supportMeGo
    self.selfTog = self.___ex.selfTog
--------End_Auto_Generate----------   
end

function LegendRoadSupporterView:start()
	self.otherTog.onValueChanged.AddListener(function (isOn)
		if isOn then
			self:OnToggleClick(SlrType.SupportCard)
		end
	end)
	self.selfTog.onValueChanged.AddListener(function (isOn)
		if isOn then
			self:OnToggleClick(SlrType.SelfCard)
		end
	end)
end

function LegendRoadSupporterView:InitView(legendRoadSupporterModel)
    self.model = legendRoadSupporterModel
    self:ShowLegendRoadSupporter()
    self:ShowLegendRoadSelect()
end

local greenColor = "<color=#0b8110>%s</color>"
function LegendRoadSupporterView:ShowLegendRoadSupporter()
	local data = self.model:GetData()
	if data.noSupportCard then
		GameObjectHelper.FastSetActive(self.legendRoadGo, false)
		return
	end
	
	if data.noOpen then
		--通知显示本卡没开启传奇之路
		GameObjectHelper.FastSetActive(self.legendRoadGo, false)
		return
	end
	
	GameObjectHelper.FastSetActive(self.legendRoadGo, true)
	local scheStr = lang.transstr("support_legend_schedule") .. " "
	--显示本卡进度
    self.scheduleMeTxt.text = scheStr .. data.chapterProgress .. "-" .. data.stageProgress
	if data.noSupportOpen then
		GameObjectHelper.FastSetActive(self.noSupportTxt.gameObject, true)
		GameObjectHelper.FastSetActive(self.supportGo, false)
		self.scheduleTxt.text = scheStr .. lang.transstr("support_legend_noopen")
		self.noSupportTxt.text = lang.trans("support_legendr_other_noschedule")
		return
	end
	if data.isSupportOther then
		GameObjectHelper.FastSetActive(self.noSupportTxt.gameObject, true)
		GameObjectHelper.FastSetActive(self.supportGo, false)
		self.scheduleTxt.text = scheStr .. data.supportChapterProgress .. "-" .. data.supportStageProgress
		self.noSupportTxt.text = lang.trans("support_tip_10")
		return
	end
	GameObjectHelper.FastSetActive(self.noSupportTxt.gameObject, false)
	GameObjectHelper.FastSetActive(self.supportGo, true)
    self.scheduleTxt.text = scheStr .. string.format(greenColor, data.curSupportChapterProgress .. "-" .. 
    	data.curSupportStageProgress) .. "/" .. data.supportChapterProgress .. "-" .. data.supportStageProgress
    
    if not data.lockChapter or data.lockChapter == 0 then
    	GameObjectHelper.FastSetActive(self.lockGo, false)
    else
    	GameObjectHelper.FastSetActive(self.lockGo, true)
    	self.lockTxt.text = lang.trans("support_legend_lock", data.lockChapter, data.lockStage)
    	self.lockConditionTxt.text = data.lockConditionStr
    end
end

function LegendRoadSupporterView:ShowLegendRoadSelect()
	local selectType = self.model:GetSelectLegendRoadType()
	if selectType == SlrType.SupportCard then
		self.otherTog.isOn = true
	else
		self.selfTog.isOn = true
	end
end

function LegendRoadSupporterView:OnToggleClick(clickType)
	local selectType = self.model:GetSelectLegendRoadType()
	if clickType == selectType then
		return
	end
	self:ShowLegendRoadSelect()
	local func = function()
		self.model:SetSelectLegendRoadType(clickType)
		EventSystem.SendEvent("Supporter_Select_type")
		DialogManager.ShowToastByLang("support_legend_success")
		self:ShowLegendRoadSelect()
	end
	if self.model:IsLowerSelect(clickType) then
		DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("support_switchlengedroad_content"), func)
	else
		func()
	end
end

function LegendRoadSupporterView:EnterScene()

end

function LegendRoadSupporterView:ExitScene()

end

return LegendRoadSupporterView
