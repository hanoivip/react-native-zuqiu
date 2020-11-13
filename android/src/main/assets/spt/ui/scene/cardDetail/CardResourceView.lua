local CardResourceView = class(unity.base)
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

function CardResourceView:ctor()
    self.parentNode = self.___ex.parentNode
    self.transferResourceIndex = 2
    self.childGoMap = {}
end

function CardResourceView:InitView(cardModel)
    self.cardModel = cardModel
    local curr_childCount = #self.childGoMap
    local resources = cardModel:GetCardResources() or {}

    for i = curr_childCount + 1, #resources do
        local childPrefabPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/CardResourceBar.prefab"
        local childGO = res.Instantiate(childPrefabPath)
        childGO.transform:SetParent(self.parentNode, false)
        table.insert(self.childGoMap, childGO)
    end

    for i = #resources + 1, curr_childCount do
        self.childGoMap[i]:SetActive(false)
    end

    for i, v in ipairs(self.childGoMap) do
        local data = {}
        data.title = self:TransResourceText(resources[i])
        v:GetComponent(clr.CapsUnityLuaBehav):InitView(data)
    end
end

function CardResourceView:TransResourceText(resource)
    if tonumber(resource) == self.transferResourceIndex then
        return lang.transstr("card_resource_title" .. resource, self.cardModel:GetTransferCondition())
    else
        return resource and lang.transstr("card_resource_title" .. resource) or ""
    end
end

return CardResourceView
