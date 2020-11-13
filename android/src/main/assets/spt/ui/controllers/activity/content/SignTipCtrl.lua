local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Card = require("data.Card")
local SignTipCtrl = class()

function SignTipCtrl:ctor(cardId, needDay)
    local viewObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/S11.prefab")
    self.view = viewObject:GetComponent(clr.CapsUnityLuaBehav)
    self.view.OnContinue = function() self:Close() end
    self:ShowSignCardTip(cardId, needDay)
end

function SignTipCtrl:ShowSignCardTip(cardId, needDay)
    local cardStaticData = Card[tostring(cardId)]
    local name = cardStaticData.name2
    self.view.txtDialog.text = lang.trans("sign_tip", needDay, name)
end

function SignTipCtrl:Close()
    Object.Destroy(self.view.gameObject)
end

return SignTipCtrl
