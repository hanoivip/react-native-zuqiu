local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachBaseInfoFormationItemView = class(unity.base, "CoachBaseInfoFormationItemView")

function CoachBaseInfoFormationItemView:ctor()
    -- 阵型item容器
    self.objFormationContainer = self.___ex.objFormationContainer
    -- 阵型控制脚本
    self.sptFormation = self.___ex.sptFormation
    -- 振兴名称
    self.txtName = self.___ex.txtName
    -- 当前阵型等级
    self.txtLvl = self.___ex.txtLvl
    -- 是否选中
    self.imgSelected = self.___ex.imgSelected
    self.btnClick = self.___ex.btnClick
    -- 是否使用
    self.imgUsed = self.___ex.imgUsed
end

function CoachBaseInfoFormationItemView:start()
    self:RegBtnEvent()
end

function CoachBaseInfoFormationItemView:InitView(data)
    self.data = data

    self.sptFormation:InitView(0, data.formationId, data.formationData)
    self.txtName.text = data.formationData.name
    self.txtLvl.text = lang.trans("friends_manager_item_level", data.lvl)
    self:BuildSelect()
    self:BuildUsed()
end

function CoachBaseInfoFormationItemView:OnEnterScene()
end

function CoachBaseInfoFormationItemView:OnExitScene()
end

function CoachBaseInfoFormationItemView:RegBtnEvent()
end

-- 玩家列表中点击的阵型
function CoachBaseInfoFormationItemView:BuildSelect()
    GameObjectHelper.FastSetActive(self.imgSelected.gameObject, self.data.isSelected)
end

-- 玩家当前使用的阵型
function CoachBaseInfoFormationItemView:BuildUsed()
    GameObjectHelper.FastSetActive(self.imgUsed.gameObject, self.data.isChoosed)
end

return CoachBaseInfoFormationItemView
