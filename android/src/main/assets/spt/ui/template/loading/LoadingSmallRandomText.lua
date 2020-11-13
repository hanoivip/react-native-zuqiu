local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local LoadingSmallRandomText = class(unity.base)

function LoadingSmallRandomText:ctor()
    self.txt = self.___ex.txt
    self.txts = {}
    self.txtIndex = nil
    self.defaultTips = nil
	self.autoCloseTime = 0
	self.closeFunc = nil
    self.canvasGroup = self.___ex.canvasGroup
    self:SetDefaultDesc()
end

function LoadingSmallRandomText:SetDefaultDesc()
    self.txts = {
        "Loading",
        "Loading .",
        "Loading . .",
        "Loading . . .",
    }
    self.txtIndex = 1
end

function LoadingSmallRandomText:SetTxts(txts)
    -- if not txts or type(txts) ~= 'table' then
    --     return
    -- end

    -- self.txts = txts
end

function LoadingSmallRandomText:SetDefaultTips(tips)
    -- self.defaultTips = tips
end

function LoadingSmallRandomText:SetCloseTime(closeTime, closeFunc)
	self.autoCloseTime = closeTime
	self.intervalTime = 0
	self.unscaledTime = Time.unscaledTime
	self.closeFunc = closeFunc
end

local AppearTime = 0.3
function LoadingSmallRandomText:start()
    self.canvasGroup.alpha = 0
    self:UpdateDesc()
    self:coroutine(function ()
        coroutine.yield(UnityEngine.WaitForSeconds(AppearTime))
        self.canvasGroup.alpha = 1
        while 1 do
			self:UpdateTime()
            coroutine.yield(UnityEngine.WaitForSeconds(1))
            self:UpdateDesc()
        end
    end)
end

function LoadingSmallRandomText:UpdateDesc()
    local desc = self.txts[self.txtIndex]
    self.txt.text = desc
    self.txtIndex = self.txtIndex + 1
    if self.txtIndex > #self.txts then
        self.txtIndex = 1
    end
end

function LoadingSmallRandomText:UpdateTime()
	if self.autoCloseTime > 0 then 
		self.intervalTime = self.intervalTime + (Time.unscaledTime - self.unscaledTime)
		self.unscaledTime = Time.unscaledTime

		if self.intervalTime > self.autoCloseTime then 
			self:AutoClose()
		end
	end
end

function LoadingSmallRandomText:AutoClose()
	if self.closeFunc then 
		self.closeFunc()
	elseif self.closeDialog then 
		self.closeDialog()
	else
		Object.Destroy(self.gameObject)
	end
end

return LoadingSmallRandomText