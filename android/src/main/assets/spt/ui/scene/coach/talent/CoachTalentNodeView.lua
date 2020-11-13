local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachTalentNodeView = class(unity.base, "CoachTalentNodeView")

function CoachTalentNodeView:ctor()
    -- 自身的RectTransform
    self.rct = self.___ex.rct
    -- 图标
    self.imgIcon = self.___ex.imgIcon
    -- 锁头
    self.objLock = self.___ex.objLock
    -- 技能名字
    self.txtName = self.___ex.txtName
    -- 等级
    self.objLvl = self.___ex.objLvl
    self.txtLvl = self.___ex.txtLvl
    -- 点击区域
    self.click = self.___ex.click

    self.grid = nil -- 网格化后坐标
    self.position = nil -- 实际RrctTransform坐标
    self.isLocked = true
    self.canUnlock = false

    self.arrowSpt = nil -- 前置箭头
    self.lines = nil -- 多叉出口
end

function CoachTalentNodeView:start()
    self.click:regOnButtonClick(function()
        EventSystem.SendEvent("OnTreeNodeClick", self.data)
    end)
end

function CoachTalentNodeView:InitView(treeNode)
    self.treeNode = treeNode
    self.data = treeNode:GetContent()
    self.imgIcon.overrideSprite = AssetFinder.GetCoachTalentSkill(self.data.picIndex)
    self.txtName.text = tostring(self.data.talentName)

    self.isLocked = self.data.isLocked
    self.canUnlock = self.data.canUnlock

    if self.isLocked then -- 未解锁
        if self.canUnlock then -- 可解锁
            GameObjectHelper.FastSetActive(self.objLock.gameObject, false)
        else
            GameObjectHelper.FastSetActive(self.objLock.gameObject, true)
        end
        GameObjectHelper.FastSetActive(self.objLvl.gameObject, false)
        self.imgIcon.color = Color(0, 1, 1, 1) -- 置灰
    else
        GameObjectHelper.FastSetActive(self.objLock.gameObject, false)
        GameObjectHelper.FastSetActive(self.objLvl.gameObject, true)
        self.imgIcon.color = Color(1, 1, 1, 1)
        self.txtLvl.text = lang.trans("friends_manager_item_level", self.data.lvl .. "/" .. self.data.maxLvl)
    end
end

function CoachTalentNodeView:GetNode()
    return self.treeNode
end

function CoachTalentNodeView:SetGrid(x, y)
    self.grid = Vector2(x, y)
end

function CoachTalentNodeView:GetGrid()
    return self.grid or Vector2.zero
end

function CoachTalentNodeView:SetPosition(pos)
    self.position = pos
    self.rct.anchoredPosition = pos
end

function CoachTalentNodeView:GetPosition()
    return self.position or Vector2.zero
end

function CoachTalentNodeView:SetFrontArrow(arrowSpt)
    self.arrowSpt = arrowSpt
end

function CoachTalentNodeView:InitArrowState()
    if not self.arrowSpt then return end

    self.arrowSpt:SetState(self.isLocked, self.canUnlock)
end

function CoachTalentNodeView:SetBehindLines(lines)
    self.lines = lines
end

function CoachTalentNodeView:InitLineState()
    if not self.lines then return end

    for k, v in pairs(self.lines) do
        v:SetState(self.isLocked, self.canUnlock)
    end
end

function CoachTalentNodeView:ResetState()
    self.grid = nil
    self.position = nil
    self.isLocked = true
    self.canUnlock = false
    self.arrowSpt = nil
    self.lines = nil
end

return CoachTalentNodeView
