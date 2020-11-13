local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local EventSystem = require("EventSystem")
local CoachMainModel = require("ui.models.coach.CoachMainModel")

local FormationItemView = class(unity.base)

function FormationItemView:ctor()
    -- 球场
    self.courtContent = self.___ex.courtContent
    -- 选择框
    self.radioBox = self.___ex.radioBox
    -- 名称
    self.txtStringName = self.___ex.txtStringName
    self.txtNumberName = self.___ex.txtNumberName
    -- 当前选择阵型Id
    self.nowSelectFormationId = nil
    -- 阵型数据
    self.formationData = nil
    -- 阵型Id
    self.formationId = nil
    -- 黄色边框
    self.border = self.___ex.border
    self.coachMainModel = CoachMainModel.new()
end

function FormationItemView:InitView(nowSelectFormationId, formationId, formationData)
    self.nowSelectFormationId = tonumber(nowSelectFormationId)
    self.formationId = tonumber(formationId)
    self.formationData = formationData
    self:BuildPage()
end

function FormationItemView:start()
    self:BindAll()
    self:RegisterEvent()
end

function FormationItemView:BuildPage()
    self:BuildCourt()
    self:BuildName()
    if self.nowSelectFormationId == self.formationId then
        self.radioBox:selectBtn()
        self.border:SetActive(true)
    else
        self.radioBox:unselectBtn()
        self.border:SetActive(false)
    end
end

function FormationItemView:BuildName()
    local formationName = self.formationData.name
    local formationLvl = self.coachMainModel:GetFormationLvl(self.formationId)
    self.txtStringName.text = formationName 
    self.txtNumberName.text = "Lv." .. formationLvl
end

-- 为所有的按钮绑定事件
function FormationItemView:BindAll()
    -- 选择框
    self.radioBox:regOnButtonClick(function ()
        self.radioBox:selectBtn()
        EventSystem.SendEvent("FormationItemView.OnSelectFormation", self.formationId)
        EventSystem.SendEvent("FormationSelectView.OnSelectFormation", self.formationId)
    end)
end

--- 注册事件
function FormationItemView:RegisterEvent()
    EventSystem.AddEvent("FormationItemView.OnSelectFormation", self, self.OnSelectFormation)
end

--- 移除事件
function FormationItemView:RemoveEvent()
    EventSystem.RemoveEvent("FormationItemView.OnSelectFormation", self, self.OnSelectFormation)
end

--- 当选中了一个阵型时
function FormationItemView:OnSelectFormation(formationId)
    if formationId ~= self.formationId then
        self.border:SetActive(false)
        self.radioBox:unselectBtn()
    else
        self.border:SetActive(true)
    end
end

--- 构建球场
function FormationItemView:BuildCourt()
    local courtSize = self.courtContent.sizeDelta
    local count = self.courtContent.childCount
    if count == 0 then
        for i = 1, 11 do
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationItemShirt.prefab")
            obj.transform:SetParent(self.courtContent, false)
            spt:InitView(i)
            local numberPos = self.formationData.posArray[i]
            spt:SetPos(numberPos, self.formationId, courtSize)
        end
    else
        for i = 0, count - 1 do
            local spt = res.GetLuaScript(self.courtContent:GetChild(i).gameObject)
            spt:InitView(i + 1)
            local numberPos = self.formationData.posArray[i + 1]
            spt:SetPos(numberPos, self.formationId, courtSize)
        end
    end
end

function FormationItemView:onDestroy()
    self:RemoveEvent()
end

return FormationItemView
