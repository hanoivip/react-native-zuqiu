local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Card = require("data.Card")
local ShootView = class(unity.base)

function ShootView:ctor()
    self.gName = self.___ex.gName
    self.aName = self.___ex.aName
	self.gSign = self.___ex.gSign
	self.aSign = self.___ex.aSign
end

function ShootView:InitView(shootId, assisterId, isHome)
	local shootData = Card[shootId] or {}
	local assisterData = Card[assisterId] or {}
	self.gName.text = shootData.name2
	self.aName.text = assisterData.name2
	local scale = isHome and Vector3(1, 1, 1) or Vector3(-1, 1, 1)
    self.gName.transform.localScale = scale
    self.aName.transform.localScale = scale
	self.gSign.transform.localScale = scale
	self.aSign.transform.localScale = scale
end

return ShootView