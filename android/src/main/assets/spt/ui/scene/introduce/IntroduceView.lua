local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local IntroduceView = class(unity.base)

function IntroduceView:ctor()
	self.labelScroll = self.___ex.labelScroll
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.contentTitle = self.___ex.contentTitle
    self.inlineText = self.___ex.inlineText
	self.contentText = self.___ex.contentText
end

function IntroduceView:InitView(data)
	self.data = data
	self.labelScroll:InitView(data)
end

function IntroduceView:SwitchPanel(index)
	local selectData = self.data[index]
	self.contentTitle.text = selectData.title
	self.inlineText.inline.text = selectData.desc
	local hasInline = tobool(self.inlineText.inline)
	GameObjectHelper.FastSetActive(self.contentText.gameObject, not hasInline)
	GameObjectHelper.FastSetActive(self.inlineText.gameObject, hasInline)
end

function IntroduceView:GetRuleBarRes()
    if not self.ruleBar then 
        self.ruleBar = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/RuleBar.prefab")
    end
    return self.ruleBar
end

function IntroduceView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return IntroduceView
