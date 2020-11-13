local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UpdateBoardType = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateBoardType")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local AssetFinder = require("ui.common.AssetFinder")

local CoachBaseInfoItemView = class(unity.base, "CoachBaseInfoItemView")

function CoachBaseInfoItemView:ctor()
    -- 点击区域
    self.btnBg = self.___ex.btnBg
    -- 图标
    self.imgIcon = self.___ex.imgIcon
    -- 阵型名字或战术选择的档位名字
    self.txtTitle = self.___ex.txtTitle
    -- 当前等级
    self.txtLvl = self.___ex.txtLvl
    -- 偏好阵型或战术的名称
    self.txtContent = self.___ex.txtContent
end

function CoachBaseInfoItemView:start()
end

function CoachBaseInfoItemView:InitView(data)
    self.data = data

    -- 初始化item的类型
    if data.boardType == UpdateBoardType.Formation then
        local length = string.len(data.formationName)
        local formationName = data.formationName
        -- 长度过长调整为2行
        if length > 13 then
            local startPos, endPos = string.find(formationName, "%d")
            if tonumber(startPos) > 1 then
                formationName = string.sub(formationName, 1, startPos - 1) .. "\n" .. string.sub(formationName, startPos, length)
            end
        end
        self.txtTitle.text = formationName -- 阵型名字
        self.txtLvl.text = lang.trans("friends_manager_item_level", data.formations[tostring(data.formationId)].lvl)
        self.txtContent.text = data.formationStr -- 偏好阵型
        self.imgIcon.overrideSprite = AssetFinder.GetCoachBaseInfoItemIcon(data.boardType)
    elseif data.boardType == UpdateBoardType.Tactics then
        self.txtTitle.text = data.tactics[tostring(data.usedTacticIndex)].tacticName -- 战术名字
        self.txtLvl.text = lang.trans("friends_manager_item_level", data.tactics[tostring(data.usedTacticIndex)].lvl)
        self.txtContent.text = data.tacticsStr -- 战术名称
        self.imgIcon.overrideSprite = AssetFinder.GetCoachBaseInfoItemIcon(data.boardType .. "_" .. data.tacticsType)
    else
        self.txtTitle.text = ""
        self.txtLvl.text = ""
        self.txtContent.text = ""
        GameObjectHelper.FastSetActive(self.imgIcon.gameObject, false)
        dump("wrong board type!")
    end
end

return CoachBaseInfoItemView
