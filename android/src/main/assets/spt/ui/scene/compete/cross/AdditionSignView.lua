local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local AdditionSignView = class(unity.base)

function AdditionSignView:ctor()
    self.barImage = self.___ex.barImage
    self.signImage = self.___ex.signImage
	self.signRect = self.___ex.signRect
end

function AdditionSignView:InitView(index, additionProgress, myProgress, isWin, isMatchOver)
	local path = "Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Mix/"
	local progress = ""
	local sign = ""
	local signPosX = 6
	if additionProgress == 1 then
		progress = "Progress4.png"
		sign = isWin and "True.png" or "Wrong.png"
	else
		if index == 1 then 
			progress = "Progress1.png"
			signPosX = -3
		elseif index < additionProgress then 
			progress = "Progress2.png"
		else
			progress = "Progress3.png"
		end

		if index < myProgress then 
			sign = "True.png"
		elseif index == myProgress then 
			sign = isWin and "True.png" or "Wrong.png"
		end
	end
	self.barImage.overrideSprite = res.LoadRes(path .. progress)

	if index > myProgress then 
		self.signImage.enabled = false
	elseif index == myProgress then 
		self.signImage.enabled = isMatchOver
		if isMatchOver then 
			self.signImage.overrideSprite = res.LoadRes(path .. sign)
		end
	else
		self.signImage.enabled = true
		self.signImage.overrideSprite = res.LoadRes(path .. sign)
	end
	self.signRect.anchoredPosition = Vector2(signPosX, self.signRect.anchoredPosition.y)
end

return AdditionSignView