local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local GuildRequestItemView = class(unity.base)

function GuildRequestItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.btnDetail = self.___ex.btnDetail
    self.time = self.___ex.time
    self.btnCancel = self.___ex.btnCancel
    self.btnComfirm = self.___ex.btnComfirm
end

function GuildRequestItemView:start()
    self.btnDetail:regOnButtonClick(function() 
        if type(self.onViewDetail) == "function" then
            self.onViewDetail()
        end
    end)
    self.btnCancel:regOnButtonClick(function() 
        if type(self.onBtnCancelClick) == "function" then
            self.onBtnCancelClick()
        end
    end)
    self.btnComfirm:regOnButtonClick(function() 
        if type(self.onBtnComfirmClick) == "function" then
            self.onBtnComfirmClick()
        end
    end)
end

local function formateNum(num)
    if string.len(num) < 2 then
        return '0' .. num
    else
        return tostring(num)
    end
end

function GuildRequestItemView:InitView(itemModel)
    self.itemModel = itemModel
    self.nameTxt.text = itemModel:GetName()
    self.level.text = "Lv" .. tostring(itemModel:GetLevel())
    local timeTable = string.convertSecondToTimeTable(itemModel:GetLastTime())
    self.time.text = formateNum(timeTable.hour) .. ":" .. formateNum(timeTable.minute)
    local logoTable = itemModel:GetTeamLogo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoTable)
end

function GuildRequestItemView:onDestroy()
end

return GuildRequestItemView