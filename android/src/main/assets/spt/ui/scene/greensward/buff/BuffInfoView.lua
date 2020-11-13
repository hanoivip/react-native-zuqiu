local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local BuffInfoView = class(unity.base)

function BuffInfoView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.contentTxt = self.___ex.contentTxt
--------End_Auto_Generate----------
end

function BuffInfoView:InitView(fixPosX, fixPosY, title, desc)
    self.transform.anchoredPosition = Vector2(fixPosX, fixPosY)
    self.titleTxt.text = title
    self.contentTxt.text = desc
end

return BuffInfoView
