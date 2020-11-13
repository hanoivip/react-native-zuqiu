local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SearchDropDown = class(unity.base)

function SearchDropDown:ctor()
    self.btnDropdown = self.___ex.btnDropdown
    self.btnCloseList = self.___ex.btnCloseList
    self.arrowUp = self.___ex.arrowUp
    self.arrowDown =self.___ex.arrowDown
    self.dropdownListObj = self.___ex.dropdownListObj
    self.content = self.___ex.content
    self.scrollRect = self.___ex.scrollRect
    self.dropdownObj = self.___ex.dropdownObj
    self.selectName = self.___ex.selectName
    self.selectInfo = self.___ex.selectInfo
    self.listRectPosY = nil
end

function SearchDropDown:start()
    self.btnDropdown:regOnButtonClick(function()
        self:OnDropdownClick(true)
    end)
    self.btnCloseList:regOnButtonClick(function()
        self:OnDropdownClick(false)
    end)
end

function SearchDropDown:InitView(model, boxRes, dropdownKey, dropdownList)
    self.model = model
    self.dropdownList = dropdownList
    self:InitDetailView()
    self:CreateDropdownList(boxRes, dropdownKey, dropdownList)
    GameObjectHelper.FastSetActive(self.dropdownListObj, false)
    if dropdownKey then
        self:PlayerSearchOnDropdownSelect(dropdownKey)
    end
end

function SearchDropDown:InitDetailView()
    GameObjectHelper.FastSetActive(self.arrowUp, false)
    GameObjectHelper.FastSetActive(self.arrowDown, true)
    GameObjectHelper.FastSetActive(self.dropdownObj, false)
    GameObjectHelper.FastSetActive(self.selectInfo, true)
end

function SearchDropDown:PlayerSearchOnDropdownSelect(selectDropdownKey)
    GameObjectHelper.FastSetActive(self.dropdownObj, true)
    GameObjectHelper.FastSetActive(self.selectInfo, false)
    if selectDropdownKey then
        self.selectName.text = self.dropdownList[selectDropdownKey]
    else
        self.selectName.text = ""
    end
    if self.selectDropdown then 
        self.selectDropdown(selectDropdownKey)
    end
end

function SearchDropDown:CreateDropdownList(boxRes, dropdownKey, dropdownList)
    for key, desc in pairs(dropdownList) do
        local obj = Object.Instantiate(boxRes)
        local spt = res.GetLuaScript(obj)
        obj.transform:SetParent(self.content)
        obj.transform.localScale = Vector3.one
        spt.onDropdownSelect = function(key) self:OnDropdownClick(false, key) end
        spt:InitView(key, desc, dropdownKey)
    end
end

function SearchDropDown:OnDropdownClick(isOpen, selectDropdownKey)
    GameObjectHelper.FastSetActive(self.dropdownListObj, isOpen)
    GameObjectHelper.FastSetActive(self.arrowUp, isOpen)
    GameObjectHelper.FastSetActive(self.arrowDown, not isOpen)
    if selectDropdownKey then
        self:PlayerSearchOnDropdownSelect(selectDropdownKey)
    end
end

return SearchDropDown
