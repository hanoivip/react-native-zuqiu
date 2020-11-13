local ConsumeNodeView = class(unity.base, "ConsumeNodeView")

function ConsumeNodeView:ctor()
    self.contentArea = self.___ex.contentArea
    self.descTxt = self.___ex.descTxt
end

function ConsumeNodeView:InitView(pieceModel, model)
    local piecePath = "Assets/CapstonesRes/Game/UI/Common/Part/CardPiece.prefab"
    local obj, spt = res.Instantiate(piecePath)
    obj.transform:SetParent(self.contentArea, false)
    spt:InitView(pieceModel, nil, nil, true)

    local consumeNum = pieceModel:GetAddNum()
    local ownedNum = model:GetBagPieceNum(pieceModel)
    if ownedNum < consumeNum then
        ownedNum = "<color=red>" .. ownedNum .. "</color>"
    else
        ownedNum = "<color=green>" .. ownedNum .. "</color>"
    end
    self.descTxt.text = lang.trans("need_num", ownedNum, consumeNum)
end

return ConsumeNodeView