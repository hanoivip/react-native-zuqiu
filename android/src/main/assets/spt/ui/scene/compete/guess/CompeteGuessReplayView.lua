local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CompeteGuessReplayView = class(unity.base, "CompeteGuessReplayView")

local itemPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessReplayItem.prefab"

function  CompeteGuessReplayView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 录像显示区域
    self.rctContent = self.___ex.rctContent

    -- 脚本数据
    self.itemSpts = {}
end

function CompeteGuessReplayView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end


function CompeteGuessReplayView:InitView(competeGuessReplayModel)
    self.model = competeGuessReplayModel

    local matchCount = self.model:GetMatchCount()
    for i = 1, matchCount do
        local obj, spt = res.Instantiate(itemPath)
        obj.transform:SetParent(self.rctContent.transform)
        obj.transform.localScale = Vector3.one
        spt.idx = i
        spt.onClickBtnReplay = function(vid) self:OnClickBtnReplay(vid) end
        spt:InitView(self.model:GetMatchData(i))
        table.insert(self.itemSpts, spt)
    end
end

function CompeteGuessReplayView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function CompeteGuessReplayView:OnClickBtnReplay(vid)
    if self.onClickBtnReplay then
        self.onClickBtnReplay(vid)
    end
end

return CompeteGuessReplayView
