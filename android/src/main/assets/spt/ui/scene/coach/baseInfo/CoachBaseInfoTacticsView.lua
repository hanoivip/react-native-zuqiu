local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CoachBaseInfoTacticsView = class(unity.base, "CoachBaseInfoTacticsView")

function CoachBaseInfoTacticsView:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.txtTitleRef = self.___ex.txtTitleRef
    -- 传球策略
    self.passTacticLevel = self.___ex.passTacticLevel
    self.sliderPassTactic = self.___ex.sliderPassTactic
    self.listenerPassTactic = self.___ex.listenerPassTactic
    -- 战术节奏
    -- 比赛心态
    -- 防守策略
    -- 进攻偏好
end

function CoachBaseInfoTacticsView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachBaseInfoTacticsView:InitView(coachBaseInfoTacticsModel)
    self.model = coachBaseInfoTacticsModel
    -- 设置标题
    local title = self.model:GetBoardTitle()
    self.txtTitle.text = title
    self.txtTitleRef.text = title
end

function CoachBaseInfoTacticsView:RegBtnEvent()
    -- self.btnClose:regOnButtonClick(function()
    --     self:Close()
    -- end)
end

function CoachBaseInfoTacticsView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return CoachBaseInfoTacticsView
