local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local RectTransform = UnityEngine.RectTransform
local RectTransformUtility = UnityEngine.RectTransformUtility
local LotteryDragMask = class(unity.base)

function LotteryDragMask:start()
	self.rectTrans = self.gameObject:GetComponent(RectTransform)
end

function LotteryDragMask:SetOpenCallBack(showRewardCall)
	self.showRewardCall = showRewardCall
end

function LotteryDragMask:onBeginDrag(eventData)
	self.startPos = self.trans.localPosition
end

function LotteryDragMask:onDrag(eventData)
	local success, pos = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.rectTrans, eventData.position, eventData.pressEventCamera, Vector2.zero);
	for i, v in pairs(self.posArea) do
		local inArea = RectTransformUtility.RectangleContainsScreenPoint(v, eventData.position, eventData.pressEventCamera)
		if inArea then
			self.posState[v.name] = true
		end
	end
	self.trans.localPosition = Vector3(pos.x, pos.y, 0)
end

function LotteryDragMask:onEndDrag(eventData)
	self.trans.localPosition = self.startPos
	local inAreaCount = 0
	for i, v in pairs(self.posState) do
		if v then
			inAreaCount = inAreaCount + 1
		end
	end
	if inAreaCount > 3 then
		self.rawImg.enabled = false
		if self.showRewardCall then
			self.showRewardCall()
		end
	end
end

function LotteryDragMask:SetMaskTransAndRawImage(trans, rawImg)
	self.trans = trans
	self.rawImg = rawImg
end

function LotteryDragMask:OnCheckPosArea(posArea)
	self.posArea = posArea
	self.posState = {}
end

return LotteryDragMask
