--local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MySceneListView = class(unity.base)

function MySceneListView:ctor()
    self.title = self.___ex.title
    self.content = self.___ex.content
end

function MySceneListView:start()

end

function MySceneListView:InitView(mySceneListModel)
    self.mySceneListModel = mySceneListModel
    self.itemList = {}
    self.title.text = mySceneListModel:GetName()
    for i = 1, #mySceneListModel.data do
        local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/MyScene/Item.prefab")
        itemObj.transform:SetParent(self.content, false)
        itemSpt:InitView(mySceneListModel.data[i])

        self.itemList[i] = itemSpt
        itemSpt.OnButtonClick = function()
            if mySceneListModel.data[i]:GetSelect() then
                return
            end
            self:ChangeClick(mySceneListModel.data[i].data.key)
        end
    end
    self:SetSelect()
end

function MySceneListView:ChangeClick(name)
    if self.SetClick then
        self.SetClick(self.mySceneListModel:GetName(), name)
    end
end

function MySceneListView:SetSelect()
    for k,v in pairs(self.itemList) do
        v:OnSelect(self.mySceneListModel.data[k]:GetSelect())
    end
end

return MySceneListView